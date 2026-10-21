import 'package:flutter/foundation.dart';

import '../api/api_exception.dart';
import '../api/dio_factory.dart';
import '../models/staff_models.dart';
import 'token_storage.dart';

enum SessionStatus { unknown, signedOut, signedIn }

class SessionController extends ChangeNotifier {
  SessionController(this._storage, this._dioFactory);

  final TokenStorage _storage;
  final DioFactory _dioFactory;

  SessionStatus status = SessionStatus.unknown;
  StaffInfo? staff;
  List<EventAssignment> events = const [];
  EventAssignment? selectedEvent;
  String? error;

  StaffRole? get currentRole => selectedEvent?.role;

  Future<void> bootstrap() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) {
      status = SessionStatus.signedOut;
      notifyListeners();
      return;
    }
    try {
      final me = await _dioFactory.api.me();
      staff = me.staff;
      events = me.events;
      _selectEvent(_storage.getSelectedEventId());
      status = SessionStatus.signedIn;
    } catch (_) {
      await _storage.clearTokens();
      status = SessionStatus.signedOut;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    error = null;
    notifyListeners();
    try {
      final result = await _dioFactory.api.login(email.trim(), password);
      await _storage.saveTokens(
        accessToken: result.access,
        refreshToken: result.refresh,
      );
      staff = result.staff;
      events = result.events;
      _selectEvent(null);
      status = SessionStatus.signedIn;
      notifyListeners();
      return true;
    } catch (e) {
      error = _message(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh != null) {
      try {
        await _dioFactory.api.logout(refresh);
      } catch (_) {}
    }
    await _storage.clearTokens();
    await _storage.setSelectedEventId(null);
    staff = null;
    events = const [];
    selectedEvent = null;
    status = SessionStatus.signedOut;
    notifyListeners();
  }

  Future<void> selectEvent(String eventId) async {
    _selectEvent(eventId);
    await _storage.setSelectedEventId(selectedEvent?.eventId);
    notifyListeners();
  }

  void _selectEvent(String? preferredId) {
    if (events.isEmpty) {
      selectedEvent = null;
      return;
    }
    if (preferredId != null) {
      for (final e in events) {
        if (e.eventId == preferredId) {
          selectedEvent = e;
          return;
        }
      }
    }
    selectedEvent = events.first;
  }

  String _message(Object e) {
    if (e is ApiException) return e.message;
    if (e is Exception) {
      final s = e.toString();
      if (s.contains('ApiException')) {
        return s.replaceFirst('Exception: ', '');
      }
    }
    final err = (e as dynamic).error;
    if (err is ApiException) return err.message;
    return 'Something went wrong. Please try again.';
  }
}
