import 'package:flutter_test/flutter_test.dart';
import 'package:spritz_planning/data/models/models.dart';

void main() {
  group('RoomState', () {
    test('hasParticipantVoted returns true when vote has value', () {
      final state = _roomState(
        votes: [_vote('p1', '5')],
      );
      expect(state.hasParticipantVoted('p1'), isTrue);
      expect(state.hasParticipantVoted('p2'), isFalse);
    });

    test('allParticipantsVoted is false with pending votes', () {
      final state = _roomState(
        participants: [_participant('p1'), _participant('p2')],
        votes: [_vote('p1', '3')],
      );
      expect(state.allParticipantsVoted, isFalse);
    });

    test('allParticipantsVoted is true when everyone voted', () {
      final state = _roomState(
        participants: [_participant('p1'), _participant('p2')],
        votes: [_vote('p1', '3'), _vote('p2', '5')],
      );
      expect(state.allParticipantsVoted, isTrue);
    });

    test('allParticipantsVoted is false without current story', () {
      final state = _roomState(
        room: _roomWithoutStory(),
        votes: [_vote('p1', '3')],
      );
      expect(state.allParticipantsVoted, isFalse);
    });
  });
}

final _t = DateTime.utc(2025);

RoomState _roomState({
  Room? room,
  List<Participant>? participants,
  List<Story>? stories,
  List<Vote>? votes,
}) {
  return RoomState(
    room: room ?? _room(),
    participants: participants ?? [_participant('p1')],
    stories: stories ?? [_story()],
    votes: votes ?? const [],
  );
}

const _defaultDeck = ['0', '½', '1', '2', '3', '5', '8', '13', '21', '?', '☕'];

Room _room({String currentStoryId = 'story-1'}) {
  return Room(
    id: 'room-1',
    code: 'SPRT-TEST',
    name: 'Test',
    phase: RoomPhase.voting,
    currentStoryId: currentStoryId,
    votesRevealed: false,
    deckValues: _defaultDeck,
    allowCoffeeBreak: true,
    lastActivityAt: _t,
    createdAt: _t,
  );
}

Room _roomWithoutStory() {
  return Room(
    id: 'room-1',
    code: 'SPRT-TEST',
    name: 'Test',
    phase: RoomPhase.lobby,
    votesRevealed: false,
    deckValues: _defaultDeck,
    allowCoffeeBreak: true,
    lastActivityAt: _t,
    createdAt: _t,
  );
}

Participant _participant(String id) {
  return Participant(
    id: id,
    roomId: 'room-1',
    nickname: id,
    isFacilitator: id == 'p1',
    joinedAt: _t,
    lastSeenAt: _t,
  );
}

Story _story() {
  return Story(
    id: 'story-1',
    roomId: 'room-1',
    title: 'US-1',
    description: '',
    sortOrder: 0,
    status: StoryStatus.voting,
    createdAt: _t,
  );
}

Vote _vote(String participantId, String value) {
  return Vote(
    id: 'v-$participantId',
    storyId: 'story-1',
    participantId: participantId,
    value: value,
    votedAt: _t,
  );
}
