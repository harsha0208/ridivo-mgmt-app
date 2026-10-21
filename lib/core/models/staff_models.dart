enum StaffRole {
  checkin,
  seller,
  timing,
  manager,
  unknown;

  static StaffRole fromString(String? raw) {
    switch (raw) {
      case 'checkin':
        return StaffRole.checkin;
      case 'seller':
        return StaffRole.seller;
      case 'timing':
        return StaffRole.timing;
      case 'manager':
        return StaffRole.manager;
      default:
        return StaffRole.unknown;
    }
  }

  bool get canCheckin => this == StaffRole.checkin || this == StaffRole.manager;
  bool get canTiming => this == StaffRole.timing || this == StaffRole.manager;
  bool get isSellerOnly => this == StaffRole.seller;
}

class StaffInfo {
  const StaffInfo({
    required this.id,
    required this.email,
    required this.fullName,
  });

  final String id;
  final String email;
  final String fullName;

  factory StaffInfo.fromJson(Map<String, dynamic> json) {
    return StaffInfo(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? '',
    );
  }
}

class EventAssignment {
  const EventAssignment({
    required this.eventId,
    required this.role,
    required this.eventTitle,
  });

  final String eventId;
  final StaffRole role;
  final String eventTitle;

  factory EventAssignment.fromJson(Map<String, dynamic> json) {
    return EventAssignment(
      eventId: json['event_id'] as String,
      role: StaffRole.fromString(json['role'] as String?),
      eventTitle: json['event_title'] as String? ?? 'Event',
    );
  }
}

class VenueTicket {
  const VenueTicket({
    required this.id,
    required this.ticketNumber,
    required this.status,
    required this.passProductId,
    required this.lapsIncluded,
    this.holderPhone,
    this.holderName,
    this.checkedInAt,
  });

  final String id;
  final String ticketNumber;
  final String status;
  final String passProductId;
  final int lapsIncluded;
  final String? holderPhone;
  final String? holderName;
  final String? checkedInAt;

  bool get isChallenge => lapsIncluded > 0;

  factory VenueTicket.fromJson(Map<String, dynamic> json) {
    return VenueTicket(
      id: json['id'] as String,
      ticketNumber: json['ticket_number'] as String? ?? '',
      status: json['status'] as String? ?? '',
      passProductId: json['pass_product_id'] as String? ?? '',
      lapsIncluded: (json['laps_included'] as num?)?.toInt() ?? 0,
      holderPhone: json['holder_phone'] as String?,
      holderName: json['holder_name'] as String?,
      checkedInAt: json['checked_in_at'] as String?,
    );
  }
}

class ScanResult {
  const ScanResult({
    required this.result,
    this.message,
    this.ticket,
    this.checkinId,
    this.priorCheckinCount = 0,
  });

  final String result;
  final String? message;
  final VenueTicket? ticket;
  final String? checkinId;
  final int priorCheckinCount;

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final ticketJson = json['ticket'] as Map<String, dynamic>?;
    return ScanResult(
      result: json['result'] as String? ?? 'invalid',
      message: json['message'] as String?,
      ticket: ticketJson == null ? null : VenueTicket.fromJson(ticketJson),
      checkinId: json['checkin_id'] as String?,
      priorCheckinCount: (json['prior_checkin_count'] as num?)?.toInt() ?? 0,
    );
  }
}

class TimingSession {
  const TimingSession({
    required this.id,
    required this.ticketId,
    required this.status,
    this.startedAt,
    this.finishedAt,
    this.durationMs,
  });

  final String id;
  final String ticketId;
  final String status;
  final String? startedAt;
  final String? finishedAt;
  final int? durationMs;

  factory TimingSession.fromJson(Map<String, dynamic> json) {
    return TimingSession(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      startedAt: json['started_at'] as String?,
      finishedAt: json['finished_at'] as String?,
      durationMs: (json['duration_ms'] as num?)?.toInt(),
    );
  }
}
