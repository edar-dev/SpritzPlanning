import '../../data/models/models.dart';
import '../voting/vote_stats.dart';

class StoryEstimateBar {
  const StoryEstimateBar({
    required this.title,
    required this.estimate,
    this.numericIndex,
  });

  final String title;
  final String estimate;
  final int? numericIndex;
}

class SessionReportStats {
  const SessionReportStats({
    required this.completedCount,
    required this.spikeCount,
    required this.meanPoints,
    required this.medianPoints,
    required this.bars,
  });

  final int completedCount;
  final int spikeCount;
  final double? meanPoints;
  final double? medianPoints;
  final List<StoryEstimateBar> bars;

  static SessionReportStats fromRoomState(RoomState state) {
    final done = state.stories.where((s) => s.status == StoryStatus.done);
    final spikes = done.where((s) => s.isSpike).length;
    final numericEstimates = <int>[];
    final bars = <StoryEstimateBar>[];

    for (final story in done) {
      final est = story.finalEstimate ?? '—';
      bars.add(
        StoryEstimateBar(
          title: story.title,
          estimate: est,
          numericIndex:
              isNumericDeckValue(est) ? _fibonacciIndex(est) : null,
        ),
      );
      if (isNumericDeckValue(est)) {
        numericEstimates.add(_fibonacciIndex(est));
      }
    }

    numericEstimates.sort();
    double? mean;
    double? median;
    if (numericEstimates.isNotEmpty) {
      mean = numericEstimates.reduce((a, b) => a + b) / numericEstimates.length;
      final mid = numericEstimates.length ~/ 2;
      median = numericEstimates.length.isOdd
          ? numericEstimates[mid].toDouble()
          : (numericEstimates[mid - 1] + numericEstimates[mid]) / 2;
    }

    return SessionReportStats(
      completedCount: done.length,
      spikeCount: spikes,
      meanPoints: mean,
      medianPoints: median,
      bars: bars,
    );
  }
}

int _fibonacciIndex(String value) {
  const order = ['0', '½', '1', '2', '3', '5', '8', '13', '21'];
  return order.indexOf(value);
}
