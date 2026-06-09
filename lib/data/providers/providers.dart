import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/session_constants.dart';
import '../../core/monitoring/error_reporter.dart';
import '../../core/network/rpc_retry.dart';
import '../../core/network/vote_outbox.dart';
import '../../core/storage/session_storage.dart';
import '../models/connection_status.dart';
import '../models/models.dart';
import '../repositories/room_repository.dart';

enum VoteOutboxBannerState { hidden, pending, synced }

final voteOutboxBannerProvider =
    StateProvider<VoteOutboxBannerState>((ref) => VoteOutboxBannerState.hidden);

final voteOutboxPendingCountProvider = StateProvider<int>((ref) => 0);

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

      await syncPendingVotes(participantId);
    } catch (e, st) {
      await ErrorReporter.capture(
        e,
        stackTrace: st,
        tags: const {'flow': 'enter_room'},
      );
      state = AsyncError(e, st);
    }
  }

  /// Applies vote locally, then RPC; queues on transient failure (#126).
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
      await VoteOutbox.remove(
        participantId: participantId,
        storyId: storyId,
      );
      await _refreshOutboxUi(participantId);
      await syncPendingVotes(participantId);
    } catch (e, st) {
      if (isRetryableRpcError(e)) {
        await VoteOutbox.enqueue(
          VoteOutboxEntry(
            participantId: participantId,
            storyId: storyId,
            value: value,
            enqueuedAt: DateTime.now().toUtc(),
          ),
        );
        await _refreshOutboxUi(participantId);
        ref.read(voteOutboxBannerProvider.notifier).state =
            VoteOutboxBannerState.pending;
        return;
      }
      await VoteOutbox.remove(
        participantId: participantId,
        storyId: storyId,
      );
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

  Future<void> syncPendingVotes(String participantId) async {
    final pending = await VoteOutbox.loadForParticipant(participantId);
    if (pending.isEmpty) {
      await _refreshOutboxUi(participantId);
      return;
    }

    ref.read(voteOutboxBannerProvider.notifier).state =
        VoteOutboxBannerState.pending;

    for (final entry in pending) {
      try {
        await _repo.castVote(
          participantId: entry.participantId,
          storyId: entry.storyId,
          value: entry.value,
        );
        await VoteOutbox.remove(
          participantId: entry.participantId,
          storyId: entry.storyId,
        );
      } catch (e, st) {
        if (isRetryableRpcError(e)) {
          await _refreshOutboxUi(participantId);
          return;
        }
        await VoteOutbox.remove(
          participantId: entry.participantId,
          storyId: entry.storyId,
        );
        ErrorReporter.breadcrumbRpcFailure('cast_vote_outbox', e);
        await ErrorReporter.capture(
          e,
          stackTrace: st,
          tags: const {'action': 'cast_vote_outbox'},
        );
      }
    }

    final remaining = await VoteOutbox.loadForParticipant(participantId);
    await _refreshOutboxUi(participantId);
    if (remaining.isEmpty) {
      ref.read(voteOutboxBannerProvider.notifier).state =
          VoteOutboxBannerState.synced;
    }
  }

  Future<void> _refreshOutboxUi(String participantId) async {
    final pending = await VoteOutbox.loadForParticipant(participantId);
    ref.read(voteOutboxPendingCountProvider.notifier).state = pending.length;
    if (pending.isEmpty &&
        ref.read(voteOutboxBannerProvider) == VoteOutboxBannerState.pending) {
      ref.read(voteOutboxBannerProvider.notifier).state =
          VoteOutboxBannerState.hidden;
    }
  }

  void clearVoteOutboxBanner() {
    ref.read(voteOutboxBannerProvider.notifier).state =
        VoteOutboxBannerState.hidden;
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
    final session = ref.read(sessionProvider).valueOrNull;
    if (session != null) {
      await syncPendingVotes(session.participantId);
    }
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
  return ref.watch(canModerateSessionProvider);
});

final currentParticipantRoleProvider = Provider<ParticipantRole>((ref) {
  return ref.watch(currentParticipantProvider)?.role ?? ParticipantRole.editor;
});

final canModerateSessionProvider = Provider<bool>((ref) {
  return ref.watch(currentParticipantProvider)?.canModerateSession ?? false;
});

final canEditBacklogProvider = Provider<bool>((ref) {
  return ref.watch(currentParticipantProvider)?.canEditBacklog ?? false;
});
