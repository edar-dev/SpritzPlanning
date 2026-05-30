import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  });

  final String roomId;
  final String participantId;
  final String code;
}

class SessionNotifier extends AsyncNotifier<SessionData?> {
  @override
  Future<SessionData?> build() async {
    final saved = await SessionStorage.loadSession();
    if (saved == null) return null;
    return SessionData(
      roomId: saved.roomId,
      participantId: saved.participantId,
      code: '',
    );
  }

  Future<void> saveSession(SessionResult result) async {
    await SessionStorage.saveSession(
      participantId: result.participantId,
      roomId: result.roomId,
    );
    state = AsyncData(
      SessionData(
        roomId: result.roomId,
        participantId: result.participantId,
        code: result.code,
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
        const Duration(seconds: 30),
        (_) => _repo.heartbeat(participantId: participantId),
      );

      _roomSubscription = _repo.roomStateStream.listen((updated) {
        state = AsyncData(updated);
      });
    } catch (e, st) {
      state = AsyncError(e, st);
    }
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
