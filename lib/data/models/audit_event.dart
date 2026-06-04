class AuditEvent {
  const AuditEvent({
    required this.id,
    required this.kind,
    required this.summary,
    required this.createdAt,
    this.participantId,
    this.actorUserId,
    this.actorDisplayName,
    this.metadata = const {},
  });

  final String id;
  final String kind;
  final String summary;
  final DateTime createdAt;
  final String? participantId;
  final String? actorUserId;
  final String? actorDisplayName;
  final Map<String, dynamic> metadata;

  factory AuditEvent.fromJson(Map<String, dynamic> json) {
    return AuditEvent(
      id: json['id'] as String,
      kind: json['kind'] as String,
      summary: json['summary'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      participantId: json['participant_id'] as String?,
      actorUserId: json['actor_user_id'] as String?,
      actorDisplayName: json['actor_display_name'] as String?,
      metadata: Map<String, dynamic>.from(
        json['metadata'] as Map? ?? {},
      ),
    );
  }
}

class OpsHealthSnapshot {
  const OpsHealthSnapshot({
    required this.checkedAt,
    required this.activeRooms1h,
    required this.activeRooms24h,
    required this.auditEvents24h,
    required this.externalLinksTotal,
    required this.storiesDone24h,
  });

  final DateTime checkedAt;
  final int activeRooms1h;
  final int activeRooms24h;
  final int auditEvents24h;
  final int externalLinksTotal;
  final int storiesDone24h;

  factory OpsHealthSnapshot.fromJson(Map<String, dynamic> json) {
    return OpsHealthSnapshot(
      checkedAt: DateTime.parse(json['checked_at'] as String),
      activeRooms1h: json['active_rooms_1h'] as int? ?? 0,
      activeRooms24h: json['active_rooms_24h'] as int? ?? 0,
      auditEvents24h: json['audit_events_24h'] as int? ?? 0,
      externalLinksTotal: json['external_links_total'] as int? ?? 0,
      storiesDone24h: json['stories_done_24h'] as int? ?? 0,
    );
  }
}
