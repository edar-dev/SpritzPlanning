import '../../data/models/models.dart';

/// Statistiche sui voti rivelati per la dashboard di consenso.
class VoteStats {
  const VoteStats({
    required this.distribution,
    required this.suggestedConsensus,
    required this.numericOutliers,
    required this.votedCount,
    required this.participantCount,
  });

  final Map<String, int> distribution;
  final String? suggestedConsensus;
  final List<String> numericOutliers;
  final int votedCount;
  final int participantCount;

  double get voteProgress =>
      participantCount == 0 ? 0 : votedCount / participantCount;
}

const _fibonacciOrder = ['0', '½', '1', '2', '3', '5', '8', '13', '21'];

bool isNumericDeckValue(String value) => _fibonacciOrder.contains(value);

int _fibonacciIndex(String value) => _fibonacciOrder.indexOf(value);

VoteStats computeVoteStats({
  required List<Vote> votes,
  required List<Participant> participants,
}) {
  final distribution = <String, int>{};
  final numericValues = <String>[];

  for (final vote in votes) {
    final value = vote.value;
    if (value == null) continue;
    distribution[value] = (distribution[value] ?? 0) + 1;
    if (isNumericDeckValue(value)) {
      numericValues.add(value);
    }
  }

  final votedCount = votes.where((v) => v.value != null).length;
  final participantCount = participants.length;

  final consensus = _suggestedConsensus(numericValues);

  return VoteStats(
    distribution: distribution,
    suggestedConsensus: consensus,
    numericOutliers: _numericOutliers(numericValues, consensus),
    votedCount: votedCount,
    participantCount: participantCount,
  );
}

String? _suggestedConsensus(List<String> numericValues) {
  if (numericValues.isEmpty) return null;

  final counts = <String, int>{};
  for (final value in numericValues) {
    counts[value] = (counts[value] ?? 0) + 1;
  }

  final total = numericValues.length;
  final best = counts.entries.reduce(
    (a, b) => a.value >= b.value ? a : b,
  );

  if (best.value > total / 2) return best.key;
  if (best.value >= total / 2) return best.key;

  return null;
}

List<String> _numericOutliers(
  List<String> numericValues,
  String? consensus,
) {
  if (numericValues.length < 2 || consensus == null) return const [];

  final counts = <String, int>{};
  for (final value in numericValues) {
    counts[value] = (counts[value] ?? 0) + 1;
  }

  final consensusIndex = _fibonacciIndex(consensus);
  final outliers = <String>[];

  for (final entry in counts.entries) {
    if (entry.key == consensus || entry.value > 1) continue;
    final diff = _fibonacciIndex(entry.key) - consensusIndex;
    if (diff.abs() >= 1 && diff > 0) {
      outliers.add(entry.key);
    }
  }

  return outliers..sort((a, b) => _fibonacciIndex(a).compareTo(_fibonacciIndex(b)));
}
