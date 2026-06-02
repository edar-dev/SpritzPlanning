import 'dart:convert';
import 'dart:math' as math;

import '../../data/models/models.dart';
import '../voting/vote_stats.dart';
import 'session_report.dart';

class StoryEstimateBar {
  const StoryEstimateBar({
    required this.title,
    required this.estimate,
    this.numericIndex,
  });

  final String title;
  final String estimate;
  final int? numericIndex;

  Map<String, dynamic> toJson() => {
        'title': title,
        'estimate': estimate,
        if (numericIndex != null) 'numericIndex': numericIndex,
      };

  factory StoryEstimateBar.fromJson(Map<String, dynamic> json) {
    return StoryEstimateBar(
      title: json['title'] as String,
      estimate: json['estimate'] as String,
      numericIndex: json['numericIndex'] as int?,
    );
  }
}

class SessionReportStats {
  const SessionReportStats({
    required this.completedCount,
    required this.spikeCount,
    required this.meanPoints,
    required this.medianPoints,
    required this.bars,
    this.variancePoints,
    this.revisionRatePercent,
    this.avgMinutesPerStory,
  });

  final int completedCount;
  final int spikeCount;
  final double? meanPoints;
  final double? medianPoints;
  final List<StoryEstimateBar> bars;
  final double? variancePoints;
  final double? revisionRatePercent;
  final double? avgMinutesPerStory;

  static SessionReportStats fromRoomState(RoomState state) {
    final done = state.stories.where((s) => s.status == StoryStatus.done);
    final spikes = done.where((s) => s.isSpike).length;
    final estimableDone = done.where((s) => !s.isSpike).toList();
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
    final meanMedian = _meanAndMedian(numericEstimates);
    final variance = _variance(numericEstimates, meanMedian.mean);

    int withRevisions = 0;
    final durations = <Duration>[];
    for (final story in estimableDone) {
      if (_hasEstimateRevision(story)) withRevisions++;
      final duration = _storyEstimateDuration(story);
      if (duration != null) durations.add(duration);
    }

    double? revisionRate;
    if (estimableDone.isNotEmpty) {
      revisionRate = (withRevisions / estimableDone.length) * 100;
    }

    double? avgMinutes;
    if (durations.isNotEmpty) {
      final totalMs =
          durations.fold<int>(0, (sum, d) => sum + d.inMilliseconds);
      avgMinutes = (totalMs / durations.length) / 60000;
    }

    return SessionReportStats(
      completedCount: done.length,
      spikeCount: spikes,
      meanPoints: meanMedian.mean,
      medianPoints: meanMedian.median,
      bars: bars,
      variancePoints: variance,
      revisionRatePercent: revisionRate,
      avgMinutesPerStory: avgMinutes,
    );
  }

  static SessionReportStats fromReport(SessionReport report) {
    final spikes = report.rows.where((r) => r.isSpike).length;
    final estimableRows = report.rows.where((r) => !r.isSpike).toList();
    final numericEstimates = <int>[];
    final bars = <StoryEstimateBar>[];

    for (final row in report.rows) {
      bars.add(
        StoryEstimateBar(
          title: row.title,
          estimate: row.estimate,
          numericIndex:
              isNumericDeckValue(row.estimate) ? _fibonacciIndex(row.estimate) : null,
        ),
      );
      if (isNumericDeckValue(row.estimate)) {
        numericEstimates.add(_fibonacciIndex(row.estimate));
      }
    }

    numericEstimates.sort();
    final meanMedian = _meanAndMedian(numericEstimates);
    final variance = _variance(numericEstimates, meanMedian.mean);

    int withRevisions = 0;
    for (final row in estimableRows) {
      if (_hasRevisionSummary(row.estimateHistorySummary)) withRevisions++;
    }

    double? revisionRate;
    if (estimableRows.isNotEmpty) {
      revisionRate = (withRevisions / estimableRows.length) * 100;
    }

    return SessionReportStats(
      completedCount: report.rows.length,
      spikeCount: spikes,
      meanPoints: meanMedian.mean,
      medianPoints: meanMedian.median,
      bars: bars,
      variancePoints: variance,
      revisionRatePercent: revisionRate,
    );
  }

  factory SessionReportStats.fromJson(Map<String, dynamic> json) {
    final bars = (json['bars'] as List? ?? [])
        .map(
          (e) => StoryEstimateBar.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();

    return SessionReportStats(
      completedCount: json['completedCount'] as int? ?? 0,
      spikeCount: json['spikeCount'] as int? ?? 0,
      meanPoints: (json['meanPoints'] as num?)?.toDouble(),
      medianPoints: (json['medianPoints'] as num?)?.toDouble(),
      bars: bars,
      variancePoints: (json['variancePoints'] as num?)?.toDouble(),
      revisionRatePercent: (json['revisionRatePercent'] as num?)?.toDouble(),
      avgMinutesPerStory: (json['avgMinutesPerStory'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'completedCount': completedCount,
        'spikeCount': spikeCount,
        if (meanPoints != null) 'meanPoints': meanPoints,
        if (medianPoints != null) 'medianPoints': medianPoints,
        'bars': bars.map((b) => b.toJson()).toList(),
        if (variancePoints != null) 'variancePoints': variancePoints,
        if (revisionRatePercent != null) 'revisionRatePercent': revisionRatePercent,
        if (avgMinutesPerStory != null) 'avgMinutesPerStory': avgMinutesPerStory,
      };

  String toJsonString() => jsonEncode(toJson());

  static SessionReportStats? tryParseJsonString(String raw) {
    if (raw.isEmpty || raw == '{}') return null;
    try {
      return SessionReportStats.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  /// Language-neutral KPI block for Markdown/CSV exports.
  String toMarkdownKpiBlock() {
    final lines = <String>[
      '## KPI',
      '- Completed stories: $completedCount',
    ];
    if (spikeCount > 0) lines.add('- Spikes: $spikeCount');
    if (meanPoints != null) {
      lines.add('- Mean (deck index): ${meanPoints!.toStringAsFixed(1)}');
    }
    if (medianPoints != null) {
      lines.add('- Median (deck index): ${medianPoints!.toStringAsFixed(1)}');
    }
    if (variancePoints != null) {
      lines.add('- Variance (deck index): ${variancePoints!.toStringAsFixed(1)}');
    }
    if (revisionRatePercent != null) {
      lines.add(
        '- Stories with estimate revisions: ${revisionRatePercent!.round()}%',
      );
    }
    if (avgMinutesPerStory != null) {
      lines.add(
        '- Avg time per story: ${avgMinutesPerStory!.round()} min',
      );
    }
    return '${lines.join('\n')}\n';
  }
}

class _MeanMedian {
  const _MeanMedian({this.mean, this.median});

  final double? mean;
  final double? median;
}

_MeanMedian _meanAndMedian(List<int> values) {
  if (values.isEmpty) return const _MeanMedian();
  final mean = values.reduce((a, b) => a + b) / values.length;
  final mid = values.length ~/ 2;
  final median = values.length.isOdd
      ? values[mid].toDouble()
      : (values[mid - 1] + values[mid]) / 2;
  return _MeanMedian(mean: mean, median: median);
}

double? _variance(List<int> values, double? mean) {
  if (values.length < 2 || mean == null) return null;
  final sumSq = values.fold<double>(
    0,
    (sum, value) => sum + math.pow(value - mean, 2).toDouble(),
  );
  return sumSq / values.length;
}

bool _hasEstimateRevision(Story story) {
  if (story.estimateHistory.length > 1) return true;
  final unique =
      story.estimateHistory.map((e) => e.estimate).where((e) => e.isNotEmpty);
  return unique.toSet().length > 1;
}

bool _hasRevisionSummary(String summary) {
  return summary.contains('→');
}

Duration? _storyEstimateDuration(Story story) {
  if (story.isSpike || story.estimateHistory.isEmpty) return null;

  final times = story.estimateHistory.map((e) => e.at).toList()..sort();
  final start = times.first;
  final end = times.last;
  if (end.isAfter(start)) return end.difference(start);

  if (story.createdAt.isBefore(end)) {
    return end.difference(story.createdAt);
  }
  return Duration.zero;
}

int _fibonacciIndex(String value) {
  const order = ['0', '½', '1', '2', '3', '5', '8', '13', '21'];
  return order.indexOf(value);
}
