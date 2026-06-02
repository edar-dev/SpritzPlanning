import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/export/session_report.dart';
import '../../core/export/session_report_stats.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';

class SessionCloseSheet extends ConsumerStatefulWidget {
  const SessionCloseSheet({
    super.key,
    required this.roomState,
    required this.participantId,
    required this.onLeave,
  });

  final RoomState roomState;
  final String participantId;
  final VoidCallback onLeave;

  static Future<void> show(
    BuildContext context, {
    required RoomState roomState,
    required String participantId,
    required VoidCallback onLeave,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SessionCloseSheet(
        roomState: roomState,
        participantId: participantId,
        onLeave: onLeave,
      ),
    );
  }

  @override
  ConsumerState<SessionCloseSheet> createState() => _SessionCloseSheetState();
}

class _SessionCloseSheetState extends ConsumerState<SessionCloseSheet> {
  final _retroController = TextEditingController();

  @override
  void dispose() {
    _retroController.dispose();
    super.dispose();
  }

  SessionReport get _report => SessionReport.fromRoomState(
        widget.roomState,
        includeFacilitatorNotes: true,
      );

  SessionReportStats get _stats =>
      SessionReportStats.fromRoomState(widget.roomState);

  Future<void> _copyExport() async {
    final md = '${_report.toMarkdown(retroNotes: _retroController.text)}\n${_stats.toMarkdownKpiBlock()}';
    await Clipboard.setData(ClipboardData(text: md));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.reportCopied)),
      );
    }
  }

  Future<void> _duplicate() async {
    final session = ref.read(sessionProvider).valueOrNull;
    if (session == null) return;
    try {
      final result = await ref.read(roomRepositoryProvider).duplicateRoom(
            participantId: session.participantId,
            sourceRoomId: session.roomId,
          );
      await ref.read(sessionProvider.notifier).saveSession(
            result,
            nickname: session.nickname,
          );
      ref.read(roomStateProvider.notifier).leaveRoom();
      await ref.read(roomStateProvider.notifier).enterRoom(
            result.roomId,
            result.participantId,
          );
      if (mounted) {
        Navigator.pop(context);
        context.go('/room/${result.roomId}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stats = _stats;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.paddingOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.sessionCloseTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text('${l10n.reportCompleted}: ${stats.completedCount}'),
            if (stats.medianPoints != null)
              Text('${l10n.reportMedian}: ${stats.medianPoints!.toStringAsFixed(1)}'),
            const SizedBox(height: 12),
            TextField(
              controller: _retroController,
              decoration: InputDecoration(
                labelText: l10n.sessionCloseRetroLabel,
                hintText: l10n.sessionCloseRetroHint,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _copyExport,
              icon: const Icon(Icons.copy_outlined),
              label: Text(l10n.sessionCloseExport),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _duplicate,
              icon: const Icon(Icons.copy_all_outlined),
              label: Text(l10n.sessionCloseDuplicate),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                widget.onLeave();
              },
              child: Text(l10n.sessionCloseLeave),
            ),
          ],
        ),
      ),
    );
  }
}
