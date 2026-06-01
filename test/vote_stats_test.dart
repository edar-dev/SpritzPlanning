import 'package:flutter_test/flutter_test.dart';
import 'package:spritz_planning/core/voting/vote_stats.dart';
import 'package:spritz_planning/data/models/models.dart';

void main() {
  group('computeVoteStats', () {
    test('suggested consensus 5 and outlier 8 for votes 3,5,5,8', () {
      final participants = [
        Participant(
          id: 'p1',
          roomId: 'r1',
          nickname: 'A',
          isFacilitator: true,
          isObserver: false,
          joinedAt: _t,
          lastSeenAt: _t,
        ),
        Participant(
          id: 'p2',
          roomId: 'r1',
          nickname: 'B',
          isFacilitator: false,
          isObserver: false,
          joinedAt: _t,
          lastSeenAt: _t,
        ),
        Participant(
          id: 'p3',
          roomId: 'r1',
          nickname: 'C',
          isFacilitator: false,
          isObserver: false,
          joinedAt: _t,
          lastSeenAt: _t,
        ),
        Participant(
          id: 'p4',
          roomId: 'r1',
          nickname: 'D',
          isFacilitator: false,
          isObserver: false,
          joinedAt: _t,
          lastSeenAt: _t,
        ),
      ];

      final votes = [
        _vote('p1', '3'),
        _vote('p2', '5'),
        _vote('p3', '5'),
        _vote('p4', '8'),
      ];

      final stats = computeVoteStats(votes: votes, participants: participants);

      expect(stats.suggestedConsensus, '5');
      expect(stats.numericOutliers, ['8']);
      expect(stats.distribution['5'], 2);
      expect(stats.votedCount, 4);
      expect(stats.participantCount, 4);
    });

    test('excludes non-numeric votes from consensus', () {
      final stats = computeVoteStats(
        votes: [_vote('p1', '?'), _vote('p2', '☕')],
        participants: [
          Participant(
            id: 'p1',
            roomId: 'r1',
            nickname: 'A',
            isFacilitator: true,
            isObserver: false,
            joinedAt: _t,
            lastSeenAt: _t,
          ),
          Participant(
            id: 'p2',
            roomId: 'r1',
            nickname: 'B',
            isFacilitator: false,
            isObserver: false,
            joinedAt: _t,
            lastSeenAt: _t,
          ),
        ],
      );

      expect(stats.suggestedConsensus, isNull);
      expect(stats.numericOutliers, isEmpty);
    });
  });
}

final _t = DateTime.utc(2025);

Vote _vote(String participantId, String value) {
  return Vote(
    id: 'v-$participantId',
    storyId: 's1',
    participantId: participantId,
    value: value,
    votedAt: _t,
  );
}
