import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/error_snackbar.dart';
import '../../shared/widgets/section_header.dart';

/// Lista ordini compatta per il barman durante la votazione.
class CompactOrderList extends ConsumerWidget {
  const CompactOrderList({
    super.key,
    required this.roomState,
    required this.participantId,
  });

  final RoomState roomState;
  final String participantId;

  List<Story> get _openStories {
    return roomState.stories
        .where(
          (s) =>
              s.status != StoryStatus.done && s.kind != StoryKind.spike,
        )
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stories = _openStories;
    if (stories.isEmpty) return const SizedBox.shrink();

    final currentId = roomState.room.currentStoryId;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: l10n.menu,
          subtitle: l10n.menuCompactHint,
        ),
        const SizedBox(height: 8),
        ...stories.map((story) {
          final isCurrent = story.id == currentId;
          final scheme = Theme.of(context).colorScheme;

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Material(
              color: isCurrent
                  ? scheme.primaryContainer.withValues(alpha: 0.45)
                  : scheme.surface,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: isCurrent
                    ? null
                    : () => _onTapStory(context, ref, story),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent
                          ? scheme.primary
                          : scheme.outline.withValues(alpha: 0.6),
                      width: isCurrent ? 1.5 : 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCurrent
                            ? Icons.local_bar_rounded
                            : Icons.receipt_long_outlined,
                        size: 18,
                        color: isCurrent
                            ? scheme.primary
                            : scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          story.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: isCurrent
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                        ),
                      ),
                      if (isCurrent)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            l10n.currentStoryLabel,
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _onTapStory(
    BuildContext context,
    WidgetRef ref,
    Story target,
  ) async {
    final l10n = context.l10n;
    final current = roomState.currentStory;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.switchOrderTitle),
        content: Text(
          l10n.switchOrderMessage(
            current?.title ?? l10n.noActiveStory,
            target.title,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.switchOrderConfirm),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(roomRepositoryProvider).startVoting(
            participantId: participantId,
            storyId: target.id,
          );
    } catch (e, st) {
      if (context.mounted) {
        await showUserError(context, e, stackTrace: st);
      }
    }
  }
}
