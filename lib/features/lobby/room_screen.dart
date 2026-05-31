import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/session_constants.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/models/connection_status.dart';
import '../../shared/widgets/connection_banner.dart';
import '../../core/errors/user_facing_error.dart';
import '../../core/export/session_report.dart';
import '../../shared/widgets/error_snackbar.dart';
import '../../shared/widgets/participant_avatar.dart';
import 'session_report_sheet.dart';
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

  Future<void> _leaveAndGoHome() async {
    ref.read(roomStateProvider.notifier).leaveRoom();
    await ref.read(sessionProvider.notifier).clearSession();
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final roomStateAsync = ref.watch(roomStateProvider);
    final session = ref.watch(sessionProvider).valueOrNull;
    final isFacilitator = ref.watch(isFacilitatorProvider);
    final connectionStatus = ref.watch(connectionStatusProvider).valueOrNull ??
        ConnectionStatus.connected;

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
              Text(userFacingMessage(e)),
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

        final stillInRoom = roomState.participants.any(
          (p) => p.id == session.participantId,
        );
        if (!stillInRoom) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => unawaited(_leaveAndGoHome()),
          );
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final room = roomState.room;
        final showVoting = room.phase == RoomPhase.voting ||
            room.phase == RoomPhase.revealed;

        final showConnectionBanner =
            connectionStatus != ConnectionStatus.connected;

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
              if (isFacilitator)
                IconButton(
                  icon: const Icon(Icons.summarize_outlined),
                  tooltip: AppStrings.riepilogoSerata,
                  onPressed: () => SessionReportSheet.show(
                    context,
                    SessionReport.fromRoomState(roomState),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Lascia il locale',
                onPressed: () => unawaited(_leaveAndGoHome()),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showConnectionBanner)
                ConnectionBanner(
                  status: connectionStatus,
                  onRefresh: () =>
                      ref.read(roomStateProvider.notifier).refresh(),
                ),
              Expanded(
                child: LayoutBuilder(
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
              ),
            ],
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

class _ParticipantsRow extends ConsumerWidget {
  const _ParticipantsRow({required this.roomState});

  final RoomState roomState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showVoteStatus = roomState.room.phase == RoomPhase.voting &&
        !roomState.room.votesRevealed;
    final session = ref.watch(sessionProvider).valueOrNull;
    final isFacilitator = ref.watch(isFacilitatorProvider);

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
                final canManage = isFacilitator &&
                    session != null &&
                    p.id != session.participantId;
                return ParticipantAvatar(
                  nickname: p.nickname,
                  isFacilitator: p.isFacilitator,
                  showVoteStatus: showVoteStatus,
                  hasVoted: roomState.hasParticipantVoted(p.id),
                  isAbsent: p.isAbsent(
                    now: DateTime.now(),
                    thresholdSeconds: SessionConstants.absenceThresholdSeconds,
                  ),
                  onLongPress: canManage
                      ? () => _showParticipantActions(
                            context,
                            ref,
                            barmanId: session.participantId,
                            target: p,
                          )
                      : null,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _LobbyPanel extends ConsumerStatefulWidget {
  const _LobbyPanel({
    required this.roomState,
    required this.isFacilitator,
    required this.participantId,
  });

  final RoomState roomState;
  final bool isFacilitator;
  final String participantId;

  @override
  ConsumerState<_LobbyPanel> createState() => _LobbyPanelState();
}

class _LobbyPanelState extends ConsumerState<_LobbyPanel> {
  Timer? _reorderDebounce;
  List<String>? _localOrder;

  @override
  void dispose() {
    _reorderDebounce?.cancel();
    super.dispose();
  }

  List<Story> get _pendingStories {
    final stories = widget.roomState.stories
        .where((s) => s.status == StoryStatus.pending)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (_localOrder != null) {
      final byId = {for (final s in stories) s.id: s};
      return _localOrder!
          .where(byId.containsKey)
          .map((id) => byId[id]!)
          .toList();
    }
    return stories;
  }

  List<Story> get _activeStories => widget.roomState.stories
      .where((s) => s.status == StoryStatus.voting || s.status == StoryStatus.revealed)
      .toList()
    ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  void _scheduleReorder(List<Story> ordered) {
    _reorderDebounce?.cancel();
    _reorderDebounce = Timer(
      const Duration(milliseconds: 300),
      () => unawaited(_persistReorder(ordered)),
    );
  }

  Future<void> _persistReorder(List<Story> ordered) async {
    try {
      await ref.read(roomRepositoryProvider).reorderStories(
            participantId: widget.participantId,
            storyIds: ordered.map((s) => s.id).toList(),
          );
      if (!mounted) return;
      setState(() => _localOrder = null);
    } catch (e, st) {
      if (!mounted) return;
      setState(() => _localOrder = null);
      await showUserError(context, e, stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pendingStories = _pendingStories;
    final activeStories = _activeStories;
    final canReorder = widget.isFacilitator &&
        widget.roomState.room.phase == RoomPhase.lobby &&
        pendingStories.length > 1;

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
              if (canReorder) ...[
                const SizedBox(height: 8),
                Text(
                  AppStrings.modificaOrdineHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(AppColors.textSecondary),
                      ),
                ),
              ],
              const SizedBox(height: 16),
              if (pendingStories.isEmpty && activeStories.isEmpty)
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
              else ...[
                ...activeStories.map(
                  (story) => _StoryTile(
                    story: story,
                    isFacilitator: widget.isFacilitator,
                    participantId: widget.participantId,
                    onStartVoting: () => _showStartVotingDialog(
                      context,
                      ref,
                      widget.participantId,
                      story.id,
                    ),
                    onRemove: () => _removeStory(
                      context,
                      ref,
                      widget.participantId,
                      story.id,
                    ),
                    onEdit: null,
                    showDragHandle: false,
                  ),
                ),
                if (canReorder)
                  ReorderableListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    buildDefaultDragHandles: false,
                    itemCount: pendingStories.length,
                    onReorder: (oldIndex, newIndex) {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final updated = List<Story>.from(pendingStories);
                      final item = updated.removeAt(oldIndex);
                      updated.insert(newIndex, item);
                      setState(() => _localOrder = updated.map((s) => s.id).toList());
                      _scheduleReorder(updated);
                    },
                    itemBuilder: (context, index) {
                      final story = pendingStories[index];
                      return _StoryTile(
                        key: ValueKey(story.id),
                        story: story,
                        isFacilitator: widget.isFacilitator,
                        participantId: widget.participantId,
                        onStartVoting: () => _showStartVotingDialog(
                          context,
                          ref,
                          widget.participantId,
                          story.id,
                        ),
                        onRemove: () => _removeStory(
                          context,
                          ref,
                          widget.participantId,
                          story.id,
                        ),
                        onEdit: () => _showEditStoryDialog(
                          context,
                          ref,
                          widget.participantId,
                          story,
                        ),
                        showDragHandle: true,
                        dragIndex: index,
                      );
                    },
                  )
                else
                  ...pendingStories.map(
                    (story) => _StoryTile(
                      story: story,
                      isFacilitator: widget.isFacilitator,
                      participantId: widget.participantId,
                      onStartVoting: () => _showStartVotingDialog(
                        context,
                        ref,
                        widget.participantId,
                        story.id,
                      ),
                      onRemove: () => _removeStory(
                        context,
                        ref,
                        widget.participantId,
                        story.id,
                      ),
                      onEdit: widget.isFacilitator
                          ? () => _showEditStoryDialog(
                                context,
                                ref,
                                widget.participantId,
                                story,
                              )
                          : null,
                      showDragHandle: false,
                    ),
                  ),
              ],
              if (!widget.isFacilitator) ...[
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
}

class _StoryTile extends StatelessWidget {
  const _StoryTile({
    super.key,
    required this.story,
    required this.isFacilitator,
    required this.participantId,
    required this.onStartVoting,
    required this.onRemove,
    required this.onEdit,
    required this.showDragHandle,
    this.dragIndex = 0,
  });

  final Story story;
  final bool isFacilitator;
  final String participantId;
  final VoidCallback onStartVoting;
  final VoidCallback onRemove;
  final VoidCallback? onEdit;
  final bool showDragHandle;
  final int dragIndex;

  @override
  Widget build(BuildContext context) {
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
          subtitle: story.description.isNotEmpty ? Text(story.description) : null,
          trailing: isFacilitator && story.status == StoryStatus.pending
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showDragHandle)
                      ReorderableDragStartListener(
                        index: dragIndex,
                        child: const Icon(Icons.drag_handle),
                      ),
                    if (onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: AppStrings.modificaOrdine,
                        onPressed: onEdit,
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onRemove,
                    ),
                    FilledButton(
                      onPressed: onStartVoting,
                      child: const Text(AppStrings.startVoting),
                    ),
                  ],
                )
              : story.finalEstimate != null
                  ? Chip(
                      label: Text('${story.finalEstimate} pt'),
                      backgroundColor: const Color(AppColors.primarySoft),
                    )
                  : null,
        ),
      ),
    );
  }
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
    } catch (e, st) {
      if (context.mounted) {
        await showUserError(context, e, stackTrace: st);
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
  } catch (e, st) {
    if (context.mounted) {
      await showUserError(context, e, stackTrace: st);
    }
  }
}

Future<void> _confirmTransferBarman(
  BuildContext context,
  WidgetRef ref, {
  required String fromParticipantId,
  required Participant toParticipant,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(AppStrings.passaBancone),
      content: Text(
        AppStrings.confermaPassaBancone(toParticipant.nickname),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(AppStrings.passaBancone),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    await ref.read(roomRepositoryProvider).transferFacilitator(
          fromParticipantId: fromParticipantId,
          toParticipantId: toParticipant.id,
        );
  } catch (e, st) {
    if (context.mounted) {
      await showUserError(context, e, stackTrace: st);
    }
  }
}

Future<void> _showEditStoryDialog(
  BuildContext context,
  WidgetRef ref,
  String participantId,
  Story story,
) async {
  final titleController = TextEditingController(text: story.title);
  final descController = TextEditingController(text: story.description);

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(AppStrings.modificaOrdine),
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
          child: const Text(AppStrings.salvaOrdine),
        ),
      ],
    ),
  );

  if (result == true && titleController.text.trim().isNotEmpty) {
    try {
      await ref.read(roomRepositoryProvider).updateStory(
            participantId: participantId,
            storyId: story.id,
            title: titleController.text.trim(),
            description: descController.text.trim(),
          );
    } catch (e, st) {
      if (context.mounted) {
        await showUserError(context, e, stackTrace: st);
      }
    }
  }

  titleController.dispose();
  descController.dispose();
}

Future<void> _showStartVotingDialog(
  BuildContext context,
  WidgetRef ref,
  String participantId,
  String storyId,
) async {
  int? durationSeconds;

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text(AppStrings.scegliTimer),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text(AppStrings.timerNone),
              selected: durationSeconds == null,
              onSelected: (_) => setState(() => durationSeconds = null),
            ),
            ChoiceChip(
              label: const Text(AppStrings.timer2Min),
              selected: durationSeconds == 120,
              onSelected: (_) => setState(() => durationSeconds = 120),
            ),
            ChoiceChip(
              label: const Text(AppStrings.timer5Min),
              selected: durationSeconds == 300,
              onSelected: (_) => setState(() => durationSeconds = 300),
            ),
            ChoiceChip(
              label: const Text(AppStrings.timer10Min),
              selected: durationSeconds == 600,
              onSelected: (_) => setState(() => durationSeconds = 600),
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
            child: const Text(AppStrings.startVoting),
          ),
        ],
      ),
    ),
  );

  if (confirmed != true) return;

  try {
    await ref.read(roomRepositoryProvider).startVoting(
          participantId: participantId,
          storyId: storyId,
          durationSeconds: durationSeconds,
        );
  } catch (e, st) {
    if (context.mounted) {
      await showUserError(context, e, stackTrace: st);
    }
  }
}

Future<void> _showParticipantActions(
  BuildContext context,
  WidgetRef ref, {
  required String barmanId,
  required Participant target,
}) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(AppStrings.azioniCliente),
            subtitle: Text(target.nickname),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text(AppStrings.passaBancone),
            onTap: () => Navigator.pop(ctx, 'transfer'),
          ),
          ListTile(
            leading: const Icon(Icons.person_remove_outlined),
            title: const Text(AppStrings.rimuoviDalBancone),
            onTap: () => Navigator.pop(ctx, 'remove'),
          ),
        ],
      ),
    ),
  );

  if (!context.mounted) return;

  if (action == 'transfer') {
    await _confirmTransferBarman(
      context,
      ref,
      fromParticipantId: barmanId,
      toParticipant: target,
    );
  } else if (action == 'remove') {
    await _confirmRemoveParticipant(
      context,
      ref,
      barmanId: barmanId,
      target: target,
    );
  }
}

Future<void> _confirmRemoveParticipant(
  BuildContext context,
  WidgetRef ref, {
  required String barmanId,
  required Participant target,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(AppStrings.rimuoviDalBancone),
      content: Text(AppStrings.confermaRimuovi(target.nickname)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(AppStrings.rimuoviDalBancone),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  try {
    await ref.read(roomRepositoryProvider).removeParticipant(
          barmanId: barmanId,
          targetId: target.id,
        );
  } catch (e, st) {
    if (context.mounted) {
      await showUserError(context, e, stackTrace: st);
    }
  }
}
