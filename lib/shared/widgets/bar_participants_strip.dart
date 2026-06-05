import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/models/models.dart';

/// Bancone: partecipanti con stato voto leggibile (orizzontale o verticale).
class BarParticipantsStrip extends StatelessWidget {
  const BarParticipantsStrip({
    super.key,
    required this.roomState,
    required this.showVoteStatus,
    this.layout = BarParticipantsLayout.horizontal,
    this.onParticipantLongPress,
  });

  final RoomState roomState;
  final bool showVoteStatus;
  final BarParticipantsLayout layout;
  final void Function(Participant participant)? onParticipantLongPress;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final (voted, total) = roomState.votingProgress;
    final hideVotes = roomState.room.hideVotersUntilReveal && showVoteStatus;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primaryContainer.withValues(alpha: 0.35),
            scheme.surfaceContainerLow,
          ],
        ),
        borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_bar_rounded,
                  size: 20,
                  color: scheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.clienti,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                if (showVoteStatus && total > 0)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: voted == total
                          ? const Color(AppColors.success)
                              .withValues(alpha: 0.15)
                          : scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: voted == total
                            ? const Color(AppColors.success)
                                .withValues(alpha: 0.5)
                            : scheme.outline,
                      ),
                    ),
                    child: Text(
                      '$voted/$total ${l10n.dosiScelte}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: voted == total
                                ? const Color(AppColors.success)
                                : scheme.onSurface,
                          ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (layout == BarParticipantsLayout.horizontal)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _chipList(
                    context,
                    hideVotes: hideVotes,
                  ),
                ),
              )
            else
              ..._chipList(context, hideVotes: hideVotes),
          ],
        ),
      ),
    );
  }

  List<Widget> _chipList(
    BuildContext context, {
    required bool hideVotes,
  }) {
    final spacing = layout == BarParticipantsLayout.horizontal ? 10.0 : 8.0;
    final chips = <Widget>[];
    for (final p in roomState.participants) {
      chips.add(
        _BarGuestChip(
          participant: p,
          hasVoted: roomState.hasParticipantVoted(p.id),
          showVoteStatus: showVoteStatus && !p.isObserver,
          hideVoteState: hideVotes,
          isFacilitator: p.isFacilitator,
          isObserver: p.isObserver,
          role: p.role,
          isAbsent: p.isAbsent(now: DateTime.now()),
          layout: layout,
          onLongPress: onParticipantLongPress == null
              ? null
              : () => onParticipantLongPress!(p),
        ),
      );
      if (p != roomState.participants.last) {
        chips.add(SizedBox(
          width: layout == BarParticipantsLayout.horizontal ? spacing : 0,
          height: layout == BarParticipantsLayout.vertical ? spacing : 0,
        ));
      }
    }
    return chips;
  }
}

enum BarParticipantsLayout { horizontal, vertical }

class _BarGuestChip extends StatelessWidget {
  const _BarGuestChip({
    required this.participant,
    required this.hasVoted,
    required this.showVoteStatus,
    required this.hideVoteState,
    required this.isFacilitator,
    required this.isObserver,
    required this.role,
    required this.isAbsent,
    required this.layout,
    this.onLongPress,
  });

  final Participant participant;
  final bool hasVoted;
  final bool showVoteStatus;
  final bool hideVoteState;
  final bool isFacilitator;
  final bool isObserver;
  final ParticipantRole role;
  final bool isAbsent;
  final BarParticipantsLayout layout;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initial = participant.nickname.isNotEmpty
        ? participant.nickname[0].toUpperCase()
        : '?';
    final accent = isFacilitator
        ? const Color(AppColors.spritzOrange)
        : const Color(AppColors.oliveGreen);

    final voted = hasVoted && showVoteStatus && !hideVoteState;
    final waiting = showVoteStatus && !hideVoteState && !hasVoted && !isObserver;

    final borderColor = isFacilitator
        ? scheme.primary.withValues(alpha: 0.6)
        : voted
            ? const Color(AppColors.success).withValues(alpha: 0.55)
            : waiting
                ? scheme.outline
                : scheme.outline.withValues(alpha: 0.5);

    final chip = Material(
      color: scheme.surfaceContainerLowest.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
      child: InkWell(
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
        child: Container(
          width: layout == BarParticipantsLayout.horizontal ? 148 : null,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
            border: Border.all(color: borderColor, width: isFacilitator ? 2 : 1),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: accent.withValues(alpha: 0.18),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      participant.nickname,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 4),
                    _RoleOrVoteStatus(
                      isFacilitator: isFacilitator,
                      isObserver: isObserver,
                      role: role,
                      isAbsent: isAbsent,
                      voted: voted,
                      waiting: waiting,
                      hideVoteState: hideVoteState && showVoteStatus,
                    ),
                  ],
                ),
              ),
              if (showVoteStatus && !isObserver && !hideVoteState)
                Icon(
                  voted
                      ? Icons.check_circle_rounded
                      : Icons.hourglass_empty_rounded,
                  size: 22,
                  color: voted
                      ? const Color(AppColors.success)
                      : scheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );

    return chip;
  }
}

class _RoleOrVoteStatus extends StatelessWidget {
  const _RoleOrVoteStatus({
    required this.isFacilitator,
    required this.isObserver,
    required this.role,
    required this.isAbsent,
    required this.voted,
    required this.waiting,
    required this.hideVoteState,
  });

  final bool isFacilitator;
  final bool isObserver;
  final ParticipantRole role;
  final bool isAbsent;
  final bool voted;
  final bool waiting;
  final bool hideVoteState;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    String label;
    Color bg;
    Color fg;

    if (isAbsent) {
      label = l10n.assente;
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
    } else if (isObserver) {
      label = l10n.observerBadge;
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
    } else if (isFacilitator) {
      label = l10n.barman;
      bg = const Color(AppColors.primarySoft);
      fg = const Color(AppColors.spritzOrangeDark);
    } else if (hideVoteState) {
      label = l10n.chooseDose;
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
    } else if (voted) {
      label = l10n.barVoteStatusOrdered;
      bg = const Color(AppColors.success).withValues(alpha: 0.12);
      fg = const Color(AppColors.success);
    } else if (waiting) {
      label = l10n.barVoteStatusWaiting;
      bg = scheme.primaryContainer.withValues(alpha: 0.4);
      fg = scheme.onPrimaryContainer;
    } else if (role == ParticipantRole.viewer) {
      label = l10n.viewerBadge;
      bg = scheme.surfaceContainerHighest;
      fg = scheme.onSurfaceVariant;
    } else {
      label = l10n.editorBadge;
      bg = const Color(AppColors.primarySoft).withValues(alpha: 0.5);
      fg = const Color(AppColors.oliveGreen);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
