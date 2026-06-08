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
import 'home_settings_sheet.dart';
import 'home_welcome_content.dart';
import 'room_template_sheet.dart';
import 'onboarding_dialog.dart';
import 'session_archive_sheet.dart';
import '../../core/preferences/session_archive_storage.dart';
import '../../core/theme/app_focus.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _nicknameController = TextEditingController();
  final _localeNameController = TextEditingController();
  final _roomCodeController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLoading = false;
  bool _joinAsObserver = false;
  bool _showJoinAdvanced = false;
  bool _requiresPin = false;
  String? _joinRoomPreviewName;
  Timer? _joinInfoDebounce;
  String? _error;
  String? _nicknameError;
  String? _localeNameError;
  String? _roomCodeError;
  _HomeMode _mode = _HomeMode.welcome;
  List<RecentRoomEntry> _recentRooms = [];
  StoredSession? _storedSession;
  int _archiveCount = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyJoinCodeFromUrl();
      unawaited(_loadLocalPreferences());
      unawaited(_maybeShowOnboarding());
    });
  }

  Future<void> _loadLocalPreferences() async {
    final nickname = await AppPreferences.loadLastNickname();
    var recent = await RecentRoomsStorage.load();
    final stored = await SessionStorage.loadSession();
    final archive = await SessionArchiveStorage.load();
    if (SupabaseConfig.isConfigured && recent.isNotEmpty) {
      recent = await _pruneUnavailableRecentRooms(recent);
    }
    if (!mounted) return;
    setState(() {
      if (nickname != null && _nicknameController.text.isEmpty) {
        _nicknameController.text = nickname;
      }
      _recentRooms = recent;
      _storedSession = stored;
      _archiveCount = archive.length;
    });
  }

  Future<void> _maybeShowOnboarding() async {
    if (!mounted) return;
    await OnboardingDialog.maybeShow(context);
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
    _pinController.dispose();
    _joinInfoDebounce?.cancel();
    super.dispose();
  }

  void _scheduleJoinInfoLookup(String code) {
    _joinInfoDebounce?.cancel();
    final trimmed = code.trim();
    if (trimmed.length < 4) {
      setState(() {
        _requiresPin = false;
        _joinRoomPreviewName = null;
      });
      return;
    }
    _joinInfoDebounce = Timer(const Duration(milliseconds: 450), () async {
      try {
        final info = await ref
            .read(roomRepositoryProvider)
            .getRoomJoinInfo(trimmed);
        if (!mounted) return;
        setState(() {
          _requiresPin = info.requiresPin;
          _joinRoomPreviewName =
              info.roomName.isNotEmpty ? info.roomName : null;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          _requiresPin = false;
          _joinRoomPreviewName = null;
        });
      }
    });
  }

  Future<void> _createRoom() async {
    final l10n = context.l10n;
    final nickname = _nicknameController.text.trim();
    final localeName = _localeNameController.text.trim();

    if (nickname.length < 2) {
      setState(() {
        _nicknameError = l10n.nicknameTooShort;
        _error = null;
      });
      return;
    }
    if (localeName.length < 2) {
      setState(() {
        _localeNameError = l10n.localeNameTooShort;
        _error = null;
      });
      return;
    }

    setState(() {
      _nicknameError = null;
      _localeNameError = null;
    });

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
      await RecentRoomsStorage.add(
        code: result.code,
        name: localeName,
        roomId: result.roomId,
      );
      if (mounted) context.go('/room/${result.roomId}');
    });
  }

  Future<void> _joinRoom() async {
    final l10n = context.l10n;
    final nickname = _nicknameController.text.trim();
    final code = _roomCodeController.text.trim();

    if (nickname.length < 2) {
      setState(() {
        _nicknameError = l10n.nicknameTooShort;
        _error = null;
      });
      return;
    }
    if (code.isEmpty) {
      setState(() {
        _roomCodeError = l10n.roomCodeRequired;
        _error = null;
      });
      return;
    }
    final pin = _pinController.text.trim();
    if (_requiresPin && pin.isEmpty) {
      setState(() => _error = l10n.roomPinRequired);
      return;
    }

    setState(() {
      _nicknameError = null;
      _roomCodeError = null;
    });

    await _joinAction(() async {
      await AppPreferences.saveLastNickname(nickname);
      final stored = _storedSession;
      if (stored != null &&
          stored.roomCode != null &&
          stored.nickname != null &&
          stored.roomCode!.toUpperCase() == code.toUpperCase() &&
          stored.nickname!.toLowerCase() == nickname.toLowerCase()) {
        await ref.read(sessionProvider.notifier).saveSession(
              SessionResult(
                roomId: stored.roomId,
                participantId: stored.participantId,
                code: stored.roomCode!,
              ),
              nickname: nickname,
              roomName: stored.roomName,
            );
        await ref.read(roomStateProvider.notifier).enterRoom(
              stored.roomId,
              stored.participantId,
            );
        if (mounted) context.go('/room/${stored.roomId}');
        return;
      }

      final result = await ref.read(roomRepositoryProvider).joinRoom(
            code: code,
            nickname: nickname,
            observer: _joinAsObserver,
            pin: pin.isNotEmpty ? pin : null,
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
          roomId: result.roomId,
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

  Future<List<RecentRoomEntry>> _pruneUnavailableRecentRooms(
    List<RecentRoomEntry> entries,
  ) async {
    final repo = ref.read(roomRepositoryProvider);
    final valid = <RecentRoomEntry>[];
    for (final entry in entries) {
      try {
        await repo.getRoomJoinInfo(entry.code);
        valid.add(entry);
      } catch (_) {
        await RecentRoomsStorage.remove(code: entry.code);
      }
    }
    return valid;
  }

  Future<void> _openRecentRoom(RecentRoomEntry entry) async {
    final code = RecentRoomsStorage.normalizeCode(entry.code);
    final stored = _storedSession;

    if (stored != null &&
        stored.roomCode != null &&
        stored.roomCode!.toUpperCase() == code) {
      await _resumeStoredSession();
      return;
    }

    if (!SupabaseConfig.isConfigured) {
      setState(() {
        _mode = _HomeMode.join;
        _roomCodeController.text = code;
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final info = await ref.read(roomRepositoryProvider).getRoomJoinInfo(code);
      if (!mounted) return;
      setState(() {
        _mode = _HomeMode.join;
        _roomCodeController.text = code;
        _requiresPin = info.requiresPin;
        _joinRoomPreviewName =
            info.roomName.isNotEmpty ? info.roomName : entry.name;
        _isLoading = false;
      });
    } catch (e, st) {
      await ErrorReporter.capture(e, stackTrace: st, tags: {'flow': 'recent_room'});
      await RecentRoomsStorage.remove(code: code);
      final recent = await RecentRoomsStorage.load();
      if (!mounted) return;
      setState(() {
        _recentRooms = recent;
        _error = context.l10n.recentRoomUnavailable;
        _isLoading = false;
      });
    }
  }

  Future<void> _createFromTemplate() async {
    final template = await RoomTemplateSheet.pick(context);
    if (template == null || !mounted) return;

    final l10n = context.l10n;
    final nickname = _nicknameController.text.trim();
    if (nickname.length < 2) {
      setState(() {
        _mode = _HomeMode.create;
        _localeNameController.text = template.name;
        _error = l10n.nicknameTooShort;
      });
      return;
    }

    await _joinAction(() async {
      await AppPreferences.saveLastNickname(nickname);
      final result = await ref.read(roomRepositoryProvider).createRoom(
            name: template.name,
            nickname: nickname,
          );
      final repo = ref.read(roomRepositoryProvider);
      await repo.setRoomDeck(
        participantId: result.participantId,
        deckValues: template.deckValues,
        allowCoffeeBreak: template.allowCoffeeBreak,
      );
      await repo.setRoomSettings(
        participantId: result.participantId,
        autoRevealWhenAllVoted: template.autoRevealWhenAllVoted,
        hideVotersUntilReveal: template.hideVotersUntilReveal,
      );
      if (template.storyTitles.isNotEmpty) {
        await repo.addStories(
          participantId: result.participantId,
          titles: template.storyTitles,
        );
      }
      await ref.read(sessionProvider.notifier).saveSession(
            result,
            nickname: nickname,
            roomName: template.name,
          );
      await ref.read(roomStateProvider.notifier).enterRoom(
            result.roomId,
            result.participantId,
          );
      await RecentRoomsStorage.add(
        code: result.code,
        name: template.name,
        roomId: result.roomId,
      );
      if (mounted) context.go('/room/${result.roomId}');
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
        decoration: AppDecorations.heroGradient(context),
        child: SafeArea(
          child: Column(
            children: [
              if (!configured)
                ConnectionBanner(message: l10n.supabaseNotConfigured),
              const PwaInstallBanner(),
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
                          context,
                          radius: AppDecorations.radiusXl,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                          child: Column(
                              children: [
                                const _HomePreferencesBar(),
                                const SizedBox(height: 20),
                                _buildLogo(context),
                                const SizedBox(height: 20),
                                Text(
                                  l10n.appName,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.tagline,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
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
      decoration: AppDecorations.iconBadge(context),
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

    return HomeWelcomeContent(
      configured: configured,
      isLoading: _isLoading,
      recentRooms: _recentRooms,
      storedSession: _storedSession,
      showResume: showResume,
      archiveCount: _archiveCount,
      onResume: _resumeStoredSession,
      onOpenCreate: () => setState(() {
        _mode = _HomeMode.create;
        _error = null;
      }),
      onOpenJoin: () => setState(() {
        _mode = _HomeMode.join;
        _error = null;
      }),
      onOpenRecent: _openRecentRoom,
      onTemplate: _createFromTemplate,
      onArchive: () => SessionArchiveSheet.show(context),
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
            errorText: _nicknameError,
          ),
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            if (_nicknameError != null) {
              setState(() => _nicknameError = null);
            }
          },
        ),
        const SizedBox(height: 16),
        if (_mode == _HomeMode.create)
          TextField(
            controller: _localeNameController,
            decoration: InputDecoration(
              labelText: l10n.localeNameLabel,
              hintText: l10n.localeNameHint,
              prefixIcon: const Icon(Icons.store_outlined),
              errorText: _localeNameError,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _createRoom(),
            onChanged: (_) {
              if (_localeNameError != null) {
                setState(() => _localeNameError = null);
              }
            },
          ),
        if (_mode == _HomeMode.join) ...[
          TextField(
            controller: _roomCodeController,
            decoration: InputDecoration(
              labelText: l10n.roomCodeLabel,
              hintText: l10n.roomCodeHint,
              prefixIcon: const Icon(Icons.qr_code_rounded),
              errorText: _roomCodeError,
              helperText: _joinRoomPreviewName,
            ),
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _joinRoom(),
            onChanged: (value) {
              if (_roomCodeError != null) {
                setState(() => _roomCodeError = null);
              }
              _scheduleJoinInfoLookup(value);
            },
          ),
          if (_requiresPin) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: l10n.roomPinLabel,
                hintText: l10n.roomPinHint,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              keyboardType: TextInputType.number,
              obscureText: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _joinRoom(),
            ),
          ],
          const SizedBox(height: 8),
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: EdgeInsets.zero,
              title: Text(
                l10n.joinAdvancedOptions,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              initiallyExpanded: _showJoinAdvanced,
              onExpansionChanged: (expanded) =>
                  setState(() => _showJoinAdvanced = expanded),
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.joinAsObserver),
                  value: _joinAsObserver,
                  onChanged: (value) =>
                      setState(() => _joinAsObserver = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
        ],
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
                    _nicknameError = null;
                    _localeNameError = null;
                    _roomCodeError = null;
                  }),
          child: Text(l10n.back),
        ),
      ],
    );
  }
}

class _HomePreferencesBar extends ConsumerWidget {
  const _HomePreferencesBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider).valueOrNull ?? const Locale('it');
    final iconColor = appToolbarIconColor(context);

    return DecoratedBox(
      decoration: AppDecorations.preferencesBar(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Semantics(
              label: l10n.languageLabel,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  value: locale,
                  style: Theme.of(context).textTheme.labelLarge,
                  dropdownColor: Theme.of(context).colorScheme.surfaceContainerLowest,
                  items: const [
                    DropdownMenuItem(
                      value: Locale('it'),
                      child: Text('Italiano (IT)'),
                    ),
                    DropdownMenuItem(
                      value: Locale('en'),
                      child: Text('English (EN)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(localeProvider.notifier).setLocale(value);
                    }
                  },
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              tooltip: l10n.helpTitle,
              onPressed: () => context.push('/help'),
              icon: Icon(Icons.help_outline_rounded, color: iconColor),
            ),
            IconButton(
              tooltip: l10n.appSettings,
              onPressed: () => HomeSettingsSheet.show(context),
              icon: Icon(Icons.settings_outlined, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }
}

enum _HomeMode { welcome, create, join }
