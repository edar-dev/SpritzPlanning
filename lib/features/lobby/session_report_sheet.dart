import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_strings.dart';
import '../../core/export/session_report.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class SessionReportSheet extends StatelessWidget {
  const SessionReportSheet({super.key, required this.report});

  final SessionReport report;

  static Future<void> show(BuildContext context, SessionReport report) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SessionReportSheet(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.riepilogoSerata,
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
                  AppStrings.reportEmpty,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              )
            else ...[
              Flexible(
                child: SingleChildScrollView(
                  child: DecoratedBox(
                    decoration: AppDecorations.surfaceCard(),
                    child: Column(
                      children: report.rows.map((row) {
                        return ListTile(
                          title: Text(row.title),
                          trailing: Chip(
                            label: Text('${row.estimate} pt'),
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
                    label: const Text(AppStrings.exportCsv),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _shareMarkdown(report),
                    icon: const Icon(Icons.share_outlined, size: 18),
                    label: const Text(AppStrings.exportMarkdown),
                  ),
                  FilledButton.icon(
                    onPressed: () => _copy(context, report.toMarkdown()),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text(AppStrings.copiaReport),
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
        const SnackBar(content: Text(AppStrings.reportCopied)),
      );
    }
  }

  Future<void> _shareMarkdown(SessionReport report) async {
    await Share.share(
      report.toMarkdown(),
      subject: '${AppStrings.riepilogoSerata} — ${report.roomName}',
    );
  }
}
