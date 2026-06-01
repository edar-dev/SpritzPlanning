import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/error_snackbar.dart';

class ConfidencePanel extends ConsumerWidget {
  const ConfidencePanel({
    super.key,
    required this.roomState,
    required this.participantId,
    required this.isFacilitator,
  });

  final RoomState roomState;
  final String participantId;
  final bool isFacilitator;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (!roomState.room.confidenceRoundActive) return const SizedBox.shrink();

    final me = roomState.participants
        .where((p) => p.id == participantId)
        .firstOrNull;
    if (me?.isObserver ?? true) return const SizedBox.shrink();

    final (voted, total) = roomState.confidenceProgress;
    final myVote = roomState.currentConfidenceVotes
        .where((v) => v.participantId == participantId)
        .firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.confidenceVoteTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.confidenceVoteSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(AppColors.textSecondary),
                  ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: total == 0 ? 0 : voted / total,
              color: const Color(AppColors.spritzOrange),
            ),
            const SizedBox(height: 4),
            Text(l10n.confidenceVoteProgress(voted, total)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final value = index + 1;
                final selected = myVote?.value == value;
                return IconButton.filledTonal(
                  isSelected: selected,
                  onPressed: () => _cast(
                    context,
                    ref,
                    value,
                  ),
                  icon: Text('$value'),
                );
              }),
            ),
            if (isFacilitator) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _end(context, ref),
                  child: Text(l10n.confidenceVoteClose),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _cast(BuildContext context, WidgetRef ref, int value) async {
    try {
      await ref.read(roomRepositoryProvider).castConfidenceVote(
            participantId: participantId,
            value: value,
          );
      await ref.read(roomStateProvider.notifier).refresh();
    } catch (e, st) {
      if (!context.mounted) return;
      await showUserError(context, e, stackTrace: st);
    }
  }

  Future<void> _end(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(roomRepositoryProvider).endConfidenceVote(
            participantId: participantId,
          );
      await ref.read(roomStateProvider.notifier).refresh();
    } catch (e, st) {
      if (!context.mounted) return;
      await showUserError(context, e, stackTrace: st);
    }
  }
}
