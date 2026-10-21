import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage(this._secure, this._prefs);

  final FlutterSecureStorage _secure;
  final SharedPreferences _prefs;

  static const _accessKey = 'venue_access_token';
  static const _refreshKey = 'venue_refresh_token';
  static const _selectedEventKey = 'selected_event_id';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secure.write(key: _accessKey, value: accessToken),
      _secure.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  Future<void> saveAccessToken(String accessToken) async {
    await _secure.write(key: _accessKey, value: accessToken);
  }

  Future<String?> getAccessToken() => _secure.read(key: _accessKey);

  Future<String?> getRefreshToken() => _secure.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await Future.wait([
      _secure.delete(key: _accessKey),
      _secure.delete(key: _refreshKey),
    ]);
  }

  Future<void> setSelectedEventId(String? eventId) async {
    if (eventId == null || eventId.isEmpty) {
      await _prefs.remove(_selectedEventKey);
    } else {
      await _prefs.setString(_selectedEventKey, eventId);
    }
  }

  String? getSelectedEventId() => _prefs.getString(_selectedEventKey);
}
