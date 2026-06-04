enum RoomPhase { lobby, voting, revealed }

enum StoryStatus { pending, voting, revealed, done }

enum StoryKind { story, spike }

enum ParticipantRole { facilitator, editor, viewer }

extension ParticipantRoleX on ParticipantRole {
  String get dbValue => name;

  static ParticipantRole fromDb(String? value) {
    return ParticipantRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ParticipantRole.editor,
    );
  }
}

extension StoryKindX on StoryKind {
  String get dbValue => name;

  static StoryKind fromDb(String value) {
    return StoryKind.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StoryKind.story,
    );
  }
}

extension RoomPhaseX on RoomPhase {
  String get dbValue => name;

  static RoomPhase fromDb(String value) {
    return RoomPhase.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RoomPhase.lobby,
    );
  }
}

extension StoryStatusX on StoryStatus {
  String get dbValue => name;

  static StoryStatus fromDb(String value) {
    return StoryStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => StoryStatus.pending,
    );
  }
}

class Room {
  const Room({
    required this.id,
    required this.code,
    required this.name,
    required this.phase,
    this.currentStoryId,
    required this.votesRevealed,
    this.votingDeadlineAt,
    required this.deckValues,
    required this.allowCoffeeBreak,
    required this.autoRevealWhenAllVoted,
    required this.hideVotersUntilReveal,
    required this.confidenceRoundActive,
    required this.lastActivityAt,
    required this.createdAt,
    this.workspaceName,
    this.brandColor,
  });

  final String id;
  final String code;
  final String name;
  final RoomPhase phase;
  final String? currentStoryId;
  final bool votesRevealed;
  final DateTime? votingDeadlineAt;
  final List<String> deckValues;
  final bool allowCoffeeBreak;
  final bool autoRevealWhenAllVoted;
  final bool hideVotersUntilReveal;
  final bool confidenceRoundActive;
  final DateTime lastActivityAt;
  final DateTime createdAt;
  final String? workspaceName;
  final String? brandColor;

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      phase: RoomPhaseX.fromDb(json['phase'] as String),
      currentStoryId: json['current_story_id'] as String?,
      votesRevealed: json['votes_revealed'] as bool? ?? false,
      votingDeadlineAt: json['voting_deadline_at'] != null
          ? DateTime.parse(json['voting_deadline_at'] as String)
          : null,
      deckValues: _parseDeckValues(json['deck_values']),
      allowCoffeeBreak: json['allow_coffee_break'] as bool? ?? true,
      autoRevealWhenAllVoted:
          json['auto_reveal_when_all_voted'] as bool? ?? false,
      hideVotersUntilReveal:
          json['hide_voters_until_reveal'] as bool? ?? false,
      confidenceRoundActive:
          json['confidence_round_active'] as bool? ?? false,
      lastActivityAt: DateTime.parse(json['last_activity_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      workspaceName: json['workspace_name'] as String?,
      brandColor: json['brand_color'] as String?,
    );
  }
}

List<String> _parseDeckValues(dynamic raw) {
  if (raw is List) {
    return raw.map((e) => e.toString()).toList();
  }
  return const ['0', '½', '1', '2', '3', '5', '8', '13', '21', '?', '☕'];
}

class Participant {
  const Participant({
    required this.id,
    required this.roomId,
    required this.nickname,
    required this.isFacilitator,
    required this.isObserver,
    required this.role,
    required this.joinedAt,
    required this.lastSeenAt,
  });

  final String id;
  final String roomId;
  final String nickname;
  final bool isFacilitator;
  final bool isObserver;
  final ParticipantRole role;
  final DateTime joinedAt;
  final DateTime lastSeenAt;

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      nickname: json['nickname'] as String,
      isFacilitator: json['is_facilitator'] as bool? ?? false,
      isObserver: json['is_observer'] as bool? ?? false,
      role: _parseRole(json),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      lastSeenAt: DateTime.parse(json['last_seen_at'] as String),
    );
  }

  static ParticipantRole _parseRole(Map<String, dynamic> json) {
    final roleRaw = json['role'] as String?;
    if (roleRaw != null && roleRaw.trim().isNotEmpty) {
      return ParticipantRoleX.fromDb(roleRaw);
    }
    final isFacilitator = json['is_facilitator'] as bool? ?? false;
    final isObserver = json['is_observer'] as bool? ?? false;
    if (isFacilitator) return ParticipantRole.facilitator;
    if (isObserver) return ParticipantRole.viewer;
    return ParticipantRole.editor;
  }

  bool isAbsent({required DateTime now, int thresholdSeconds = 120}) {
    return now.difference(lastSeenAt).inSeconds > thresholdSeconds;
  }

  bool get canModerateSession => role == ParticipantRole.facilitator;
  bool get canEditBacklog =>
      role == ParticipantRole.facilitator || role == ParticipantRole.editor;
  bool get canVote => role != ParticipantRole.viewer;
}

class EstimateHistoryEntry {
  const EstimateHistoryEntry({
    required this.estimate,
    required this.at,
    required this.kind,
  });

  final String estimate;
  final DateTime at;
  final String kind;

  factory EstimateHistoryEntry.fromJson(Map<String, dynamic> json) {
    return EstimateHistoryEntry(
      estimate: json['estimate'] as String? ?? '',
      at: _parseEstimateAt(json['at']),
      kind: json['kind'] as String? ?? 'final',
    );
  }

  static DateTime _parseEstimateAt(dynamic value) {
    if (value is String) return DateTime.parse(value);
    return DateTime.now().toUtc();
  }
}

class Story {
  const Story({
    required this.id,
    required this.roomId,
    required this.title,
    required this.description,
    required this.sortOrder,
    required this.status,
    required this.kind,
    this.finalEstimate,
    required this.facilitatorNote,
    required this.publicComment,
    required this.isReference,
    required this.estimateHistory,
    required this.createdAt,
  });

  final String id;
  final String roomId;
  final String title;
  final String description;
  final int sortOrder;
  final StoryStatus status;
  final StoryKind kind;
  final String? finalEstimate;
  final String facilitatorNote;
  final String publicComment;
  final bool isReference;
  final List<EstimateHistoryEntry> estimateHistory;
  final DateTime createdAt;

  bool get isSpike => kind == StoryKind.spike;

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as String,
      roomId: json['room_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      sortOrder: json['sort_order'] as int? ?? 0,
      status: StoryStatusX.fromDb(json['status'] as String),
      kind: StoryKindX.fromDb(json['kind'] as String? ?? 'story'),
      finalEstimate: json['final_estimate'] as String?,
      facilitatorNote: json['facilitator_note'] as String? ?? '',
      publicComment: json['public_comment'] as String? ?? '',
      isReference: json['is_reference'] as bool? ?? false,
      estimateHistory: _parseEstimateHistory(json['estimate_history']),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static List<EstimateHistoryEntry> _parseEstimateHistory(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .map(
          (e) => EstimateHistoryEntry.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }
}

class ConfidenceVote {
  const ConfidenceVote({
    required this.storyId,
    required this.participantId,
    required this.value,
  });

  final String storyId;
  final String participantId;
  final int value;

  factory ConfidenceVote.fromJson(Map<String, dynamic> json) {
    return ConfidenceVote(
      storyId: json['story_id'] as String,
      participantId: json['participant_id'] as String,
      value: json['value'] as int,
    );
  }
}

class Vote {
  const Vote({
    required this.id,
    required this.storyId,
    required this.participantId,
    this.value,
    required this.votedAt,
  });

  final String id;
  final String storyId;
  final String participantId;
  final String? value;
  final DateTime votedAt;

  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'] as String,
      storyId: json['story_id'] as String,
      participantId: json['participant_id'] as String,
      value: json['value'] as String?,
      votedAt: DateTime.parse(json['voted_at'] as String),
    );
  }
}

class RoomJoinInfo {
  const RoomJoinInfo({
    required this.requiresPin,
    required this.roomName,
  });

  final bool requiresPin;
  final String roomName;
}

class SessionResult {
  const SessionResult({
    required this.roomId,
    required this.participantId,
    required this.code,
  });

  final String roomId;
  final String participantId;
  final String code;

  factory SessionResult.fromJson(Map<String, dynamic> json) {
    return SessionResult(
      roomId: json['room_id'] as String,
      participantId: json['participant_id'] as String,
      code: json['code'] as String,
    );
  }
}

class RoomState {
  const RoomState({
    required this.room,
    required this.participants,
    required this.stories,
    required this.votes,
    this.confidenceVotes = const [],
  });

  final Room room;
  final List<Participant> participants;
  final List<Story> stories;
  final List<Vote> votes;
  final List<ConfidenceVote> confidenceVotes;

  Story? get currentStory {
    final id = room.currentStoryId;
    if (id == null) return null;
    try {
      return stories.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Vote> get currentVotes {
    final id = room.currentStoryId;
    if (id == null) return [];
    return votes.where((v) => v.storyId == id).toList();
  }

  bool hasParticipantVoted(String participantId) {
    return currentVotes.any(
      (v) => v.participantId == participantId && v.value != null,
    );
  }

  /// Active voters who must cast a ballot (excludes observers and AFK).
  List<Participant> get activeVotingParticipants {
    final now = DateTime.now();
    return participants
        .where((p) => !p.isObserver && !p.isAbsent(now: now))
        .toList();
  }

  bool get allParticipantsVoted => allActiveVotingParticipantsVoted;

  bool get allActiveVotingParticipantsVoted {
    if (room.currentStoryId == null) return false;
    final voters = activeVotingParticipants;
    if (voters.isEmpty) return false;
    return voters.every((p) => hasParticipantVoted(p.id));
  }

  (int voted, int total) get votingProgress {
    final voters = activeVotingParticipants;
    if (voters.isEmpty) return (0, 0);
    final voted = voters.where((p) => hasParticipantVoted(p.id)).length;
    return (voted, voters.length);
  }

  Story? get referenceStory {
    try {
      return stories.firstWhere((s) => s.isReference);
    } catch (_) {
      return null;
    }
  }

  List<ConfidenceVote> get currentConfidenceVotes {
    final id = room.currentStoryId;
    if (id == null) return [];
    return confidenceVotes.where((v) => v.storyId == id).toList();
  }

  (int voted, int total) get confidenceProgress {
    final voters = activeVotingParticipants;
    if (voters.isEmpty) return (0, 0);
    final voted = voters
        .where(
          (p) => currentConfidenceVotes.any((c) => c.participantId == p.id),
        )
        .length;
    return (voted, voters.length);
  }

  RoomState copyWith({
    Room? room,
    List<Participant>? participants,
    List<Story>? stories,
    List<Vote>? votes,
    List<ConfidenceVote>? confidenceVotes,
  }) {
    return RoomState(
      room: room ?? this.room,
      participants: participants ?? this.participants,
      stories: stories ?? this.stories,
      votes: votes ?? this.votes,
      confidenceVotes: confidenceVotes ?? this.confidenceVotes,
    );
  }
}
