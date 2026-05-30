import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_strings.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../shared/widgets/participant_avatar.dart';
import '../../shared/widgets/room_code_display.dart';
import '../../shared/widgets/section_header.dart';
import '../voting/voting_panel.dart';

class RoomScreen extends ConsumerStatefulWidget {
  const RoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends ConsumerState<RoomScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureRoomEntered());
  }

  Future<void> _ensureRoomEntered() async {
    final session = ref.read(sessionProvider).valueOrNull;
    final roomState = ref.read(roomStateProvider).valueOrNull;
    if (session != null && roomState == null) {
      await ref.read(roomStateProvider.notifier).enterRoom(
            session.roomId,
            session.participantId,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomStateAsync = ref.watch(roomStateProvider);
    final session = ref.watch(sessionProvider).valueOrNull;
    final isFacilitator = ref.watch(isFacilitatorProvider);

    return roomStateAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.appName)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$e'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/'),
                child: const Text('Torna alla home'),
              ),
            ],
          ),
        ),
      ),
      data: (roomState) {
        if (roomState == null || session == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go('/');
          });
          return const SizedBox.shrink();
        }

        final room = roomState.room;
        final showVoting = room.phase == RoomPhase.voting ||
            room.phase == RoomPhase.revealed;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(room.name),
                Text(
                  room.code,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: const Color(AppColors.textSecondary),
                        letterSpacing: 1.5,
                      ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Lascia il locale',
                onPressed: () async {
                  ref.read(roomStateProvider.notifier).leaveRoom();
                  await ref.read(sessionProvider.notifier).clearSession();
                  if (context.mounted) context.go('/');
                },
              ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 800;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 300,
                      decoration: const BoxDecoration(
                        color: Color(AppColors.surfaceMuted),
                        border: Border(
                          right: BorderSide(color: Color(AppColors.border)),
                        ),
                      ),
                      child: _Sidebar(
                        roomState: roomState,
                        isFacilitator: isFacilitator,
                        participantId: session.participantId,
                      ),
                    ),
                    Expanded(
                      child: showVoting
                          ? VotingPanel(
                              roomState: roomState,
                              participantId: session.participantId,
                              isFacilitator: isFacilitator,
                            )
                          : _LobbyPanel(
                              roomState: roomState,
                              isFacilitator: isFacilitator,
                              participantId: session.participantId,
                            ),
                    ),
                  ],
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RoomCodeDisplay(
                      code: room.code,
                      onShare: () => Share.share(
                        '${AppStrings.shareMessage} ${room.code}',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ParticipantsRow(roomState: roomState),
                    const SizedBox(height: 24),
                    if (showVoting)
                      VotingPanel(
                        roomState: roomState,
                        participantId: session.participantId,
                        isFacilitator: isFacilitator,
                      )
                    else
                      _LobbyPanel(
                        roomState: roomState,
                        isFacilitator: isFacilitator,
                        participantId: session.participantId,
                      ),
                  ],
                ),
              );
            },
          ),
          floatingActionButton: isFacilitator && !showVoting
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddStoryDialog(
                    context,
                    ref,
                    session.participantId,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text(AppStrings.addOrdine),
                )
              : null,
        );
      },
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.roomState,
    required this.isFacilitator,
    required this.participantId,
  });

  final RoomState roomState;
  final bool isFacilitator;
  final String participantId;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoomCodeDisplay(
            code: roomState.room.code,
            onShare: () => Share.share(
              '${AppStrings.shareMessage} ${roomState.room.code}',
            ),
          ),
          const SizedBox(height: 16),
          _ParticipantsRow(roomState: roomState),
        ],
      ),
    );
  }
}

class _ParticipantsRow extends StatelessWidget {
  const _ParticipantsRow({required this.roomState});

  final RoomState roomState;

  @override
  Widget build(BuildContext context) {
    final showVoteStatus = roomState.room.phase == RoomPhase.voting &&
        !roomState.room.votesRevealed;

    return DecoratedBox(
      decoration: AppDecorations.surfaceCard(radius: AppDecorations.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.clienti,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(AppColors.textSecondary),
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: roomState.participants.map((p) {
                return ParticipantAvatar(
                  nickname: p.nickname,
                  isFacilitator: p.isFacilitator,
                  showVoteStatus: showVoteStatus,
                  hasVoted: roomState.hasParticipantVoted(p.id),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LobbyPanel extends ConsumerWidget {
  const _LobbyPanel({
    required this.roomState,
    required this.isFacilitator,
    required this.participantId,
  });

  final RoomState roomState;
  final bool isFacilitator;
  final String participantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingStories = roomState.stories
        .where((s) => s.status != StoryStatus.done)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(
                title: AppStrings.menu,
                subtitle: 'Ordini da stimare con il team',
              ),
              const SizedBox(height: 16),
              if (pendingStories.isEmpty)
                DecoratedBox(
                  decoration: AppDecorations.surfaceCard(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 56,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: AppDecorations.iconBadge(
                              primary: false,
                            ),
                            child: const Icon(
                              Icons.receipt_long_outlined,
                              size: 32,
                              color: Color(AppColors.textSecondary),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.menuEmpty,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...pendingStories.map((story) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: DecoratedBox(
                  decoration: AppDecorations.surfaceCard(
                    radius: AppDecorations.radiusMd,
                  ),
                  child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: _statusColor(story.status).withValues(alpha: 0.12),
                    child: Icon(
                      _statusIcon(story.status),
                      color: _statusColor(story.status),
                      size: 20,
                    ),
                  ),
                  title: Text(story.title),
                  subtitle: story.description.isNotEmpty
                      ? Text(story.description)
                      : null,
                  trailing: isFacilitator && story.status == StoryStatus.pending
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _removeStory(
                                context,
                                ref,
                                participantId,
                                story.id,
                              ),
                            ),
                            FilledButton(
                              onPressed: () => _startVoting(
                                context,
                                ref,
                                participantId,
                                story.id,
                              ),
                              child: const Text(AppStrings.startVoting),
                            ),
                          ],
                        )
                      : story.finalEstimate != null
                          ? Chip(
                              label: Text('${story.finalEstimate} pt'),
                              backgroundColor:
                                  const Color(AppColors.primarySoft),
                            )
                          : null,
                ),
                ),
              );
            }),
              if (!isFacilitator) ...[
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    AppStrings.waitingAperitivo,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(StoryStatus status) {
    return switch (status) {
      StoryStatus.pending => Colors.grey,
      StoryStatus.voting => Colors.orange,
      StoryStatus.revealed => Colors.blue,
      StoryStatus.done => Colors.green,
    };
  }

  IconData _statusIcon(StoryStatus status) {
    return switch (status) {
      StoryStatus.pending => Icons.receipt_long,
      StoryStatus.voting => Icons.local_bar,
      StoryStatus.revealed => Icons.visibility,
      StoryStatus.done => Icons.check,
    };
  }
}

Future<void> _showAddStoryDialog(
  BuildContext context,
  WidgetRef ref,
  String participantId,
) async {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(AppStrings.addOrdine),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: const InputDecoration(labelText: AppStrings.ordineTitle),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descController,
            decoration: const InputDecoration(
              labelText: AppStrings.ordineDescription,
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Aggiungi'),
        ),
      ],
    ),
  );

  if (result == true && titleController.text.trim().isNotEmpty) {
    try {
      await ref.read(roomRepositoryProvider).addStory(
            participantId: participantId,
            title: titleController.text.trim(),
            description: descController.text.trim(),
          );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  titleController.dispose();
  descController.dispose();
}

Future<void> _removeStory(
  BuildContext context,
  WidgetRef ref,
  String participantId,
  String storyId,
) async {
  try {
    await ref.read(roomRepositoryProvider).removeStory(
          participantId: participantId,
          storyId: storyId,
        );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}

Future<void> _startVoting(
  BuildContext context,
  WidgetRef ref,
  String participantId,
  String storyId,
) async {
  try {
    await ref.read(roomRepositoryProvider).startVoting(
          participantId: participantId,
          storyId: storyId,
        );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
