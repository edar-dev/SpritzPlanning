import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/export/session_report.dart';
import '../../core/export/session_report_stats.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class SessionReportSheet extends StatelessWidget {
  const SessionReportSheet({
    super.key,
    required this.report,
    required this.stats,
  });

  final SessionReport report;
  final SessionReportStats stats;

  static Future<void> show(
    BuildContext context,
    SessionReport report,
    SessionReportStats stats,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SessionReportSheet(report: report, stats: stats),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.riepilogoSerata,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${report.roomName} · ${report.roomCode}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.textSecondary),
                  ),
            ),
            const SizedBox(height: 16),
            if (report.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  l10n.reportEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            else ...[
              Semantics(
                label: _statsSemanticsLabel(l10n),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatChip(
                      label: l10n.reportCompleted,
                      value: '${stats.completedCount}',
                    ),
                    if (stats.spikeCount > 0)
                      _StatChip(
                        label: l10n.reportSpikes,
                        value: '${stats.spikeCount}',
                      ),
                    if (stats.meanPoints != null)
                      _StatChip(
                        label: l10n.reportMean,
                        value: stats.meanPoints!.toStringAsFixed(1),
                      ),
                    if (stats.medianPoints != null)
                      _StatChip(
                        label: l10n.reportMedian,
                        value: stats.medianPoints!.toStringAsFixed(1),
                      ),
                  ],
                ),
              ),
              if (stats.bars.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: stats.bars.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final bar = stats.bars[index];
                      final maxIndex = 8.0;
                      final h = bar.numericIndex != null
                          ? 24 + (bar.numericIndex! / maxIndex) * 72
                          : 40.0;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 36,
                            height: h,
                            decoration: BoxDecoration(
                              color: const Color(AppColors.spritzOrange)
                                  .withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 48,
                            child: Text(
                              bar.estimate,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: DecoratedBox(
                    decoration: AppDecorations.surfaceCard(),
                    child: Column(
                      children: report.rows.map((row) {
                        return ListTile(
                          title: Text(row.title),
                          subtitle: row.isSpike
                              ? Text(l10n.storyKindSpike)
                              : null,
                          trailing: Chip(
                            label: Text(l10n.pointsSuffix(row.estimate)),
                            backgroundColor: const Color(AppColors.primarySoft),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _copy(context, report.toCsv()),
                    icon: const Icon(Icons.table_chart_outlined, size: 18),
                    label: Text(l10n.exportCsv),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _copy(context, report.toJira()),
                    icon: const Icon(Icons.integration_instructions_outlined,
                        size: 18),
                    label: Text(l10n.exportJira),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _copy(context, report.toAzureDevOps()),
                    icon: const Icon(Icons.cloud_outlined, size: 18),
                    label: Text(l10n.exportAzureDevOps),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _copy(context, report.toLinear()),
                    icon: const Icon(Icons.linear_scale_outlined, size: 18),
                    label: Text(l10n.exportLinear),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _copy(context, report.toGitHubIssues()),
                    icon: const Icon(Icons.code_outlined, size: 18),
                    label: Text(l10n.exportGitHubIssues),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _copy(context, report.toJson()),
                    icon: const Icon(Icons.data_object_outlined, size: 18),
                    label: Text(l10n.exportJson),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _shareMarkdown(context, report),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: Text(l10n.exportMarkdown),
                  ),
                  FilledButton.icon(
                    onPressed: () => _copy(context, report.toMarkdown()),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(l10n.copiaReport),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statsSemanticsLabel(dynamic l10n) {
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
    return parts.join(', ');
  }

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.reportCopied)),
      );
    }
  }

  Future<void> _shareMarkdown(BuildContext context, SessionReport report) async {
    final l10n = context.l10n;
    await Share.share(
      report.toMarkdown(),
      subject: '${l10n.riepilogoSerata} — ${report.roomName}',
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: const Color(AppColors.primarySoft),
    );
  }
}
