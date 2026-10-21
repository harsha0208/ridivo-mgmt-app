import '../../core/models/staff_models.dart';

enum MemberStatus { queued, running, finished, dnf }

enum GroupStatus { staging, running, review, saving }

class TimingMember {
  TimingMember({
    required this.ticketId,
    required this.ticketNumber,
    this.holderName,
    required this.lapsIncluded,
    this.status = MemberStatus.queued,
    this.startedAtMs,
    this.finishedAtMs,
    this.durationMs,
    this.editedDurationMs,
    this.saveError,
  });

  final String ticketId;
  final String ticketNumber;
  final String? holderName;
  final int lapsIncluded;
  MemberStatus status;
  int? startedAtMs;
  int? finishedAtMs;
  int? durationMs;
  int? editedDurationMs;
  String? saveError;

  int? get effectiveDurationMs {
    if (status != MemberStatus.finished) return null;
    return editedDurationMs ?? durationMs;
  }

  factory TimingMember.fromTicket(VenueTicket t) {
    return TimingMember(
      ticketId: t.id,
      ticketNumber: t.ticketNumber,
      holderName: t.holderName,
      lapsIncluded: t.lapsIncluded,
    );
  }

  factory TimingMember.fromJson(Map<String, dynamic> json) {
    return TimingMember(
      ticketId: json['ticketId'] as String,
      ticketNumber: json['ticketNumber'] as String? ?? '',
      holderName: json['holderName'] as String?,
      lapsIncluded: (json['lapsIncluded'] as num?)?.toInt() ?? 0,
      status: MemberStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MemberStatus.queued,
      ),
      startedAtMs: (json['startedAtMs'] as num?)?.toInt(),
      finishedAtMs: (json['finishedAtMs'] as num?)?.toInt(),
      durationMs: (json['durationMs'] as num?)?.toInt(),
      editedDurationMs: (json['editedDurationMs'] as num?)?.toInt(),
      saveError: json['saveError'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'ticketId': ticketId,
        'ticketNumber': ticketNumber,
        'holderName': holderName,
        'lapsIncluded': lapsIncluded,
        'status': status.name,
        'startedAtMs': startedAtMs,
        'finishedAtMs': finishedAtMs,
        'durationMs': durationMs,
        'editedDurationMs': editedDurationMs,
        'saveError': saveError,
      };

  TimingMember copy() => TimingMember.fromJson(toJson());
}

class TimingGroup {
  TimingGroup({
    required this.id,
    this.name,
    List<TimingMember>? members,
    this.status = GroupStatus.staging,
  }) : members = members ?? [];

  final String id;
  String? name;
  List<TimingMember> members;
  GroupStatus status;

  bool get allDone =>
      members.isNotEmpty &&
      members.every(
        (m) => m.status == MemberStatus.finished || m.status == MemberStatus.dnf,
      );

  factory TimingGroup.create({String? name}) {
    return TimingGroup(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );
  }

  factory TimingGroup.fromJson(Map<String, dynamic> json) {
    return TimingGroup(
      id: json['id'] as String,
      name: json['name'] as String?,
      members: (json['members'] as List<dynamic>? ?? [])
          .map((e) => TimingMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: GroupStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => GroupStatus.staging,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'members': members.map((m) => m.toJson()).toList(),
        'status': status.name,
      };
}

class TimingGroupsState {
  TimingGroupsState({this.current, this.next});

  TimingGroup? current;
  TimingGroup? next;

  factory TimingGroupsState.empty() => TimingGroupsState();

  factory TimingGroupsState.fromJson(Map<String, dynamic> json) {
    return TimingGroupsState(
      current: json['current'] == null
          ? null
          : TimingGroup.fromJson(json['current'] as Map<String, dynamic>),
      next: json['next'] == null
          ? null
          : TimingGroup.fromJson(json['next'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'current': current?.toJson(),
        'next': next?.toJson(),
      };

  String? slotForTicket(String ticketId) {
    if (current?.members.any((m) => m.ticketId == ticketId) ?? false) {
      return 'current';
    }
    if (next?.members.any((m) => m.ticketId == ticketId) ?? false) {
      return 'next';
    }
    return null;
  }
}

String formatDurationMs(int ms) {
  final totalSec = ms < 0 ? 0.0 : ms / 1000.0;
  final mins = totalSec ~/ 60;
  final secs = totalSec - mins * 60;
  final secsStr = secs.toStringAsFixed(1).padLeft(4, '0');
  return '$mins:$secsStr';
}

/// Parse "m:ss.s" or plain seconds into ms.
int? parseDurationInput(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  if (trimmed.contains(':')) {
    final parts = trimmed.split(':');
    if (parts.length != 2) return null;
    final mins = double.tryParse(parts[0]);
    final secs = double.tryParse(parts[1]);
    if (mins == null || secs == null) return null;
    return ((mins * 60 + secs) * 1000).round();
  }
  final secs = double.tryParse(trimmed);
  if (secs == null || secs < 0) return null;
  return (secs * 1000).round();
}
