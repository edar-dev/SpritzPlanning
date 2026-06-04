import 'package:flutter_test/flutter_test.dart';
import 'package:spritz_planning/core/export/session_report.dart';
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
      confidenceRoundActive: false,
      lastActivityAt: DateTime.utc(2026, 6, 1, 12),
      createdAt: DateTime.utc(2026, 6, 1, 10),
    ),
    participants: const [],
    stories: stories,
    votes: const [],
  );
}

Story _doneStory(
  String title,
  String estimate, {
  StoryKind kind = StoryKind.story,
  List<EstimateHistoryEntry> estimateHistory = const [],
  DateTime? createdAt,
}) {
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
    publicComment: '',
    isReference: false,
    estimateHistory: estimateHistory,
    createdAt: createdAt ?? DateTime.utc(2026, 6, 1, 10),
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
    expect(stats.meanPoints, 5);
    expect(stats.completedCount, 3);
    expect(stats.variancePoints, closeTo(2 / 3, 0.01));
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
    expect(stats.variancePoints, isNull);
  });

  test('revision rate counts stories with multiple history entries', () {
    final stats = SessionReportStats.fromRoomState(
      _stateWithDoneStories([
        _doneStory(
          'revised',
          '5',
          estimateHistory: [
            EstimateHistoryEntry(
              estimate: '8',
              at: DateTime.utc(2026, 6, 1, 10),
              kind: 'final',
            ),
            EstimateHistoryEntry(
              estimate: '5',
              at: DateTime.utc(2026, 6, 1, 11),
              kind: 'final',
            ),
          ],
        ),
        _doneStory('stable', '3'),
      ]),
    );

    expect(stats.revisionRatePercent, 50);
  });

  test('avg minutes per story from estimate history span', () {
    final stats = SessionReportStats.fromRoomState(
      _stateWithDoneStories([
        _doneStory(
          'slow',
          '8',
          estimateHistory: [
            EstimateHistoryEntry(
              estimate: '8',
              at: DateTime.utc(2026, 6, 1, 10),
              kind: 'final',
            ),
            EstimateHistoryEntry(
              estimate: '8',
              at: DateTime.utc(2026, 6, 1, 10, 30),
              kind: 'final',
            ),
          ],
        ),
      ]),
    );

    expect(stats.avgMinutesPerStory, 30);
  });

  test('fromReport derives revision rate from history summary', () {
    final report = SessionReport(
      roomName: 'Bar',
      roomCode: 'CODE',
      exportedAt: DateTime.utc(2026),
      rows: [
        SessionReportRow(
          title: 'A',
          estimate: '5',
          description: '',
          facilitatorNote: '',
          publicComment: '',
          isReference: false,
          estimateHistorySummary: '8 → 5',
          completedAt: DateTime.utc(2026),
          isSpike: false,
        ),
        SessionReportRow(
          title: 'B',
          estimate: '3',
          description: '',
          facilitatorNote: '',
          publicComment: '',
          isReference: false,
          estimateHistorySummary: '',
          completedAt: DateTime.utc(2026),
          isSpike: false,
        ),
      ],
    );

    final stats = SessionReportStats.fromReport(report);
    expect(stats.revisionRatePercent, 50);
    expect(stats.completedCount, 2);
  });

  test('toJson round-trip preserves KPI fields', () {
    final original = SessionReportStats.fromRoomState(
      _stateWithDoneStories([
        _doneStory('a', '3'),
        _doneStory('b', '5'),
      ]),
    );
    final restored = SessionReportStats.fromJson(original.toJson());

    expect(restored.completedCount, original.completedCount);
    expect(restored.meanPoints, original.meanPoints);
    expect(restored.revisionRatePercent, original.revisionRatePercent);
  });
}
