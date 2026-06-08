import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/deck_values.dart';
import '../../core/feedback/session_feedback.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/voting/vote_stats.dart';
import 'vote_summary_panel.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../shared/widgets/error_snackbar.dart';
import '../../shared/widgets/section_header.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/bar_participants_strip.dart';
import '../../shared/widgets/participant_avatar.dart';
import '../../shared/widgets/spritz_card.dart';

class VotingPanel extends ConsumerStatefulWidget {
  const VotingPanel({
    super.key,
    required this.roomState,
    required this.participantId,
    required this.isFacilitator,
  });

  final RoomState roomState;
  final String participantId;
  final bool isFacilitator;

  @override
  ConsumerState<VotingPanel> createState() => _VotingPanelState();
}

class _VotingPanelState extends ConsumerState<VotingPanel>
    with TickerProviderStateMixin {
  String? _selectedValue;
  String? _finalEstimate;
  late AnimationController _revealController;
  Timer? _countdownTimer;
  DateTime _now = DateTime.now();
  bool _castVoteInFlight = false;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _syncFromState();
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void didUpdateWidget(VotingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roomState.room.votesRevealed !=
            widget.roomState.room.votesRevealed &&
        widget.roomState.room.votesRevealed) {
      if (MediaQuery.disableAnimationsOf(context)) {
        _revealController.value = 1;
      } else {
        _revealController.forward(from: 0);
      }
    }
    _syncFromState();
    _notifyAllVoted(oldWidget);
  }

  void _notifyAllVoted(VotingPanel oldWidget) {
    if (!widget.isFacilitator) return;
    final wasAllVoted = oldWidget.roomState.allParticipantsVoted;
    final isAllVoted = widget.roomState.allParticipantsVoted;
    if (!wasAllVoted && isAllVoted && widget.roomState.room.phase == RoomPhase.voting) {
      unawaited(SessionFeedback.onConsensusSuggested());
      HapticFeedback.mediumImpact();
      WidgetsBinding.instance.addPostFrameCallback((_) => _showAllVotedSnackbar());
    }
  }

  void _showAllVotedSnackbar() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.allVoted)),
    );
  }

  void _syncFromState() {
    final myVote = widget.roomState.currentVotes.firstWhereOrNull(
      (v) => v.participantId == widget.participantId,
    );
    if (myVote?.value != null && !widget.roomState.room.votesRevealed) {
      _selectedValue = myVote!.value;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _confirmAndCastVote(String value) async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.confirmVoteTitle(value)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.back),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.chooseDose),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _castVote(value);
    }
  }

  Future<void> _applyConsensusAndNext(String value) async {
    setState(() => _finalEstimate = value);
    await _confirmEstimate();
    await _nextStory();
  }

  Future<void> _castVote(String value) async {
    final story = widget.roomState.currentStory;
    if (story == null || _castVoteInFlight) return;

    setState(() {
      _selectedValue = value;
      _castVoteInFlight = true;
    });
    try {
      await ref.read(roomStateProvider.notifier).castVoteOptimistic(
            participantId: widget.participantId,
            storyId: story.id,
            value: value,
          );
    } catch (e, st) {
      if (mounted) {
        setState(() => _selectedValue = null);
        await showUserError(
          context,
          e,
          stackTrace: st,
          tags: const {'action': 'cast_vote'},
          roomPhase: widget.roomState.room.phase.name,
          isFacilitator: widget.isFacilitator,
        );
      }
    } finally {
      if (mounted) setState(() => _castVoteInFlight = false);
    }
  }

  Future<void> _reveal() async {
    try {
      await ref.read(roomRepositoryProvider).revealVotes(
            participantId: widget.participantId,
          );
    } catch (e, st) {
      if (mounted) {
        await showUserError(context, e, stackTrace: st, tags: {'action': 'cast_vote'});
      }
    }
  }

  Future<void> _reset() async {
    setState(() => _selectedValue = null);
    try {
      await ref.read(roomRepositoryProvider).resetVotes(
            participantId: widget.participantId,
          );
    } catch (e, st) {
      if (mounted) {
        await showUserError(context, e, stackTrace: st, tags: {'action': 'cast_vote'});
      }
    }
  }

  Future<void> _confirmEstimate() async {
    final story = widget.roomState.currentStory;
    if (story == null || _finalEstimate == null) return;
    try {
      await ref.read(roomRepositoryProvider).setFinalEstimate(
            participantId: widget.participantId,
            storyId: story.id,
            estimate: _finalEstimate!,
          );
    } catch (e, st) {
      if (mounted) {
        await showUserError(context, e, stackTrace: st, tags: {'action': 'cast_vote'});
      }
    }
  }

  Future<void> _nextStory() async {
    setState(() {
      _selectedValue = null;
      _finalEstimate = null;
    });
    try {
      await ref.read(roomRepositoryProvider).nextStory(
            participantId: widget.participantId,
          );
      final updated = ref.read(roomStateProvider).valueOrNull;
      if (updated != null &&
          updated.stories.any((s) => s.status == StoryStatus.done)) {
        await AppPreferences.markSessionCompleted();
      }
    } catch (e, st) {
      if (mounted) {
        await showUserError(context, e, stackTrace: st, tags: {'action': 'cast_vote'});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final story = widget.roomState.currentStory;
    if (story == null) {
      return Center(
        child: Text(
          l10n.noActiveStory,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final revealed = widget.roomState.room.votesRevealed;
    final isVoting = widget.roomState.room.phase == RoomPhase.voting;
    final myVote = widget.roomState.currentVotes.firstWhereOrNull(
      (v) => v.participantId == widget.participantId,
    );
    final me = widget.roomState.participants.firstWhereOrNull(
      (p) => p.id == widget.participantId,
    );
    if (me?.isObserver == true && isVoting && !revealed) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            l10n.observerCannotVote,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      );
    }

    final voteStats = computeVoteStats(
      votes: widget.roomState.currentVotes,
      participants: widget.roomState.activeVotingParticipants,
    );
    final deadline = widget.roomState.room.votingDeadlineAt;
    final timerExpired = deadline != null && _now.isAfter(deadline);

    final showGuestVotes = isVoting && !revealed;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BarOrderTicket(
            label: l10n.currentStoryLabel,
            title: story.title,
            description: story.description,
          ),
          if (showGuestVotes) ...[
            const SizedBox(height: 16),
            BarParticipantsStrip(
              roomState: widget.roomState,
              showVoteStatus: true,
            ),
          ],
          if (deadline != null && isVoting && !revealed) ...[
            const SizedBox(height: 12),
            _VotingCountdown(deadline: deadline, now: _now),
            if (timerExpired)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  l10n.timerScaduto,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(AppColors.spritzOrange),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
          ],
          if (isVoting && !revealed) ...[
            const SizedBox(height: 16),
            _VoteProgressBar(stats: voteStats),
          ],
          const SizedBox(height: 24),
          if (revealed) ...[
            _buildRevealContent(
              voteStats: voteStats,
            ),
          ] else ...[
            SectionHeader(
              title: l10n.chooseDose,
              subtitle: l10n.chooseDoseSubtitle,
            ),
            const SizedBox(height: 12),
            _BarDeckTray(
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: DeckValues.forRoom(widget.roomState.room).map((value) {
                  return SpritzCard(
                    value: value,
                    selected: _selectedValue == value || myVote?.value == value,
                    onTap: () => _castVote(value),
                    onLongPress: revealed
                        ? null
                        : () => unawaited(_confirmAndCastVote(value)),
                    disabled: revealed,
                  );
                }).toList(),
              ),
            ),
            if (_selectedValue != null || myVote?.value != null) ...[
              const SizedBox(height: 16),
              Text(
                l10n.voteSubmitted,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
          const SizedBox(height: 24),
          if (widget.isFacilitator) ...[
            if (isVoting && !revealed) ...[
              if (widget.roomState.allParticipantsVoted)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.allVoted,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(AppColors.success),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              FilledButton.icon(
                onPressed: _reveal,
                icon: const Icon(Icons.celebration_outlined),
                label: Text(l10n.servizio),
              ),
            ],
            if (revealed) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: Text(l10n.resetRound),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _finalEstimate != null ? _confirmEstimate : null,
                      child: Text(l10n.confirmEstimate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _nextStory,
                child: Text(l10n.nextOrdine),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildRevealContent({required VoteStats voteStats}) {
    final section = _RevealSection(
      roomState: widget.roomState,
      voteStats: voteStats,
      finalEstimate: _finalEstimate,
      onSelectEstimate: (v) => setState(() => _finalEstimate = v),
      isFacilitator: widget.isFacilitator,
      onApplyConsensus: widget.isFacilitator &&
              voteStats.suggestedConsensus != null
          ? () => _applyConsensusAndNext(voteStats.suggestedConsensus!)
          : null,
    );

    if (MediaQuery.disableAnimationsOf(context)) {
      return section;
    }

    return FadeTransition(
      opacity: _revealController,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1).animate(
          CurvedAnimation(
            parent: _revealController,
            curve: Curves.elasticOut,
          ),
        ),
        child: section,
      ),
    );
  }
}

/// Ticket ordine corrente (stile comanda bancone).
class _BarOrderTicket extends StatelessWidget {
  const _BarOrderTicket({
    required this.label,
    required this.title,
    required this.description,
  });

  final String label;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
        border: Border.all(
          color: scheme.primary.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.65),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppDecorations.radiusLg - 1),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarDeckTray extends StatelessWidget {
  const _BarDeckTray({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  const Color(0xFF2E2A28),
                  scheme.surfaceContainerLow,
                ]
              : [
                  const Color(0xFFEBE0D4),
                  const Color(0xFFF7F2EC),
                ],
        ),
        borderRadius: BorderRadius.circular(AppDecorations.radiusXl),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.style_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.barDeckTrayTitle,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _VotingCountdown extends StatelessWidget {
  const _VotingCountdown({required this.deadline, required this.now});

  final DateTime deadline;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final remaining = deadline.difference(now);
    final expired = remaining.isNegative;
    final display = expired
        ? Duration.zero
        : Duration(seconds: remaining.inSeconds);

    final minutes = display.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = display.inSeconds.remainder(60).toString().padLeft(2, '0');

    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 18,
          color: expired ? scheme.primary : scheme.onSurfaceVariant,
        ),
        const SizedBox(width: 6),
        Text(
          '$minutes:$seconds',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
                color: expired ? scheme.primary : scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(width: 6),
        Text(
          l10n.timerLabel,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _VoteProgressBar extends StatelessWidget {
  const _VoteProgressBar({required this.stats});

  final VoteStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${stats.votedCount}/${stats.participantCount} ${l10n.dosiScelte}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (stats.votedCount == stats.participantCount &&
                stats.participantCount > 0)
              Text(
                l10n.allVoted,
                style: TextStyle(
                  color: const Color(AppColors.success),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: stats.voteProgress,
            minHeight: 10,
            backgroundColor: scheme.surfaceContainerLow,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }
}

class _RevealSection extends StatelessWidget {
  const _RevealSection({
    required this.roomState,
    required this.voteStats,
    required this.finalEstimate,
    required this.onSelectEstimate,
    required this.isFacilitator,
    this.onApplyConsensus,
  });

  final RoomState roomState;
  final VoteStats voteStats;
  final String? finalEstimate;
  final ValueChanged<String> onSelectEstimate;
  final bool isFacilitator;
  final VoidCallback? onApplyConsensus;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      liveRegion: true,
      child: Column(
      children: [
        Text(
          l10n.votesRevealed,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: roomState.participants.map((p) {
            final vote = roomState.currentVotes.firstWhereOrNull(
              (v) => v.participantId == p.id,
            );
            return Column(
              children: [
                ParticipantAvatar(
                  nickname: p.nickname,
                  isFacilitator: p.isFacilitator,
                  isObserver: p.isObserver,
                  role: p.role,
                ),
                const SizedBox(height: 8),
                if (vote?.value != null)
                  SpritzCard(
                    value: vote!.value!,
                    selected: false,
                    onTap: () {},
                    revealed: true,
                    disabled: true,
                  )
                else
                  const Text('—'),
              ],
            );
          }).toList(),
        ),
        if (onApplyConsensus != null && voteStats.suggestedConsensus != null) ...[
          const SizedBox(height: 16),
          MaterialBanner(
            backgroundColor: const Color(AppColors.primarySoft),
            content: Text(
              '${l10n.consensoSuggerito}: ${voteStats.suggestedConsensus}',
            ),
            actions: [
              TextButton(
                onPressed: onApplyConsensus,
                child: Text(
                  l10n.applyConsensusAndNext(voteStats.suggestedConsensus!),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        VoteSummaryPanel(stats: voteStats),
        if (isFacilitator) ...[
          const SizedBox(height: 24),
          Text(
            l10n.finalEstimateLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: DeckValues.forRoom(roomState.room)
                .where((v) => v != '?' && v != '☕')
                .map((value) {
              return ChoiceChip(
                label: Text(value),
                selected: finalEstimate == value,
                onSelected: (_) => onSelectEstimate(value),
              );
            }).toList(),
          ),
        ],
      ],
      ),
    );
  }
}
