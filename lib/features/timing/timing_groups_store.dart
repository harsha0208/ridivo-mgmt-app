import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'timing_groups_models.dart';

class TimingGroupsStore {
  TimingGroupsStore(this._prefs);

  final SharedPreferences _prefs;

  String _key(String eventId) => 'timing_groups:$eventId';

  TimingGroupsState load(String eventId) {
    final raw = _prefs.getString(_key(eventId));
    if (raw == null || raw.isEmpty) return TimingGroupsState.empty();
    try {
      return TimingGroupsState.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return TimingGroupsState.empty();
    }
  }

  Future<void> save(String eventId, TimingGroupsState state) async {
    await _prefs.setString(_key(eventId), jsonEncode(state.toJson()));
  }

  Future<void> clear(String eventId) async {
    await _prefs.remove(_key(eventId));
  }
}
