import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/errors/user_facing_error.dart';
import '../../core/export/session_report.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/preferences/session_archive_storage.dart';
import '../../core/preferences/recent_rooms_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/providers.dart';
import '../lobby/session_report_sheet.dart';

class SessionArchiveSheet extends ConsumerStatefulWidget {
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
  ConsumerState<SessionArchiveSheet> createState() =>
      _SessionArchiveSheetState();
}

class _SessionArchiveSheetState extends ConsumerState<SessionArchiveSheet> {
  late List<SessionArchiveEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = List<SessionArchiveEntry>.from(widget.entries);
  }

  SessionReport _reportFor(SessionArchiveEntry entry) {
    return SessionReport.fromJson(
      Map<String, dynamic>.from(jsonDecode(entry.reportJson) as Map),
    );
  }

  List<String> _previewLines(SessionReport report) {
    return report.rows.take(3).map((r) => '• ${r.title} → ${r.estimate}').toList();
  }

  Future<void> _copyReport(BuildContext context, SessionReport report) async {
    await Clipboard.setData(ClipboardData(text: report.toMarkdown()));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.sessionArchiveExported)),
      );
    }
  }

  Future<void> _deleteEntry(SessionArchiveEntry entry) async {
    await SessionArchiveStorage.delete(entry.id);
    if (!mounted) return;
    setState(() => _entries.removeWhere((e) => e.id == entry.id));
  }

  Future<void> _createFromArchive(SessionArchiveEntry entry) async {
    final l10n = context.l10n;
    final report = _reportFor(entry);
    final titles = report.rows.map((r) => r.title).where((t) => t.isNotEmpty).toList();
    if (titles.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.archiveUseTemplateEmpty)),
      );
      return;
    }

    var nickname = await AppPreferences.loadLastNickname() ?? '';
    if (nickname.trim().length < 2) {
      nickname = await _promptNickname() ?? '';
    }
    if (nickname.trim().length < 2) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.nicknameTooShort)),
      );
      return;
    }

    final localeName = '${entry.roomName} 2';
    try {
      await AppPreferences.saveLastNickname(nickname.trim());
      final repo = ref.read(roomRepositoryProvider);
      final result = await repo.createRoom(
        name: localeName,
        nickname: nickname.trim(),
      );
      await repo.addStories(
        participantId: result.participantId,
        titles: titles,
      );
      await ref.read(sessionProvider.notifier).saveSession(
            result,
            nickname: nickname.trim(),
            roomName: localeName,
          );
      await ref.read(roomStateProvider.notifier).enterRoom(
            result.roomId,
            result.participantId,
          );
      await RecentRoomsStorage.add(
        code: result.code,
        name: localeName,
        roomId: result.roomId,
      );
      if (!mounted) return;
      Navigator.pop(context);
      context.go('/room/${result.roomId}');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingMessage(e, l10n: l10n))),
      );
    }
  }

  Future<String?> _promptNickname() async {
    final controller = TextEditingController();
    final l10n = context.l10n;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.nicknameLabel),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: l10n.nicknameHint),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(l10n.enterBancone),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
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
            if (_entries.isEmpty)
              Text(l10n.sessionArchiveEmpty, textAlign: TextAlign.center)
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final completedLabel =
                        dateFormat.format(entry.completedAt.toLocal());
                    final report = _reportFor(entry);
                    final preview = _previewLines(report);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              entry.roomName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${entry.roomCode} · $completedLabel',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: const Color(AppColors.textSecondary),
                                  ),
                            ),
                            if (preview.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...preview.map(
                                (line) => Text(
                                  line,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 4,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _copyReport(context, report),
                                  icon: const Icon(Icons.copy_outlined, size: 18),
                                  label: Text(l10n.archiveCopyReport),
                                ),
                                TextButton.icon(
                                  onPressed: () => _createFromArchive(entry),
                                  icon: const Icon(Icons.playlist_add_outlined,
                                      size: 18),
                                  label: Text(l10n.archiveUseTemplate),
                                ),
                                TextButton.icon(
                                  onPressed: () => _deleteEntry(entry),
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  label: Text(l10n.archiveDeleteEntry),
                                ),
                                TextButton.icon(
                                  onPressed: () => SessionReportSheet.show(
                                    context,
                                    report,
                                  ),
                                  icon: const Icon(Icons.open_in_new_outlined,
                                      size: 18),
                                  label: Text(l10n.riepilogoSerata),
                                ),
                              ],
                            ),
                          ],
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
}
