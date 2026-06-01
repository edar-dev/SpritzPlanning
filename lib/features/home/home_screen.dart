import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/preferences/preferences_providers.dart';
import '../../core/preferences/recent_rooms_storage.dart';
import '../../core/storage/session_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/errors/user_facing_error.dart';
import '../../core/monitoring/error_reporter.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../data/supabase/supabase_client.dart';
import '../../shared/widgets/connection_banner.dart';
import '../../shared/widgets/pwa_install_banner.dart';
import '../../shared/widgets/spritz_action_tile.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _nicknameController = TextEditingController();
  final _localeNameController = TextEditingController();
  final _roomCodeController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  _HomeMode _mode = _HomeMode.welcome;
  List<RecentRoomEntry> _recentRooms = [];
  StoredSession? _storedSession;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyJoinCodeFromUrl();
      unawaited(_loadLocalPreferences());
    });
  }

  Future<void> _loadLocalPreferences() async {
    final nickname = await AppPreferences.loadLastNickname();
    final recent = await RecentRoomsStorage.load();
    final stored = await SessionStorage.loadSession();
    if (!mounted) return;
    setState(() {
      if (nickname != null && _nicknameController.text.isEmpty) {
        _nicknameController.text = nickname;
      }
      _recentRooms = recent;
      _storedSession = stored;
    });
  }

  void _applyJoinCodeFromUrl() {
    final code = GoRouterState.of(context).uri.queryParameters['code'];
    if (code == null || code.trim().isEmpty) return;
    setState(() {
      _mode = _HomeMode.join;
      _roomCodeController.text = code.trim().toUpperCase();
      _error = null;
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _localeNameController.dispose();
    _roomCodeController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    final l10n = context.l10n;
    final nickname = _nicknameController.text.trim();
    final localeName = _localeNameController.text.trim();

    if (nickname.length < 2) {
      setState(() => _error = l10n.nicknameTooShort);
      return;
    }
    if (localeName.length < 2) {
      setState(() => _error = l10n.localeNameTooShort);
      return;
    }

    await _joinAction(() async {
      await AppPreferences.saveLastNickname(nickname);
      final result = await ref.read(roomRepositoryProvider).createRoom(
            name: localeName,
            nickname: nickname,
          );
      await ref.read(sessionProvider.notifier).saveSession(
            result,
            nickname: nickname,
            roomName: localeName,
          );
      await ref.read(roomStateProvider.notifier).enterRoom(
            result.roomId,
            result.participantId,
          );
      await RecentRoomsStorage.add(code: result.code, name: localeName);
      if (mounted) context.go('/room/${result.roomId}');
    });
  }

  Future<void> _joinRoom() async {
    final l10n = context.l10n;
    final nickname = _nicknameController.text.trim();
    final code = _roomCodeController.text.trim();

    if (nickname.length < 2) {
      setState(() => _error = l10n.nicknameTooShort);
      return;
    }
    if (code.isEmpty) {
      setState(() => _error = l10n.roomCodeRequired);
      return;
    }

    await _joinAction(() async {
      await AppPreferences.saveLastNickname(nickname);
      final result = await ref.read(roomRepositoryProvider).joinRoom(
            code: code,
            nickname: nickname,
          );
      await ref.read(sessionProvider.notifier).saveSession(
            result,
            nickname: nickname,
          );
      await ref.read(roomStateProvider.notifier).enterRoom(
            result.roomId,
            result.participantId,
          );
      final roomState = ref.read(roomStateProvider).valueOrNull;
      if (roomState != null) {
        await ref.read(sessionProvider.notifier).updateRoomMetadata(
              roomName: roomState.room.name,
              roomCode: roomState.room.code,
            );
        await RecentRoomsStorage.add(
          code: roomState.room.code,
          name: roomState.room.name,
        );
      }
      if (mounted) context.go('/room/${result.roomId}');
    });
  }

  Future<void> _resumeStoredSession() async {
    final stored = _storedSession;
    if (stored == null) return;

    await _joinAction(() async {
      await ref.read(sessionProvider.notifier).saveSession(
            SessionResult(
              roomId: stored.roomId,
              participantId: stored.participantId,
              code: stored.roomCode ?? '',
            ),
            nickname: stored.nickname,
            roomName: stored.roomName,
          );
      await ref.read(roomStateProvider.notifier).enterRoom(
            stored.roomId,
            stored.participantId,
          );
      if (mounted) context.go('/room/${stored.roomId}');
    });
  }

  void _openRecentRoom(RecentRoomEntry entry) {
    setState(() {
      _mode = _HomeMode.join;
      _roomCodeController.text = entry.code;
      _error = null;
    });
  }

  Future<void> _joinAction(Future<void> Function() action) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await action();
    } catch (e, st) {
      await ErrorReporter.capture(e, stackTrace: st, tags: {'flow': 'join'});
      setState(() => _error = userFacingMessage(e, l10n: context.l10n));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final configured = SupabaseConfig.isConfigured;

    return Scaffold(
      body: DecoratedBox(
        decoration: AppDecorations.heroGradient(),
        child: SafeArea(
          child: Column(
            children: [
              if (!configured)
                ConnectionBanner(message: l10n.supabaseNotConfigured),
              const PwaInstallBanner(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: _HomePreferencesBar(),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 32,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: DecoratedBox(
                        decoration: AppDecorations.surfaceCard(
                          radius: AppDecorations.radiusXl,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                          child: Column(
                            children: [
                              _buildLogo(context),
                              const SizedBox(height: 20),
                              Text(
                                l10n.appName,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: const Color(AppColors.textPrimary),
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.tagline,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 32),
                              if (_mode == _HomeMode.welcome)
                                _buildWelcomeActions(configured, l10n)
                              else
                                _buildForm(context, l10n),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: AppDecorations.iconBadge(),
      child: const Icon(
        Icons.local_bar_rounded,
        size: 36,
        color: Color(AppColors.spritzOrange),
      ),
    );
  }

  Widget _buildWelcomeActions(bool configured, AppLocalizations l10n) {
    final session = ref.watch(sessionProvider).valueOrNull;
    final showResume = session == null && _storedSession != null;

    return Column(
      children: [
        if (showResume) ...[
          SpritzActionTile(
            icon: Icons.restore_rounded,
            title: l10n.resumeSession,
            subtitle: l10n.resumeSessionSubtitle(
              _storedSession!.roomName ?? l10n.appName,
              _storedSession!.roomCode ?? '',
            ),
            primary: true,
            onTap: configured && !_isLoading ? _resumeStoredSession : null,
          ),
          const SizedBox(height: 12),
        ],
        if (_recentRooms.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.recentRooms,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(AppColors.textSecondary),
                  ),
            ),
          ),
          const SizedBox(height: 8),
          ..._recentRooms.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SpritzActionTile(
                icon: Icons.history_rounded,
                title: entry.name,
                subtitle: entry.code,
                onTap: configured && !_isLoading
                    ? () => _openRecentRoom(entry)
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SpritzActionTile(
          icon: Icons.storefront_outlined,
          title: l10n.openLocale,
          subtitle: l10n.createRoomSubtitle,
          primary: true,
          onTap: configured && !_isLoading
              ? () => setState(() {
                    _mode = _HomeMode.create;
                    _error = null;
                  })
              : null,
        ),
        const SizedBox(height: 12),
        SpritzActionTile(
          icon: Icons.door_front_door_outlined,
          title: l10n.enterBancone,
          subtitle: l10n.joinRoomSubtitle,
          onTap: configured && !_isLoading
              ? () => setState(() {
                    _mode = _HomeMode.join;
                    _error = null;
                  })
              : null,
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nicknameController,
          decoration: InputDecoration(
            labelText: l10n.nicknameLabel,
            hintText: l10n.nicknameHint,
            prefixIcon: const Icon(Icons.person_outline_rounded),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        if (_mode == _HomeMode.create)
          TextField(
            controller: _localeNameController,
            decoration: InputDecoration(
              labelText: l10n.localeNameLabel,
              hintText: l10n.localeNameHint,
              prefixIcon: const Icon(Icons.store_outlined),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _createRoom(),
          ),
        if (_mode == _HomeMode.join)
          TextField(
            controller: _roomCodeController,
            decoration: InputDecoration(
              labelText: l10n.roomCodeLabel,
              hintText: l10n.roomCodeHint,
              prefixIcon: const Icon(Icons.qr_code_rounded),
            ),
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _joinRoom(),
          ),
        const SizedBox(height: 24),
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        FilledButton(
          onPressed: _isLoading
              ? null
              : (_mode == _HomeMode.create ? _createRoom : _joinRoom),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _mode == _HomeMode.create
                      ? l10n.openLocale
                      : l10n.enterBancone,
                ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _isLoading
              ? null
              : () => setState(() {
                    _mode = _HomeMode.welcome;
                    _error = null;
                  }),
          child: Text(l10n.back),
        ),
      ],
    );
  }
}

class _HomePreferencesBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider).valueOrNull ?? ThemeMode.system;
    final locale = ref.watch(localeProvider).valueOrNull;
    final projectorMode =
        ref.watch(projectorModeProvider).valueOrNull ?? false;

    return Row(
      children: [
        DropdownButtonHideUnderline(
          child: DropdownButton<Locale>(
            value: locale ?? const Locale('it'),
            items: const [
              DropdownMenuItem(value: Locale('it'), child: Text('IT')),
              DropdownMenuItem(value: Locale('en'), child: Text('EN')),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(localeProvider.notifier).setLocale(value);
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Text(
          l10n.languageLabel,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        IconButton(
          tooltip: l10n.projectorMode,
          onPressed: () => ref
              .read(projectorModeProvider.notifier)
              .setProjectorMode(!projectorMode),
          icon: Icon(
            projectorMode
                ? Icons.present_to_all
                : Icons.present_to_all_outlined,
            color: projectorMode
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
        ),
        const Spacer(),
        PopupMenuButton<ThemeMode>(
          tooltip: l10n.themeSystem,
          icon: Icon(
            switch (themeMode) {
              ThemeMode.dark => Icons.dark_mode_outlined,
              ThemeMode.light => Icons.light_mode_outlined,
              _ => Icons.brightness_auto_outlined,
            },
          ),
          onSelected: ref.read(themeModeProvider.notifier).setThemeMode,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: ThemeMode.light,
              child: Text(l10n.themeLight),
            ),
            PopupMenuItem(
              value: ThemeMode.dark,
              child: Text(l10n.themeDark),
            ),
            PopupMenuItem(
              value: ThemeMode.system,
              child: Text(l10n.themeSystem),
            ),
          ],
        ),
      ],
    );
  }
}

enum _HomeMode { welcome, create, join }
