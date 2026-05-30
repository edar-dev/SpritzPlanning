import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/models.dart';
import '../supabase/supabase_client.dart';

class RoomRepository {
  RealtimeChannel? _channel;
  final _controller = StreamController<RoomState>.broadcast();

  Stream<RoomState> get roomStateStream => _controller.stream;

  Future<SessionResult> createRoom({
    required String name,
    required String nickname,
  }) async {
    final response = await supabase.rpc(
      'create_room',
      params: {'p_name': name, 'p_nickname': nickname},
    );
    return SessionResult.fromJson(Map<String, dynamic>.from(response as Map));
  }

  Future<SessionResult> joinRoom({
    required String code,
    required String nickname,
  }) async {
    final response = await supabase.rpc(
      'join_room',
      params: {'p_code': code.trim(), 'p_nickname': nickname},
    );
    return SessionResult.fromJson(Map<String, dynamic>.from(response as Map));
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
    _refreshAndEmit(roomId);

    _channel = supabase
        .channel('room:$roomId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'rooms',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: roomId,
          ),
          callback: (_) => _refreshAndEmit(roomId),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'participants',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (_) => _refreshAndEmit(roomId),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'stories',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: roomId,
          ),
          callback: (_) => _refreshAndEmit(roomId),
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'votes',
          callback: (_) => _refreshAndEmit(roomId),
        )
        .subscribe();
  }

  Future<void> _refreshAndEmit(String roomId) async {
    try {
      final state = await fetchRoomState(roomId);
      if (!_controller.isClosed) {
        _controller.add(state);
      }
    } catch (e) {
      debugPrint('Errore refresh room: $e');
    }
  }

  void unsubscribe() {
    if (_channel != null) {
      supabase.removeChannel(_channel!);
      _channel = null;
    }
  }

  void dispose() {
    unsubscribe();
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
  }) async {
    await supabase.rpc(
      'start_voting',
      params: {
        'p_participant_id': participantId,
        'p_story_id': storyId,
      },
    );
  }

  Future<void> castVote({
    required String participantId,
    required String storyId,
    required String value,
  }) async {
    await supabase.rpc(
      'cast_vote',
      params: {
        'p_participant_id': participantId,
        'p_story_id': storyId,
        'p_value': value,
      },
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
}
