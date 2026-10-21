import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../auth/token_storage.dart';
import '../config/env.dart';
import 'api_exception.dart';
import 'venue_api.dart';

class DioFactory {
  DioFactory(this._storage);

  final TokenStorage _storage;
  Dio? _dio;
  VenueApi? _api;
  bool _refreshing = false;

  Dio get dio {
    _dio ??= _create();
    return _dio!;
  }

  VenueApi get api {
    _api ??= VenueApi(dio);
    return _api!;
  }

  Dio _create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Env.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['skipAuth'] == true) {
            return handler.next(options);
          }
          final token = await _storage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final status = error.response?.statusCode;
          final req = error.requestOptions;
          if (status != 401 || req.extra['retried'] == true || req.extra['skipAuth'] == true) {
            return handler.next(_mapError(error));
          }
          if (_refreshing) {
            return handler.next(_mapError(error));
          }
          _refreshing = true;
          try {
            final refresh = await _storage.getRefreshToken();
            if (refresh == null || refresh.isEmpty) {
              return handler.next(_mapError(error));
            }
            final bare = Dio(
              BaseOptions(
                baseUrl: Env.apiBaseUrl,
                headers: {'Content-Type': 'application/json'},
              ),
            );
            final res = await bare.post(
              '/venue/auth/refresh',
              data: {'refresh_token': refresh},
            );
            final body = res.data as Map<String, dynamic>?;
            final access = body?['data']?['access_token'] as String? ??
                body?['access_token'] as String?;
            if (access == null) {
              return handler.next(_mapError(error));
            }
            await _storage.saveAccessToken(access);
            req.headers['Authorization'] = 'Bearer $access';
            req.extra['retried'] = true;
            final clone = await dio.fetch(req);
            return handler.resolve(clone);
          } catch (_) {
            return handler.next(_mapError(error));
          } finally {
            _refreshing = false;
          }
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    }

    return dio;
  }

  DioException _mapError(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] as String? ??
          (data['error'] is Map ? (data['error'] as Map)['message'] as String? : null) ??
          error.message ??
          'Request failed';
      final code = data['code'] as String? ??
          (data['error'] is Map ? (data['error'] as Map)['code'] as String? : null);
      return DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: ApiException(message, code: code, statusCode: error.response?.statusCode),
        message: message,
      );
    }
    return error;
  }
}
