import 'package:flutter_test/flutter_test.dart';
import 'package:spritz_planning/core/export/session_report_stats.dart';
import 'package:spritz_planning/data/models/models.dart';

RoomState _stateWithDoneStories(List<Story> stories) {
  return RoomState(
    room: Room(
      id: 'r1',
      code: 'ABCD',
      name: 'Test',
      phase: RoomPhase.lobby,
      votesRevealed: false,
      deckValues: const ['1', '2', '3', '5', '8'],
      allowCoffeeBreak: true,
        autoRevealWhenAllVoted: false,
        hideVotersUntilReveal: false,
        lastActivityAt: DateTime.utc(2026),
      createdAt: DateTime.utc(2026),
    ),
    participants: const [],
    stories: stories,
    votes: const [],
  );
}

Story _doneStory(String title, String estimate, {StoryKind kind = StoryKind.story}) {
  return Story(
    id: title,
    roomId: 'r1',
    title: title,
    description: '',
    status: StoryStatus.done,
    sortOrder: 0,
    finalEstimate: estimate,
    kind: kind,
    facilitatorNote: '',
    createdAt: DateTime.utc(2026),
  );
}

void main() {
  test('median of numeric estimates [3,5,8] is 5', () {
    final stats = SessionReportStats.fromRoomState(
      _stateWithDoneStories([
        _doneStory('a', '3'),
        _doneStory('b', '5'),
        _doneStory('c', '8'),
      ]),
    );

    expect(stats.medianPoints, 5);
    // Mean uses Fibonacci deck indices: 3→4, 5→5, 8→6 → (4+5+6)/3
    expect(stats.meanPoints, 5);
    expect(stats.completedCount, 3);
  });

  test('spikes and non-numeric estimates excluded from mean/median', () {
    final stats = SessionReportStats.fromRoomState(
      _stateWithDoneStories([
        _doneStory('spike', '—', kind: StoryKind.spike),
        _doneStory('unknown', '?'),
        _doneStory('five', '5'),
      ]),
    );

    expect(stats.spikeCount, 1);
    expect(stats.meanPoints, 5);
    expect(stats.medianPoints, 5);
  });
}
