import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/export/session_report.dart';
import '../../core/export/session_report_stats.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/session_archive_storage.dart';
import '../../core/theme/app_colors.dart';
import '../archive/session_kpi_preview.dart';
import '../lobby/session_report_sheet.dart';

class SessionArchiveSheet extends StatelessWidget {
  const SessionArchiveSheet({super.key, required this.entries});

  final List<SessionArchiveEntry> entries;

  static Future<void> show(BuildContext context) async {
    final entries = await SessionArchiveStorage.load();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SessionArchiveSheet(entries: entries),
    );
  }

  static SessionReportStats _statsForEntry(SessionArchiveEntry entry) {
    return SessionReportStats.tryParseJsonString(entry.statsJson) ??
        SessionReportStats.fromReport(
          SessionReport.fromJson(
            Map<String, dynamic>.from(jsonDecode(entry.reportJson) as Map),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFormat = DateFormat.yMMMd().add_Hm();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.sessionArchiveTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            if (entries.isEmpty)
              Text(l10n.sessionArchiveEmpty, textAlign: TextAlign.center)
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final stats = _statsForEntry(entry);
                    final completedLabel =
                        dateFormat.format(entry.completedAt.toLocal());

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openReport(context, entry, stats),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.roomName,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${entry.roomCode} · $completedLabel',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: const Color(
                                                  AppColors.textSecondary,
                                                ),
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy_outlined),
                                    tooltip: l10n.copiaReport,
                                    onPressed: () =>
                                        _copyReport(context, entry),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SessionKpiPreview(stats: stats, compact: true),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openReport(
    BuildContext context,
    SessionArchiveEntry entry,
    SessionReportStats stats,
  ) async {
    final report = SessionReport.fromJson(
      Map<String, dynamic>.from(jsonDecode(entry.reportJson) as Map),
    );
    if (!context.mounted) return;
    await SessionReportSheet.show(context, report, stats);
  }

  Future<void> _copyReport(BuildContext context, SessionArchiveEntry entry) async {
    final map = jsonDecode(entry.reportJson) as Map<String, dynamic>;
    final report = SessionReport.fromJson(map);
    await Clipboard.setData(ClipboardData(text: report.toMarkdown()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.sessionArchiveExported)),
      );
    }
  }
}
