import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../core/export/session_report.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/session_archive_storage.dart';
import '../../core/theme/app_colors.dart';
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
                    final completedLabel =
                        dateFormat.format(entry.completedAt.toLocal());
                    final report = SessionReport.fromJson(
                      Map<String, dynamic>.from(
                        jsonDecode(entry.reportJson) as Map,
                      ),
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openReport(context, report),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                onPressed: () => _copyReport(context, report),
                              ),
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

  Future<void> _openReport(BuildContext context, SessionReport report) async {
    if (!context.mounted) return;
    await SessionReportSheet.show(context, report);
  }

  Future<void> _copyReport(BuildContext context, SessionReport report) async {
    await Clipboard.setData(ClipboardData(text: report.toMarkdown()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.sessionArchiveExported)),
      );
    }
  }
}
