import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/export/session_report.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class SessionReportSheet extends StatelessWidget {
  const SessionReportSheet({
    super.key,
    required this.report,
  });

  final SessionReport report;

  static Future<void> show(
    BuildContext context,
    SessionReport report,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SessionReportSheet(report: report),
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
              Flexible(
                child: SingleChildScrollView(
                  child: DecoratedBox(
                    decoration: AppDecorations.surfaceCard(context),
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
                  FilledButton.icon(
                    onPressed: () => _copy(context, report.toCsv()),
                    icon: const Icon(Icons.table_chart_outlined, size: 18),
                    label: Text(l10n.exportCsv),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _copy(context, report.toMarkdown()),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: Text(l10n.copiaReport),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _shareMarkdown(context, report),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: Text(l10n.exportMarkdown),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
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
