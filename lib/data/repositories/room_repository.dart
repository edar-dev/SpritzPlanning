import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/network/rpc_retry.dart';
import '../models/connection_status.dart';
import '../models/models.dart';
import '../supabase/supabase_client.dart';
import 'realtime_connection_manager.dart';

class RoomRepository {
  RoomRepository({RealtimeConnectionManager? connectionManager})
      : _connectionManager =
            connectionManager ?? RealtimeConnectionManager();

  final RealtimeConnectionManager _connectionManager;
  final _controller = StreamController<RoomState>.broadcast();
  String? _subscribedRoomId;

  Stream<RoomState> get roomStateStream => _controller.stream;

  Stream<ConnectionStatus> get connectionStatusStream =>
      _connectionManager.connectionStatusStream;

  Future<SessionResult> createRoom({
    required String name,
    required String nickname,
    String? pin,
  }) async {
    final response = await supabase.rpc(
      'create_room',
      params: {
        'p_name': name,
        'p_nickname': nickname,
        if (pin != null && pin.isNotEmpty) 'p_pin': pin,
      },
    );
    return SessionResult.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<SessionResult> joinRoom({
    required String code,
    required String nickname,
    bool observer = false,
    String? pin,
  }) async {
    final response = await supabase.rpc(
      'join_room',
      params: {
        'p_code': code.trim(),
        'p_nickname': nickname,
        'p_observer': observer,
        if (pin != null && pin.isNotEmpty) 'p_pin': pin,
      },
    );
    return SessionResult.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<RoomJoinInfo> getRoomJoinInfo(String code) async {
    final response = await supabase.rpc(
      'get_room_join_info',
      params: {'p_code': code.trim()},
    );
    final map = Map<String, dynamic>.from(response as Map);
    return RoomJoinInfo(
      requiresPin: map['requires_pin'] as bool? ?? false,
      roomName: map['room_name'] as String? ?? '',
    );
  }

  Future<SessionResult> duplicateRoom({
    required String participantId,
    required String sourceRoomId,
  }) async {
    final response = await supabase.rpc(
      'duplicate_room',
      params: {
        'p_participant_id': participantId,
        'p_source_room_id': sourceRoomId,
      },
    );
    return SessionResult.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<void> markStorySpike({
    required String participantId,
    required String storyId,
  }) async {
    await supabase.rpc(
      'mark_story_spike',
      params: {
        'p_participant_id': participantId,
        'p_story_id': storyId,
      },
    );
  }

  Future<void> setRoomSettings({
    required String participantId,
    required bool autoRevealWhenAllVoted,
  }) async {
    await supabase.rpc(
      'set_room_settings',
      params: {
        'p_participant_id': participantId,
        'p_auto_reveal_when_all_voted': autoRevealWhenAllVoted,
      },
    );
  }

  Future<void> setRoomPin({
    required String participantId,
    String? pin,
  }) async {
    await supabase.rpc(
      'set_room_pin',
      params: {
        'p_participant_id': participantId,
        'p_pin': pin ?? '',
      },
    );
  }

  Future<RoomState> fetchRoomState(String roomId) async {
    final roomData = await supabase
        .from('rooms')
        .select()
        .eq('id', roomId)
        .single();

    final participantsData = await supabase
        .from('participants')
        .select()
        .eq('room_id', roomId)
        .order('joined_at');

    final storiesData = await supabase
        .from('stories')
        .select()
        .eq('room_id', roomId)
        .order('sort_order');

    final room = Room.fromJson(Map<String, dynamic>.from(roomData));
    final participants = (participantsData as List)
        .map((e) => Participant.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final stories = (storiesData as List)
        .map((e) => Story.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    List<Vote> votes = [];
    if (room.currentStoryId != null) {
      final votesData = await supabase
          .from('votes')
          .select()
          .eq('story_id', room.currentStoryId!);
      votes = (votesData as List)
          .map((e) => Vote.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return RoomState(
      room: room,
      participants: participants,
      stories: stories,
      votes: votes,
    );
  }

  void subscribeToRoom(String roomId) {
    unsubscribe();
    _subscribedRoomId = roomId;
    _connectionManager.subscribe(
      roomId: roomId,
      onStateRefresh: () => _refreshAndEmit(roomId),
    );
  }

  Future<void> _refreshAndEmit(String roomId) async {
    try {
      final state = await fetchRoomState(roomId);
      if (!_controller.isClosed) {
        _controller.add(state);
      }
    } catch (e) {
      debugPrint('Errore refresh room: $e');
      rethrow;
    }
  }

  Future<void> refreshSubscribedRoom() async {
    final roomId = _subscribedRoomId;
    if (roomId == null) return;
    await _connectionManager.manualRefresh();
  }

  void unsubscribe() {
    _subscribedRoomId = null;
    _connectionManager.unsubscribe();
  }

  void dispose() {
    unsubscribe();
    _connectionManager.dispose();
    _controller.close();
  }

  Future<String> addStory({
    required String participantId,
    required String title,
    String description = '',
  }) async {
    return await supabase.rpc(
          'add_story',
          params: {
            'p_participant_id': participantId,
            'p_title': title,
            'p_description': description,
          },
        )
        as String;
  }

  Future<int> addStories({
    required String participantId,
    required List<String> titles,
  }) async {
    final response = await supabase.rpc(
      'add_stories',
      params: {
        'p_participant_id': participantId,
        'p_titles': titles,
      },
    );
    return response as int;
  }

  Future<void> removeStory({
    required String participantId,
    required String storyId,
  }) async {
    await supabase.rpc(
      'remove_story',
      params: {
        'p_participant_id': participantId,
        'p_story_id': storyId,
      },
    );
  }

  Future<void> startVoting({
    required String participantId,
    required String storyId,
    int? durationSeconds,
  }) async {
    await supabase.rpc(
      'start_voting',
      params: {
        'p_participant_id': participantId,
        'p_story_id': storyId,
        if (durationSeconds != null) 'p_duration_seconds': durationSeconds,
      },
    );
  }

  Future<void> castVote({
    required String participantId,
    required String storyId,
    required String value,
  }) async {
    await withRpcRetry(
      () => supabase.rpc(
        'cast_vote',
        params: {
          'p_participant_id': participantId,
          'p_story_id': storyId,
          'p_value': value,
        },
      ),
    );
  }

  Future<void> revealVotes({required String participantId}) async {
    await supabase.rpc(
      'reveal_votes',
      params: {'p_participant_id': participantId},
    );
  }

  Future<void> resetVotes({required String participantId}) async {
    await supabase.rpc(
      'reset_votes',
      params: {'p_participant_id': participantId},
    );
  }

  Future<void> setFinalEstimate({
    required String participantId,
    required String storyId,
    required String estimate,
  }) async {
    await supabase.rpc(
      'set_final_estimate',
      params: {
        'p_participant_id': participantId,
        'p_story_id': storyId,
        'p_estimate': estimate,
      },
    );
  }

  Future<void> nextStory({required String participantId}) async {
    await supabase.rpc(
      'next_story',
      params: {'p_participant_id': participantId},
    );
  }

  Future<void> heartbeat({required String participantId}) async {
    await supabase.rpc(
      'heartbeat',
      params: {'p_participant_id': participantId},
    );
  }

  /// Marks the participant as left so the same nickname can re-join immediately.
  Future<void> leaveRoom({required String participantId}) async {
    await supabase.rpc(
      'leave_room',
      params: {'p_participant_id': participantId},
    );
  }

  Future<void> transferFacilitator({
    required String fromParticipantId,
    required String toParticipantId,
  }) async {
    await supabase.rpc(
      'transfer_facilitator',
      params: {
        'p_from_participant_id': fromParticipantId,
        'p_to_participant_id': toParticipantId,
      },
    );
  }

  Future<void> updateStory({
    required String participantId,
    required String storyId,
    required String title,
    String description = '',
    String? facilitatorNote,
  }) async {
    await supabase.rpc(
      'update_story',
      params: {
        'p_participant_id': participantId,
        'p_story_id': storyId,
        'p_title': title,
        'p_description': description,
        if (facilitatorNote != null) 'p_facilitator_note': facilitatorNote,
      },
    );
  }

  Future<void> reorderStories({
    required String participantId,
    required List<String> storyIds,
  }) async {
    await supabase.rpc(
      'reorder_stories',
      params: {
        'p_participant_id': participantId,
        'p_story_ids': storyIds,
      },
    );
  }

  Future<void> removeParticipant({
    required String barmanId,
    required String targetId,
  }) async {
    await supabase.rpc(
      'remove_participant',
      params: {
        'p_barman_id': barmanId,
        'p_target_id': targetId,
      },
    );
  }

  Future<void> setRoomDeck({
    required String participantId,
    required List<String> deckValues,
    required bool allowCoffeeBreak,
  }) async {
    await supabase.rpc(
      'set_room_deck',
      params: {
        'p_participant_id': participantId,
        'p_deck_values': deckValues,
        'p_allow_coffee_break': allowCoffeeBreak,
      },
    );
  }
}
