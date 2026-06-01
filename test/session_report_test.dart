import 'package:flutter_test/flutter_test.dart';
import 'package:spritz_planning/core/export/session_report.dart';
import 'package:spritz_planning/data/models/models.dart';

void main() {
  test('SessionReport CSV and Markdown include done stories', () {
    final state = RoomState(
      room: Room(
        id: 'r1',
        code: 'SPRT-TEST',
        name: 'Bar Alpha',
        phase: RoomPhase.lobby,
        votesRevealed: false,
        deckValues: const ['0', '½', '1', '2', '3', '5', '8', '13', '21', '?', '☕'],
        allowCoffeeBreak: true,
        autoRevealWhenAllVoted: false,
        lastActivityAt: DateTime.utc(2026, 5, 29),
        createdAt: DateTime.utc(2026, 5, 29),
      ),
      participants: const [],
      stories: [
        Story(
          id: 's1',
          roomId: 'r1',
          title: 'Login OAuth',
          description: '',
          sortOrder: 0,
          status: StoryStatus.done,
          kind: StoryKind.story,
          finalEstimate: '5',
          facilitatorNote: '',
          createdAt: DateTime.utc(2026, 5, 29, 14, 30),
        ),
        Story(
          id: 's2',
          roomId: 'r1',
          title: 'Pending story',
          description: '',
          sortOrder: 1,
          status: StoryStatus.pending,
          kind: StoryKind.story,
          facilitatorNote: '',
          createdAt: DateTime.utc(2026, 5, 29),
        ),
      ],
      votes: const [],
    );

    final report = SessionReport.fromRoomState(state);
    expect(report.isEmpty, isFalse);
    expect(report.rows, hasLength(1));

    final csv = report.toCsv();
    expect(csv, contains('Bar Alpha'));
    expect(csv, contains('SPRT-TEST'));
    expect(csv, contains('Login OAuth'));
    expect(csv, contains(',5,'));

    final md = report.toMarkdown();
    expect(md, contains('# SpritzPlanning — Riepilogo'));
    expect(md, contains('Login OAuth'));
    expect(md, contains('| 5 |'));
    expect(md, isNot(contains('Pending story')));
  });

  test('SessionReport is empty without done estimates', () {
    final state = RoomState(
      room: Room(
        id: 'r1',
        code: 'SPRT-EMPTY',
        name: 'Empty',
        phase: RoomPhase.lobby,
        votesRevealed: false,
        deckValues: const ['0', '½', '1', '2', '3', '5', '8', '13', '21', '?', '☕'],
        allowCoffeeBreak: true,
        autoRevealWhenAllVoted: false,
        lastActivityAt: DateTime.utc(2026, 5, 29),
        createdAt: DateTime.utc(2026, 5, 29),
      ),
      participants: const [],
      stories: const [],
      votes: const [],
    );

    expect(SessionReport.fromRoomState(state).isEmpty, isTrue);
  });
}
