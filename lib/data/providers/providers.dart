import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/session_constants.dart';
import '../../core/monitoring/error_reporter.dart';
import '../../core/storage/session_storage.dart';
import '../models/connection_status.dart';
import '../models/models.dart';
import '../repositories/room_repository.dart';

final roomRepositoryProvider = Provider<RoomRepository>((ref) {
  final repo = RoomRepository();
  ref.onDispose(repo.dispose);
  return repo;
});

final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  return ref.watch(roomRepositoryProvider).connectionStatusStream;
});

final sessionProvider =
    AsyncNotifierProvider<SessionNotifier, SessionData?>(SessionNotifier.new);

class SessionData {
  const SessionData({
    required this.roomId,
    required this.participantId,
    required this.code,
    this.nickname,
    this.roomName,
  });

  final String roomId;
  final String participantId;
  final String code;
  final String? nickname;
  final String? roomName;
}

class SessionNotifier extends AsyncNotifier<SessionData?> {
  @override
  Future<SessionData?> build() async {
    final saved = await SessionStorage.loadSession();
    if (saved == null) return null;
    return SessionData(
      roomId: saved.roomId,
      participantId: saved.participantId,
      code: saved.roomCode ?? '',
      nickname: saved.nickname,
      roomName: saved.roomName,
    );
  }

  Future<void> saveSession(
    SessionResult result, {
    String? nickname,
    String? roomName,
  }) async {
    await SessionStorage.saveSession(
      participantId: result.participantId,
      roomId: result.roomId,
      nickname: nickname,
      roomCode: result.code,
      roomName: roomName,
    );
    state = AsyncData(
      SessionData(
        roomId: result.roomId,
        participantId: result.participantId,
        code: result.code,
        nickname: nickname,
        roomName: roomName,
      ),
    );
  }

  Future<void> updateRoomMetadata({
    required String roomName,
    String? roomCode,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await SessionStorage.saveSession(
      participantId: current.participantId,
      roomId: current.roomId,
      nickname: current.nickname,
      roomCode: roomCode ?? current.code,
      roomName: roomName,
    );
    state = AsyncData(
      SessionData(
        roomId: current.roomId,
        participantId: current.participantId,
        code: roomCode ?? current.code,
        nickname: current.nickname,
        roomName: roomName,
      ),
    );
  }

  Future<void> clearSession() async {
    await SessionStorage.clearSession();
    state = const AsyncData(null);
  }
}

final roomStateProvider =
    AsyncNotifierProvider<RoomStateNotifier, RoomState?>(RoomStateNotifier.new);

class RoomStateNotifier extends AsyncNotifier<RoomState?> {
  RoomRepository get _repo => ref.read(roomRepositoryProvider);
  Timer? _heartbeatTimer;
  StreamSubscription<RoomState>? _roomSubscription;
  bool _castVoteInFlight = false;

  @override
  Future<RoomState?> build() async {
    ref.onDispose(() {
      _heartbeatTimer?.cancel();
      _roomSubscription?.cancel();
      _repo.unsubscribe();
    });
    return null;
  }

  Future<void> enterRoom(String roomId, String participantId) async {
    state = const AsyncLoading();
    try {
      await _roomSubscription?.cancel();
      _repo.subscribeToRoom(roomId);
      final roomState = await _repo.fetchRoomState(roomId);
      state = AsyncData(roomState);

      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(
        const Duration(seconds: SessionConstants.heartbeatIntervalSeconds),
        (_) => _repo.heartbeat(participantId: participantId),
      );

      _roomSubscription = _repo.roomStateStream.listen((updated) {
        state = AsyncData(updated);
      });
    } catch (e, st) {
      await ErrorReporter.capture(
        e,
        stackTrace: st,
        tags: const {'flow': 'enter_room'},
      );
      state = AsyncError(e, st);
    }
  }

  /// Applies vote locally, then RPC with retry; rolls back on failure.
  Future<void> castVoteOptimistic({
    required String participantId,
    required String storyId,
    required String value,
  }) async {
    final current = state.valueOrNull;
    if (current == null || _castVoteInFlight) return;

    final previous = current;
    final optimisticVotes = _upsertVote(
      current.votes,
      participantId: participantId,
      storyId: storyId,
      value: value,
    );
    state = AsyncData(current.copyWith(votes: optimisticVotes));
    _castVoteInFlight = true;

    try {
      await _repo.castVote(
        participantId: participantId,
        storyId: storyId,
        value: value,
      );
    } catch (e, st) {
      state = AsyncData(previous);
      ErrorReporter.breadcrumbRpcFailure('cast_vote', e);
      await ErrorReporter.capture(
        e,
        stackTrace: st,
        tags: const {'action': 'cast_vote'},
        roomPhase: current.room.phase.name,
        isFacilitator: ref.read(isFacilitatorProvider),
      );
      rethrow;
    } finally {
      _castVoteInFlight = false;
    }
  }

  List<Vote> _upsertVote(
    List<Vote> votes, {
    required String participantId,
    required String storyId,
    required String value,
  }) {
    final index = votes.indexWhere(
      (v) => v.participantId == participantId && v.storyId == storyId,
    );
    final now = DateTime.now().toUtc();
    if (index >= 0) {
      final existing = votes[index];
      final updated = List<Vote>.from(votes);
      updated[index] = Vote(
        id: existing.id,
        storyId: storyId,
        participantId: participantId,
        value: value,
        votedAt: now,
      );
      return updated;
    }
    return [
      ...votes,
      Vote(
        id: 'optimistic-$participantId-$storyId',
        storyId: storyId,
        participantId: participantId,
        value: value,
        votedAt: now,
      ),
    ];
  }

  Future<void> refresh() async {
    if (state.valueOrNull == null) return;
    await _repo.refreshSubscribedRoom();
  }

  void leaveRoom() {
    _heartbeatTimer?.cancel();
    _roomSubscription?.cancel();
    _roomSubscription = null;
    _repo.unsubscribe();
    state = const AsyncData(null);
  }
}

final currentParticipantProvider = Provider<Participant?>((ref) {
  final session = ref.watch(sessionProvider).valueOrNull;
  final roomState = ref.watch(roomStateProvider).valueOrNull;
  if (session == null || roomState == null) return null;
  try {
    return roomState.participants.firstWhere(
      (p) => p.id == session.participantId,
    );
  } catch (_) {
    return null;
  }
});

final isFacilitatorProvider = Provider<bool>((ref) {
  return ref.watch(currentParticipantProvider)?.isFacilitator ?? false;
});
