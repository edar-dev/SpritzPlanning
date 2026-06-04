import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/l10n_extensions.dart';
import 'room_deck_settings_sheet.dart';
import 'story_import_sheet.dart';
import '../voting/facilitator_shortcuts.dart';
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
import '../../core/export/session_report_stats.dart';
import '../../core/feedback/session_feedback.dart';
import '../../core/share/room_invite_text.dart';
import '../../core/preferences/room_template_storage.dart';
import '../../core/plan/plan_gate.dart';
import '../../core/plan/plan_tier.dart';
import '../../data/models/audit_event.dart';
import 'story_external_link_sheet.dart';
import 'session_report_sheet.dart';
import 'session_close_sheet.dart';
import 'story_public_comment_sheet.dart';
import '../../core/notifications/browser_notifications.dart';
import '../../core/preferences/session_archive_storage.dart';
import '../../core/preferences/app_preferences.dart';
import '../../shared/widgets/room_code_display.dart';
import '../../shared/widgets/room_screen_skeleton.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/spritz_surface_card.dart';
import '../voting/voting_panel.dart';
import '../auth/sign_in_sheet.dart';
import '../../data/auth/auth_providers.dart';

class RoomScreen extends ConsumerStatefulWidget {
  const RoomScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends ConsumerState<RoomScreen> {
  bool? _wasVotesRevealed;
  bool _timerWarned = false;
  bool _linkAccountPromptShown = false;
  Timer? _notificationPoll;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureRoomEntered());
  }

  @override
  void dispose() {
    _notificationPoll?.cancel();
    super.dispose();
  }

  void _onRoomStateChanged(RoomState? previous, RoomState? current) {
    if (previous == null || current == null) return;
    final prevRoom = previous.room;
    final currRoom = current.room;
    if (prevRoom.id != currRoom.id) {
      _wasVotesRevealed = currRoom.votesRevealed;
      _timerWarned = false;
      _syncTimerNotificationPoll(currRoom);
      return;
    }
    if (!prevRoom.votesRevealed && currRoom.votesRevealed) {
      unawaited(SessionFeedback.onReveal());
      unawaited(_notifyReveal());
    }
    _wasVotesRevealed = currRoom.votesRevealed;
    if (prevRoom.currentStoryId != currRoom.currentStoryId ||
        prevRoom.votingDeadlineAt != currRoom.votingDeadlineAt) {
      _timerWarned = false;
    }
    _syncTimerNotificationPoll(currRoom);
  }

  void _syncTimerNotificationPoll(Room room) {
    _notificationPoll?.cancel();
    if (room.votingDeadlineAt == null || room.votesRevealed) return;
    _notificationPoll = Timer.periodic(const Duration(seconds: 10), (_) {
      final deadline = room.votingDeadlineAt;
      if (deadline == null) return;
      final seconds = deadline.difference(DateTime.now()).inSeconds;
      if (seconds <= 30 && seconds > 0 && !_timerWarned) {
        _timerWarned = true;
        unawaited(SessionFeedback.onTimerWarning());
        unawaited(_notifyTimer());
      }
      if (seconds <= 0) {
        _notificationPoll?.cancel();
      }
    });
  }

  Future<void> _notifyReveal() async {
    if (!await AppPreferences.loadNotificationsEnabled()) return;
    if (!mounted) return;
    showBrowserNotification(
      title: context.l10n.notificationsReveal,
      body: context.l10n.appName,
    );
  }

  Future<void> _notifyTimer() async {
    if (!await AppPreferences.loadNotificationsEnabled()) return;
    if (!mounted) return;
    showBrowserNotification(
      title: context.l10n.notificationsTimer,
      body: context.l10n.appName,
    );
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
    if (!mounted) return;
    _maybePromptLinkAccount();
  }

  void _maybePromptLinkAccount() {
    if (_linkAccountPromptShown || ref.read(isSignedInProvider)) return;
    final roomState = ref.read(roomStateProvider).valueOrNull;
    if (roomState == null) return;
    _linkAccountPromptShown = true;
    final l10n = context.l10n;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.accountLinkParticipantHint),
        action: SnackBarAction(
          label: l10n.accountSignIn,
          onPressed: () => unawaited(SignInSheet.show(context)),
        ),
      ),
    );
  }

  void _shareRoomInvite(RoomState roomState) {
    Share.share(
      RoomInviteText.build(
        l10n: context.l10n,
        roomName: roomState.room.name,
        code: roomState.room.code,
      ),
    );
  }

  Future<void> _saveRoomAsTemplate(
    BuildContext context,
    RoomState roomState,
  ) async {
    final l10n = context.l10n;
    final nameController = TextEditingController(text: roomState.room.name);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.saveRoomTemplate),
        content: TextField(
          controller: nameController,
          decoration: InputDecoration(labelText: l10n.saveRoomTemplatePrompt),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.feedbackDismiss),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.salvaOrdine),
          ),
        ],
      ),
    );
    if (saved != true || nameController.text.trim().isEmpty) {
      nameController.dispose();
      return;
    }

    final template = RoomTemplate(
      id: const Uuid().v4(),
      name: nameController.text.trim(),
      deckValues: List<String>.from(roomState.room.deckValues),
      allowCoffeeBreak: roomState.room.allowCoffeeBreak,
      storyTitles: roomState.stories
          .where((s) => s.status == StoryStatus.pending)
          .map((s) => s.title)
          .toList(),
      updatedAt: DateTime.now(),
      autoRevealWhenAllVoted: roomState.room.autoRevealWhenAllVoted,
      hideVotersUntilReveal: roomState.room.hideVotersUntilReveal,
    );
    nameController.dispose();
    await RoomTemplateStorage.upsert(template);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.saveRoomTemplateSuccess)),
    );
  }

  Future<void> _leaveAndGoHome() async {
    final session = ref.read(sessionProvider).valueOrNull;
    final roomState = ref.read(roomStateProvider).valueOrNull;
    if (roomState != null &&
        roomState.stories.any((s) => s.status == StoryStatus.done)) {
      final state = roomState;
      await AppPreferences.markSessionCompleted();
      final report = SessionReport.fromRoomState(
        state,
        includeFacilitatorNotes: true,
      );
      final stats = SessionReportStats.fromRoomState(state);
      await SessionArchiveStorage.add(
        SessionArchiveEntry(
          id: '${state.room.code}-${DateTime.now().millisecondsSinceEpoch}',
          roomName: state.room.name,
          roomCode: state.room.code,
          completedAt: DateTime.now(),
          reportJson: report.toJson(),
          statsJson: stats.toJsonString(),
        ),
      );
    }
    if (session != null) {
      try {
        await ref.read(roomRepositoryProvider).logSessionClose(
              participantId: session.participantId,
            );
      } catch (_) {}
      try {
        await ref.read(roomRepositoryProvider).leaveRoom(
              participantId: session.participantId,
            );
      } catch (_) {
        // Best-effort: local session is cleared even if the RPC fails.
      }
    }
    ref.read(roomStateProvider.notifier).leaveRoom();
    await ref.read(sessionProvider.notifier).clearSession();
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<RoomState?>>(
      roomStateProvider,
      (previous, next) => _onRoomStateChanged(
        previous?.valueOrNull,
        next.valueOrNull,
      ),
    );

    final roomStateAsync = ref.watch(roomStateProvider);
    final session = ref.watch(sessionProvider).valueOrNull;
    final canModerate = ref.watch(canModerateSessionProvider);
    final canEditBacklog = ref.watch(canEditBacklogProvider);
    final connectionStatus = ref.watch(connectionStatusProvider).valueOrNull ??
        ConnectionStatus.connected;

    return roomStateAsync.when(
      loading: () => const RoomScreenSkeleton(),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.appName)),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(userFacingMessage(e, l10n: context.l10n)),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go('/'),
                child: Text(context.l10n.backToHome),
              ),
            ],
          ),
        ),
      ),
      data: (roomState) {
        if (_wasVotesRevealed == null && roomState != null) {
          _wasVotesRevealed = roomState.room.votesRevealed;
          _syncTimerNotificationPoll(roomState.room);
        }

        if (roomState == null || session == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.go('/');
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

        return FacilitatorShortcuts(
          enabled: canModerate,
          onReveal: showVoting && !room.votesRevealed
              ? () => unawaited(_facilitatorReveal(session.participantId))
              : null,
          onNextStory: showVoting && room.votesRevealed
              ? () => unawaited(_facilitatorNextStory(session.participantId))
              : null,
          onStartVoting: !showVoting && room.phase == RoomPhase.lobby
              ? () => unawaited(_facilitatorStartFirstStory(session.participantId))
              : null,
          child: Scaffold(
          appBar: AppBar(
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(room.name),
                Text(
                  room.code,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        letterSpacing: 1.5,
                      ),
                ),
              ],
            ),
            actions: [
              if (canEditBacklog && room.phase == RoomPhase.lobby)
                IconButton(
                  icon: const Icon(Icons.upload_file_outlined),
                  tooltip: context.l10n.importStories,
                  onPressed: () => StoryImportSheet.show(
                    context,
                    participantId: session.participantId,
                  ),
                ),
              if (canModerate && room.phase == RoomPhase.lobby)
                IconButton(
                  icon: const Icon(Icons.keyboard_outlined),
                  tooltip: context.l10n.keyboardShortcuts,
                  onPressed: () => _showKeyboardShortcuts(context),
                ),
              if (canModerate && room.phase == RoomPhase.lobby)
                IconButton(
                  icon: const Icon(Icons.style_outlined),
                  tooltip: context.l10n.deckSettings,
                  onPressed: () => RoomDeckSettingsSheet.show(
                    context,
                    session.participantId,
                  ),
                ),
              if (canModerate)
                IconButton(
                  icon: const Icon(Icons.summarize_outlined),
                  tooltip: context.l10n.riepilogoSerata,
                  onPressed: () => unawaited(
                        _openSessionReport(context, roomState),
                      ),
                ),
              if (canModerate)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'duplicate') {
                      unawaited(_duplicateRoom(context, ref, session));
                    } else if (value == 'close') {
                      SessionCloseSheet.show(
                        context,
                        roomState: roomState,
                        participantId: session.participantId,
                        onLeave: () => unawaited(_leaveAndGoHome()),
                      );
                    } else if (value == 'template') {
                      unawaited(_saveRoomAsTemplate(context, roomState));
                    } else if (value == 'external') {
                      final story = roomState.currentStory;
                      if (story != null) {
                        unawaited(
                          _openExternalSync(
                            context,
                            story: story,
                            participantId: session.participantId,
                          ),
                        );
                      }
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'template',
                      child: Text(context.l10n.saveRoomTemplate),
                    ),
                    if (roomState.currentStory != null)
                      PopupMenuItem(
                        value: 'external',
                        child: Text(context.l10n.externalSyncTitle),
                      ),
                    PopupMenuItem(
                      value: 'close',
                      child: Text(context.l10n.sessionCloseTitle),
                    ),
                    PopupMenuItem(
                      value: 'duplicate',
                      child: Text(context.l10n.duplicateRoom),
                    ),
                  ],
                ),
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: context.l10n.leaveLocale,
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
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLow,
                        border: Border(
                          right: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                      child: _Sidebar(
                        roomState: roomState,
                        isFacilitator: canModerate,
                        participantId: session.participantId,
                        onShare: () => _shareRoomInvite(roomState),
                      ),
                    ),
                    Expanded(
                      child: showVoting
                          ? VotingPanel(
                              roomState: roomState,
                              participantId: session.participantId,
                              isFacilitator: canModerate,
                            )
                          : _LobbyPanel(
                              roomState: roomState,
                              canModerate: canModerate,
                              canEditBacklog: canEditBacklog,
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
                      onShare: () => _shareRoomInvite(roomState),
                    ),
                    const SizedBox(height: 16),
                    _ParticipantsRow(roomState: roomState),
                    const SizedBox(height: 24),
                    if (showVoting)
                      VotingPanel(
                        roomState: roomState,
                        participantId: session.participantId,
                        isFacilitator: canModerate,
                      )
                    else
                      _LobbyPanel(
                        roomState: roomState,
                        canModerate: canModerate,
                        canEditBacklog: canEditBacklog,
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
          floatingActionButton: canEditBacklog && !showVoting
              ? Semantics(
                  button: true,
                  label: context.l10n.addOrdine,
                  child: FloatingActionButton.extended(
                    onPressed: () => _showAddStoryDialog(
                      context,
                      ref,
                      session.participantId,
                    ),
                    icon: const Icon(Icons.add),
                    label: Text(context.l10n.addOrdine),
                  ),
                )
              : null,
        ),
        );
      },
    );
  }

  Future<void> _openSessionReport(
    BuildContext context,
    RoomState roomState,
  ) async {
    final report = SessionReport.fromRoomState(
      roomState,
      includeFacilitatorNotes: true,
    );
    final stats = SessionReportStats.fromRoomState(roomState);
    List<AuditEvent>? audit;
    if (planAllows(ref, (t) => t.canUseAuditTrail)) {
      try {
        audit = await ref.read(roomRepositoryProvider).fetchRoomAuditEvents(
              roomId: roomState.room.id,
            );
      } catch (_) {
        audit = const [];
      }
    }
    if (!context.mounted) return;
    await SessionReportSheet.show(
      context,
      report,
      stats,
      auditEvents: audit,
    );
  }

  Future<void> _openExternalSync(
    BuildContext context, {
    required Story story,
    required String participantId,
  }) async {
    final allowed = await ensurePlanFeature(
      context,
      ref,
      feature: (t) => t.canUseExternalSync,
      minimumTier: PlanTier.team,
    );
    if (!allowed || !context.mounted) return;
    await StoryExternalLinkSheet.show(
      context,
      story: story,
      participantId: participantId,
    );
  }

  Future<void> _facilitatorReveal(String participantId) async {
    try {
      await ref.read(roomRepositoryProvider).revealVotes(
            participantId: participantId,
          );
    } catch (e, st) {
      if (mounted) await showUserError(context, e, stackTrace: st);
    }
  }

  Future<void> _facilitatorNextStory(String participantId) async {
    try {
      await ref.read(roomRepositoryProvider).nextStory(
            participantId: participantId,
          );
      final roomState = ref.read(roomStateProvider).valueOrNull;
      if (roomState != null &&
          roomState.stories.any((s) => s.status == StoryStatus.done)) {
        await AppPreferences.markSessionCompleted();
      }
    } catch (e, st) {
      if (mounted) await showUserError(context, e, stackTrace: st);
    }
  }

  Future<void> _facilitatorStartFirstStory(String participantId) async {
    final roomState = ref.read(roomStateProvider).valueOrNull;
    if (roomState == null) return;
    final pending = roomState.stories
        .where((s) => s.status == StoryStatus.pending)
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (pending.isEmpty) return;
    try {
      await ref.read(roomRepositoryProvider).startVoting(
            participantId: participantId,
            storyId: pending.first.id,
          );
    } catch (e, st) {
      if (mounted) await showUserError(context, e, stackTrace: st);
    }
  }

  void _showKeyboardShortcuts(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.keyboardShortcuts),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.keyboardShortcutReveal),
            Text(l10n.keyboardShortcutNext),
            Text(l10n.keyboardShortcutStartVote),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.back),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.roomState,
    required this.isFacilitator,
    required this.participantId,
    required this.onShare,
  });

  final RoomState roomState;
  final bool isFacilitator;
  final String participantId;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RoomCodeDisplay(
            code: roomState.room.code,
            onShare: onShare,
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
        !roomState.room.votesRevealed &&
        !roomState.room.hideVotersUntilReveal;
    final session = ref.watch(sessionProvider).valueOrNull;
    final isFacilitator = ref.watch(isFacilitatorProvider);

    return SpritzSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.clienti,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
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
                  isObserver: p.isObserver,
                  role: p.role,
                  showVoteStatus: showVoteStatus && !p.isObserver,
                  hasVoted: roomState.hasParticipantVoted(p.id),
                  isAbsent: p.isAbsent(
                    now: DateTime.now(),
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
    );
  }
}

class _LobbyPanel extends ConsumerStatefulWidget {
  const _LobbyPanel({
    required this.roomState,
    required this.canModerate,
    required this.canEditBacklog,
    required this.participantId,
  });

  final RoomState roomState;
  final bool canModerate;
  final bool canEditBacklog;
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
    final canReorder = widget.canEditBacklog &&
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
              SectionHeader(
                title: context.l10n.menu,
                subtitle: context.l10n.menuSubtitle,
              ),
              if (widget.roomState.stories.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  context.l10n.backlogProgress(
                    widget.roomState.stories
                        .where((s) => s.status == StoryStatus.done)
                        .length,
                    widget.roomState.stories.length,
                  ),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: widget.roomState.stories.isEmpty
                        ? 0
                        : widget.roomState.stories
                                .where((s) => s.status == StoryStatus.done)
                                .length /
                            widget.roomState.stories.length,
                    minHeight: 8,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerLow,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
              if (canReorder) ...[
                const SizedBox(height: 8),
                Text(
                  context.l10n.modificaOrdineHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 16),
              if (pendingStories.isEmpty && activeStories.isEmpty)
                SpritzSurfaceCard(
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
                            context,
                            primary: false,
                          ),
                          child: Icon(
                            Icons.receipt_long_outlined,
                            size: 32,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.menuEmpty,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.menuEmptyImportCta,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (widget.canEditBacklog) ...[
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: () => StoryImportSheet.show(
                              context,
                              participantId: widget.participantId,
                            ),
                            icon: const Icon(Icons.upload_file_outlined),
                            label: Text(context.l10n.importStories),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else ...[
                ...activeStories.map(
                  (story) => _StoryTile(
                    story: story,
                    canModerate: widget.canModerate,
                    canEditBacklog: widget.canEditBacklog,
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
                    onMarkSpike: _spikeCallback(
                      context,
                      ref,
                      widget.canModerate,
                      widget.participantId,
                      story,
                    ),
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
                        canModerate: widget.canModerate,
                        canEditBacklog: widget.canEditBacklog,
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
                        onEdit: widget.canEditBacklog
                            ? () => _showEditStoryDialog(
                                  context,
                                  ref,
                                  widget.participantId,
                                  story,
                                  canModerate: widget.canModerate,
                                )
                            : null,
                        onSetReference: widget.canModerate
                            ? () => unawaited(_setReferenceStory(
                                  context,
                                  ref,
                                  widget.participantId,
                                  story.id,
                                ))
                            : null,
                        onMarkSpike: _spikeCallback(
                          context,
                          ref,
                          widget.canModerate,
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
                      canModerate: widget.canModerate,
                      canEditBacklog: widget.canEditBacklog,
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
                      onEdit: widget.canEditBacklog
                          ? () => _showEditStoryDialog(
                                context,
                                ref,
                                widget.participantId,
                                story,
                                canModerate: widget.canModerate,
                              )
                          : null,
                      onSetReference: widget.canModerate
                          ? () => unawaited(_setReferenceStory(
                                context,
                                ref,
                                widget.participantId,
                                story.id,
                              ))
                          : null,
                      onMarkSpike: _spikeCallback(
                        context,
                        ref,
                        widget.canModerate,
                        widget.participantId,
                        story,
                      ),
                      showDragHandle: false,
                    ),
                  ),
              ],
              if (!widget.canModerate && !widget.canEditBacklog) ...[
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    context.l10n.waitingAperitivo,
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
    required this.canModerate,
    required this.canEditBacklog,
    required this.participantId,
    required this.onStartVoting,
    required this.onRemove,
    required this.onEdit,
    this.onMarkSpike,
    this.onSetReference,
    required this.showDragHandle,
    this.dragIndex = 0,
  });

  final Story story;
  final bool canModerate;
  final bool canEditBacklog;
  final String participantId;
  final VoidCallback onStartVoting;
  final VoidCallback onRemove;
  final VoidCallback? onEdit;
  final VoidCallback? onMarkSpike;
  final VoidCallback? onSetReference;
  final bool showDragHandle;
  final int dragIndex;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: AppDecorations.surfaceCard(
          context,
          radius: AppDecorations.radiusMd,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: _statusColor(story).withValues(alpha: 0.12),
            child: Icon(
              _statusIcon(story),
              color: _statusColor(story),
              size: 20,
            ),
          ),
          title: Row(
            children: [
              Expanded(child: Text(story.title)),
              if (story.isReference)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Chip(
                    label: Text(context.l10n.referenceStoryBadge),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (story.description.isNotEmpty) Text(story.description),
              if (story.publicComment.isNotEmpty)
                Text(
                  story.publicComment,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                ),
            ],
          ),
          trailing: story.status == StoryStatus.pending &&
                  (canModerate || canEditBacklog)
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canEditBacklog)
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline),
                        tooltip: context.l10n.storyPublicCommentTitle,
                        onPressed: () => StoryPublicCommentSheet.show(
                          context,
                          story: story,
                          participantId: participantId,
                        ),
                      ),
                    if (canModerate && onSetReference != null)
                      IconButton(
                        icon: Icon(
                          story.isReference
                              ? Icons.anchor
                              : Icons.anchor_outlined,
                        ),
                        tooltip: context.l10n.setReferenceStory,
                        onPressed: onSetReference,
                      ),
                    if (canEditBacklog && showDragHandle)
                      ReorderableDragStartListener(
                        index: dragIndex,
                        child: const Icon(
                          Icons.drag_handle,
                          color: Color(AppColors.spritzOrange),
                          size: 28,
                        ),
                      ),
                    if (canModerate && onMarkSpike != null)
                      IconButton(
                        icon: const Icon(Icons.bolt_outlined),
                        tooltip: context.l10n.markAsSpike,
                        onPressed: onMarkSpike,
                      ),
                    if (canEditBacklog && onEdit != null)
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        tooltip: context.l10n.modificaOrdine,
                        onPressed: onEdit,
                      ),
                    if (canEditBacklog)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: onRemove,
                      ),
                    if (canModerate)
                      FilledButton(
                        onPressed: onStartVoting,
                        child: Text(context.l10n.startVoting),
                      ),
                  ],
                )
              : story.status == StoryStatus.pending && canEditBacklog
                  ? IconButton(
                      icon: const Icon(Icons.chat_bubble_outline),
                      tooltip: context.l10n.storyPublicCommentTitle,
                      onPressed: () => StoryPublicCommentSheet.show(
                        context,
                        story: story,
                        participantId: participantId,
                      ),
                    )
                  : story.finalEstimate != null
                      ? Chip(
                          label: Text('${story.finalEstimate} pt'),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                        )
                      : null,
        ),
      ),
    );
  }
}

Color _statusColor(Story story) {
  if (story.isSpike) return Colors.deepPurple;
  return switch (story.status) {
    StoryStatus.pending => Colors.grey,
    StoryStatus.voting => Colors.orange,
    StoryStatus.revealed => Colors.blue,
    StoryStatus.done => Colors.green,
  };
}

IconData _statusIcon(Story story) {
  if (story.isSpike) return Icons.bolt;
  return switch (story.status) {
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
      title: Text(context.l10n.addOrdine),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: context.l10n.ordineTitle),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descController,
            decoration: InputDecoration(
              labelText: context.l10n.ordineDescription,
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

Future<void> _setReferenceStory(
  BuildContext context,
  WidgetRef ref,
  String participantId,
  String storyId,
) async {
  try {
    await ref.read(roomRepositoryProvider).setReferenceStory(
          participantId: participantId,
          storyId: storyId,
        );
    await ref.read(roomStateProvider.notifier).refresh();
  } catch (e, st) {
    if (context.mounted) {
      await showUserError(context, e, stackTrace: st);
    }
  }
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
      title: Text(context.l10n.passaBancone),
      content: Text(
        context.l10n.confermaPassaBancone(toParticipant.nickname),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(context.l10n.passaBancone),
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

VoidCallback? _spikeCallback(
  BuildContext context,
  WidgetRef ref,
  bool isFacilitator,
  String participantId,
  Story story,
) {
  if (!isFacilitator ||
      story.status != StoryStatus.pending ||
      story.isSpike) {
    return null;
  }
  return () => unawaited(
        _markStorySpike(context, ref, participantId, story.id),
      );
}

Future<void> _markStorySpike(
  BuildContext context,
  WidgetRef ref,
  String participantId,
  String storyId,
) async {
  try {
    await ref.read(roomRepositoryProvider).markStorySpike(
          participantId: participantId,
          storyId: storyId,
        );
  } catch (e, st) {
    if (context.mounted) {
      await showUserError(context, e, stackTrace: st);
    }
  }
}

Future<void> _duplicateRoom(
  BuildContext context,
  WidgetRef ref,
  SessionData session,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.l10n.duplicateRoom),
      content: Text(context.l10n.duplicateRoomConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(context.l10n.duplicateRoom),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

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
    if (context.mounted) {
      context.go('/room/${result.roomId}');
    }
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
  Story story, {
  required bool canModerate,
}) async {
  final titleController = TextEditingController(text: story.title);
  final descController = TextEditingController(text: story.description);
  final noteController =
      TextEditingController(text: story.facilitatorNote);

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(context.l10n.modificaOrdine),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: titleController,
            decoration: InputDecoration(labelText: context.l10n.ordineTitle),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: descController,
            decoration: InputDecoration(
              labelText: context.l10n.ordineDescription,
            ),
            maxLines: 3,
          ),
          if (canModerate) ...[
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: InputDecoration(
                labelText: context.l10n.facilitatorNote,
                hintText: context.l10n.facilitatorNoteHint,
              ),
              maxLines: 2,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(context.l10n.salvaOrdine),
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
            facilitatorNote: canModerate ? noteController.text.trim() : null,
          );
    } catch (e, st) {
      if (context.mounted) {
        await showUserError(context, e, stackTrace: st);
      }
    }
  }

  titleController.dispose();
  descController.dispose();
  noteController.dispose();
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
        title: Text(context.l10n.scegliTimer),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: Text(context.l10n.timerNone),
              selected: durationSeconds == null,
              onSelected: (_) => setState(() => durationSeconds = null),
            ),
            ChoiceChip(
              label: Text(context.l10n.timer2Min),
              selected: durationSeconds == 120,
              onSelected: (_) => setState(() => durationSeconds = 120),
            ),
            ChoiceChip(
              label: Text(context.l10n.timer5Min),
              selected: durationSeconds == 300,
              onSelected: (_) => setState(() => durationSeconds = 300),
            ),
            ChoiceChip(
              label: Text(context.l10n.timer10Min),
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
            child: Text(context.l10n.startVoting),
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
            title: Text(context.l10n.azioniCliente),
            subtitle: Text(target.nickname),
          ),
          if (!target.isFacilitator && target.role != ParticipantRole.editor)
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l10n.setParticipantRoleEditor),
              onTap: () => Navigator.pop(ctx, 'role_editor'),
            ),
          if (!target.isFacilitator && target.role != ParticipantRole.viewer)
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: Text(context.l10n.setParticipantRoleViewer),
              onTap: () => Navigator.pop(ctx, 'role_viewer'),
            ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: Text(context.l10n.passaBancone),
            onTap: () => Navigator.pop(ctx, 'transfer'),
          ),
          ListTile(
            leading: const Icon(Icons.person_remove_outlined),
            title: Text(context.l10n.rimuoviDalBancone),
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
  } else if (action == 'role_editor' || action == 'role_viewer') {
    try {
      await ref.read(roomRepositoryProvider).setParticipantRole(
            facilitatorId: barmanId,
            targetId: target.id,
            role: action == 'role_editor'
                ? ParticipantRole.editor
                : ParticipantRole.viewer,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.participantRoleChanged)),
        );
      }
    } catch (e, st) {
      if (context.mounted) {
        await showUserError(context, e, stackTrace: st);
      }
    }
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
      title: Text(context.l10n.rimuoviDalBancone),
      content: Text(context.l10n.confermaRimuovi(target.nickname)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Annulla'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(context.l10n.rimuoviDalBancone),
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
