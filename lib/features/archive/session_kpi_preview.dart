import 'package:flutter/material.dart';

import '../../core/export/session_report_stats.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_colors.dart';

class SessionKpiPreview extends StatelessWidget {
  const SessionKpiPreview({
    super.key,
    required this.stats,
    this.compact = false,
  });

  final SessionReportStats stats;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chips = <Widget>[
      _KpiChip(
        label: l10n.reportCompleted,
        value: '${stats.completedCount}',
      ),
      if (stats.spikeCount > 0)
        _KpiChip(
          label: l10n.reportSpikes,
          value: '${stats.spikeCount}',
        ),
      if (stats.meanPoints != null)
        _KpiChip(
          label: l10n.reportMean,
          value: stats.meanPoints!.toStringAsFixed(1),
        ),
      if (stats.medianPoints != null)
        _KpiChip(
          label: l10n.reportMedian,
          value: stats.medianPoints!.toStringAsFixed(1),
        ),
      if (stats.variancePoints != null)
        _KpiChip(
          label: l10n.reportVariance,
          value: stats.variancePoints!.toStringAsFixed(1),
        ),
      if (stats.revisionRatePercent != null)
        _KpiChip(
          label: l10n.reportRevisionRate,
          value: l10n.reportRevisionRateValue(
            stats.revisionRatePercent!.round(),
          ),
        ),
      if (stats.avgMinutesPerStory != null)
        _KpiChip(
          label: l10n.reportAvgTimePerStory,
          value: l10n.reportAvgMinutesValue(
            stats.avgMinutesPerStory!.round(),
          ),
        ),
    ];

    return Semantics(
      label: _semanticsLabel(l10n),
      child: Wrap(
        spacing: compact ? 6 : 8,
        runSpacing: compact ? 6 : 8,
        children: chips,
      ),
    );
  }

  String _semanticsLabel(dynamic l10n) {
    final parts = <String>[
      '${l10n.reportCompleted}: ${stats.completedCount}',
    ];
    if (stats.meanPoints != null) {
      parts.add('${l10n.reportMean}: ${stats.meanPoints!.toStringAsFixed(1)}');
    }
    if (stats.medianPoints != null) {
      parts.add(
        '${l10n.reportMedian}: ${stats.medianPoints!.toStringAsFixed(1)}',
      );
    }
    if (stats.variancePoints != null) {
      parts.add(
        '${l10n.reportVariance}: ${stats.variancePoints!.toStringAsFixed(1)}',
      );
    }
    if (stats.revisionRatePercent != null) {
      parts.add(
        '${l10n.reportRevisionRate}: ${stats.revisionRatePercent!.round()}%',
      );
    }
    if (stats.avgMinutesPerStory != null) {
      parts.add(
        '${l10n.reportAvgTimePerStory}: ${stats.avgMinutesPerStory!.round()}',
      );
    }
    return parts.join(', ');
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text('$label: $value'),
      backgroundColor: const Color(AppColors.primarySoft),
    );
  }
}
