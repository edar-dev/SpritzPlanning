import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/export/session_report.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/session_archive_storage.dart';

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
                    return ListTile(
                      title: Text(entry.roomName),
                      subtitle: Text('${entry.roomCode} · ${entry.completedAt.toLocal()}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy_outlined),
                        onPressed: () => _copyReport(context, entry),
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
