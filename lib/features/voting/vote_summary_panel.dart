import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/deck_values.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/voting/vote_stats.dart';
import '../../shared/widgets/section_header.dart';

class VoteSummaryPanel extends StatelessWidget {
  const VoteSummaryPanel({
    super.key,
    required this.stats,
  });

  final VoteStats stats;

  @override
  Widget build(BuildContext context) {
    if (stats.distribution.isEmpty) return const SizedBox.shrink();

    final maxCount = stats.distribution.values.fold<int>(
      0,
      (prev, count) => count > prev ? count : prev,
    );

    return DecoratedBox(
      decoration: AppDecorations.surfaceCard(radius: AppDecorations.radiusMd),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(
              title: AppStrings.distribuzioneVoti,
              subtitle: 'Riepilogo delle dosi scelte',
            ),
            const SizedBox(height: 12),
            ...stats.distribution.entries.map((entry) {
              final barWidth = maxCount == 0
                  ? 0.0
                  : entry.value / maxCount;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: barWidth,
                          minHeight: 10,
                          backgroundColor: const Color(AppColors.surfaceMuted),
                          color: const Color(AppColors.spritzOrange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.value}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              );
            }),
            if (stats.suggestedConsensus != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: Color(AppColors.spritzOrange),
                  ),
                  label: Text(
                    '${AppStrings.consensoSuggerito}: ${stats.suggestedConsensus} '
                    '(${DeckValues.label(stats.suggestedConsensus!)})',
                  ),
                  backgroundColor: const Color(AppColors.primarySoft),
                ),
              ),
            ],
            if (stats.numericOutliers.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: stats.numericOutliers.map((value) {
                  return Chip(
                    label: Text(
                      '${AppStrings.outlier}: $value (${DeckValues.label(value)})',
                    ),
                    backgroundColor:
                        Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
