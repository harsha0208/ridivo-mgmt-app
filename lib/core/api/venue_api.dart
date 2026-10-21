import 'package:dio/dio.dart';

import '../models/staff_models.dart';
import 'api_exception.dart';

class VenueApi {
  VenueApi(this._dio);

  final Dio _dio;

  Future<({StaffInfo staff, List<EventAssignment> events, String access, String refresh})>
      login(String email, String password) async {
    final res = await _dio.post(
      '/venue/auth/login',
      data: {'email': email, 'password': password},
      options: Options(extra: {'skipAuth': true}),
    );
    final data = _unwrap(res);
    final events = (data['events'] as List<dynamic>? ?? [])
        .map((e) => EventAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
    return (
      staff: StaffInfo.fromJson(data['staff'] as Map<String, dynamic>),
      events: events,
      access: data['access_token'] as String,
      refresh: data['refresh_token'] as String,
    );
  }

  Future<String> refresh(String refreshToken) async {
    final res = await _dio.post(
      '/venue/auth/refresh',
      data: {'refresh_token': refreshToken},
      options: Options(extra: {'skipAuth': true}),
    );
    final data = _unwrap(res);
    return data['access_token'] as String;
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post(
      '/venue/auth/logout',
      data: {'refresh_token': refreshToken},
    );
  }

  Future<({StaffInfo staff, List<EventAssignment> events})> me() async {
    final res = await _dio.get('/venue/auth/me');
    final data = _unwrap(res);
    final events = (data['events'] as List<dynamic>? ?? [])
        .map((e) => EventAssignment.fromJson(e as Map<String, dynamic>))
        .toList();
    return (
      staff: StaffInfo.fromJson(data['staff'] as Map<String, dynamic>),
      events: events,
    );
  }

  Future<List<Map<String, dynamic>>> listOccurrences(String eventId) async {
    final res = await _dio.get('/venue/events/$eventId/venue/occurrences');
    return _unwrapList(res);
  }

  Future<List<VenueTicket>> searchTickets(String eventId, String q) async {
    final res = await _dio.get(
      '/venue/events/$eventId/venue/tickets',
      queryParameters: {'q': q, 'limit': 20},
    );
    final data = _unwrapList(res);
    return data.map(VenueTicket.fromJson).toList();
  }

  Future<ScanResult> scan(String eventId, String qrToken) async {
    final res = await _dio.post(
      '/venue/events/$eventId/venue/scan',
      data: {
        'qr_token': qrToken,
        'checkin_type': 'entry',
        'source': 'app',
      },
    );
    return ScanResult.fromJson(_unwrap(res));
  }

  /// Resolve ticket from QR for timing groups (no check-in).
  Future<ScanResult> resolveQR(String eventId, String qrToken) async {
    final res = await _dio.post(
      '/venue/events/$eventId/venue/tickets/resolve-qr',
      data: {
        'qr_token': qrToken,
        'source': 'app',
      },
    );
    return ScanResult.fromJson(_unwrap(res));
  }

  Future<void> checkIn(String eventId, String ticketId) async {
    await _dio.post(
      '/venue/events/$eventId/tickets/$ticketId/check-in',
      data: {'checkin_type': 'entry'},
    );
  }

  Future<TimingSession> startTiming(String eventId, String ticketId) async {
    final res = await _dio.post(
      '/venue/events/$eventId/tickets/$ticketId/timings/start',
      data: <String, dynamic>{},
    );
    return TimingSession.fromJson(_unwrap(res));
  }

  Future<TimingSession> recordTiming(
    String eventId,
    String ticketId, {
    required DateTime startedAt,
    required DateTime finishedAt,
    int? lapsTarget,
  }) async {
    final res = await _dio.post(
      '/venue/events/$eventId/tickets/$ticketId/timings',
      data: <String, dynamic>{
        'started_at': startedAt.toUtc().toIso8601String(),
        'finished_at': finishedAt.toUtc().toIso8601String(),
        if (lapsTarget != null && lapsTarget > 0) 'laps_target': lapsTarget,
      },
    );
    return TimingSession.fromJson(_unwrap(res));
  }

  Future<TimingSession> finishTiming(String eventId, String timingId) async {
    final res = await _dio.post(
      '/venue/events/$eventId/timings/$timingId/finish',
    );
    return TimingSession.fromJson(_unwrap(res));
  }

  Future<TimingSession> dnfTiming(String eventId, String timingId) async {
    final res = await _dio.post(
      '/venue/events/$eventId/timings/$timingId/dnf',
    );
    return TimingSession.fromJson(_unwrap(res));
  }

  Map<String, dynamic> _unwrap(Response res) {
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw ApiException('Unexpected response');
    }
    _throwIfEnvelopeError(body, res.statusCode);
    final data = _envelopeData(body);
    if (data is Map<String, dynamic>) return data;
    throw ApiException('Unexpected data shape');
  }

  List<Map<String, dynamic>> _unwrapList(Response res) {
    final body = res.data;
    if (body is! Map<String, dynamic>) {
      throw ApiException('Unexpected response');
    }
    _throwIfEnvelopeError(body, res.statusCode);
    final data = _envelopeData(body);
    if (data is List) {
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return const [];
  }

  /// Supports ridivo `{ data, message? }` / `{ success, data, message }` and
  /// `{ error: { code, message } }` envelopes.
  void _throwIfEnvelopeError(Map<String, dynamic> body, int? statusCode) {
    if (body['success'] == false) {
      throw ApiException(
        body['message'] as String? ?? 'Request failed',
        code: body['code'] as String?,
        statusCode: statusCode,
      );
    }
    final err = body['error'];
    if (err is Map<String, dynamic>) {
      throw ApiException(
        err['message'] as String? ?? 'Request failed',
        code: err['code'] as String?,
        statusCode: statusCode,
      );
    }
  }

  dynamic _envelopeData(Map<String, dynamic> body) {
    if (body.containsKey('data')) return body['data'];
    if (body.containsKey('success') || body.containsKey('error')) {
      return null;
    }
    return body;
  }
}
