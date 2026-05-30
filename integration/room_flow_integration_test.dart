import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spritz_planning/data/models/models.dart';
import 'package:spritz_planning/data/repositories/room_repository.dart';
import 'package:spritz_planning/data/supabase/supabase_client.dart';

/// Flusso end-to-end contro Supabase reale.
///
/// Esegui con credenziali:
/// `flutter test integration/room_flow_integration_test.dart --dart-define-from-file=env.json`
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Room voting flow (Supabase)', () {
    RoomRepository? repo;

    setUpAll(() async {
      if (!SupabaseConfig.isConfigured) return;
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues({});
      await initializeSupabase();
      repo = RoomRepository();
    });

    tearDown(() {
      repo?.dispose();
      repo = null;
    });

    test('create → story → vote → reveal → estimate → next', () async {
      if (!SupabaseConfig.isConfigured || repo == null) {
        markTestSkipped(
          'Imposta SUPABASE_URL e SUPABASE_ANON_KEY (--dart-define-from-file=env.json)',
        );
      }

      final repository = repo!;

      final suffix = DateTime.now().millisecondsSinceEpoch;
      final barman = await repository.createRoom(
        name: 'IT-$suffix',
        nickname: 'Barman-$suffix',
      );

      final guest = await repository.joinRoom(
        code: barman.code,
        nickname: 'Guest-$suffix',
      );

      expect(guest.roomId, barman.roomId);

      final storyId = await repository.addStory(
        participantId: barman.participantId,
        title: 'US-1',
      );

      await repository.startVoting(
        participantId: barman.participantId,
        storyId: storyId,
      );

      await repository.castVote(
        participantId: barman.participantId,
        storyId: storyId,
        value: '5',
      );
      await repository.castVote(
        participantId: guest.participantId,
        storyId: storyId,
        value: '5',
      );

      await repository.revealVotes(participantId: barman.participantId);

      var state = await repository.fetchRoomState(barman.roomId);
      expect(state.room.votesRevealed, isTrue);
      expect(state.currentVotes.length, 2);

      await repository.setFinalEstimate(
        participantId: barman.participantId,
        storyId: storyId,
        estimate: '5',
      );

      await repository.nextStory(participantId: barman.participantId);

      state = await repository.fetchRoomState(barman.roomId);
      expect(state.room.phase, RoomPhase.lobby);
      expect(state.room.votesRevealed, isFalse);
    });
  });
}
