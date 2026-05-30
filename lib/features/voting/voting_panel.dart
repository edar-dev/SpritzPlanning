import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/deck_values.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../shared/widgets/section_header.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
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
    with SingleTickerProviderStateMixin {
  String? _selectedValue;
  String? _finalEstimate;
  late AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _syncFromState();
  }

  @override
  void didUpdateWidget(VotingPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.roomState.room.votesRevealed !=
            widget.roomState.room.votesRevealed &&
        widget.roomState.room.votesRevealed) {
      _revealController.forward(from: 0);
    }
    _syncFromState();
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
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _castVote(String value) async {
    final story = widget.roomState.currentStory;
    if (story == null) return;

    setState(() => _selectedValue = value);
    try {
      await ref.read(roomRepositoryProvider).castVote(
            participantId: widget.participantId,
            storyId: story.id,
            value: value,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _reveal() async {
    try {
      await ref.read(roomRepositoryProvider).revealVotes(
            participantId: widget.participantId,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _reset() async {
    setState(() => _selectedValue = null);
    try {
      await ref.read(roomRepositoryProvider).resetVotes(
            participantId: widget.participantId,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
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
    final story = widget.roomState.currentStory;
    if (story == null) {
      return Center(
        child: Text(
          AppStrings.noActiveStory,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final revealed = widget.roomState.room.votesRevealed;
    final isVoting = widget.roomState.room.phase == RoomPhase.voting;
    final myVote = widget.roomState.currentVotes.firstWhereOrNull(
      (v) => v.participantId == widget.participantId,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: AppDecorations.surfaceCard(highlight: true),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ordine corrente',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color(AppColors.textSecondary),
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    story.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(AppColors.textPrimary),
                        ),
                  ),
                  if (story.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      story.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (revealed) ...[
            FadeTransition(
              opacity: _revealController,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1).animate(
                  CurvedAnimation(
                    parent: _revealController,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: _RevealSection(
                  roomState: widget.roomState,
                  finalEstimate: _finalEstimate,
                  onSelectEstimate: (v) => setState(() => _finalEstimate = v),
                  isFacilitator: widget.isFacilitator,
                ),
              ),
            ),
          ] else ...[
            SectionHeader(
              title: AppStrings.chooseDose,
              subtitle: 'Seleziona la dose per questo ordine',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: DeckValues.values.map((value) {
                return SpritzCard(
                  value: value,
                  selected: _selectedValue == value || myVote?.value == value,
                  onTap: () => _castVote(value),
                  disabled: revealed,
                );
              }).toList(),
            ),
            if (_selectedValue != null || myVote?.value != null) ...[
              const SizedBox(height: 16),
              Text(
                AppStrings.voteSubmitted,
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
                    AppStrings.allVoted,
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
                label: const Text(AppStrings.servizio),
              ),
            ],
            if (revealed) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _reset,
                      child: const Text(AppStrings.resetRound),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _finalEstimate != null ? _confirmEstimate : null,
                      child: const Text(AppStrings.confirmEstimate),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _nextStory,
                child: const Text(AppStrings.nextOrdine),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _RevealSection extends StatelessWidget {
  const _RevealSection({
    required this.roomState,
    required this.finalEstimate,
    required this.onSelectEstimate,
    required this.isFacilitator,
  });

  final RoomState roomState;
  final String? finalEstimate;
  final ValueChanged<String> onSelectEstimate;
  final bool isFacilitator;

  @override
  Widget build(BuildContext context) {
    final voteCounts = <String, int>{};
    for (final vote in roomState.currentVotes) {
      if (vote.value != null) {
        voteCounts[vote.value!] = (voteCounts[vote.value!] ?? 0) + 1;
      }
    }

    return Column(
      children: [
        Text(
          AppStrings.votesRevealed,
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
        if (voteCounts.isNotEmpty) ...[
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            children: voteCounts.entries.map((e) {
              return Chip(
                avatar: CircleAvatar(
                  child: Text('${e.value}', style: const TextStyle(fontSize: 12)),
                ),
                label: Text('${e.key} (${DeckValues.label(e.key)})'),
              );
            }).toList(),
          ),
        ],
        if (isFacilitator) ...[
          const SizedBox(height: 24),
          Text(
            AppStrings.finalEstimateLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: DeckValues.values
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
    );
  }
}
