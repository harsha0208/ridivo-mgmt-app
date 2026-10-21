import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/dio_factory.dart';
import '../auth/session_controller.dart';
import '../auth/token_storage.dart';

/// Overridden in [main] with the real instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(
    const FlutterSecureStorage(),
    ref.watch(sharedPreferencesProvider),
  );
});

final dioFactoryProvider = Provider<DioFactory>((ref) {
  return DioFactory(ref.watch(tokenStorageProvider));
});

final sessionControllerProvider =
    ChangeNotifierProvider<SessionController>((ref) {
  return SessionController(
    ref.watch(tokenStorageProvider),
    ref.watch(dioFactoryProvider),
  );
});
