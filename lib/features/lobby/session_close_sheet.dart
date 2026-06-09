import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/export/session_report.dart';
import '../../core/export/session_report_stats.dart';
import '../../core/errors/user_facing_error.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
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

  SessionSummaryStats get _summary =>
      SessionSummaryStats.fromRoomState(widget.roomState);

  Future<void> _copyExport() async {
    final retro = _retroController.text.trim();
    final buffer = StringBuffer(_report.toMarkdown());
    if (retro.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## ${context.l10n.sessionCloseRetroLabel}')
        ..writeln(retro);
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
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
          SnackBar(
            content: Text(userFacingMessage(e, l10n: context.l10n)),
          ),
        );
      }
    }
  }

  String _formatDuration(BuildContext context, Duration duration) {
    final l10n = context.l10n;
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return l10n.closeSummaryDurationMinutes(minutes);
    }
    return l10n.closeSummaryDurationHours(minutes ~/ 60, minutes % 60);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final summary = _summary;
    final scheme = Theme.of(context).colorScheme;

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
            const SizedBox(height: 16),
            DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
                border: Border.all(
                  color: scheme.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.closeSummaryTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(AppColors.spritzOrangeDark),
                          ),
                    ),
                    const SizedBox(height: 12),
                    _SummaryLine(
                      icon: Icons.receipt_long_outlined,
                      text: l10n.closeSummaryStories(summary.estimatedOrders),
                    ),
                    const SizedBox(height: 8),
                    _SummaryLine(
                      icon: Icons.schedule_outlined,
                      text: _formatDuration(context, summary.sessionDuration),
                    ),
                    const SizedBox(height: 8),
                    _SummaryLine(
                      icon: Icons.groups_outlined,
                      text: l10n.closeSummaryParticipants(
                        summary.participantCount,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
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

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}
