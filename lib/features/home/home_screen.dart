import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../data/providers/providers.dart';
import '../../data/supabase/supabase_client.dart';
import '../../shared/widgets/connection_banner.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _applyJoinCodeFromUrl());
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
    final nickname = _nicknameController.text.trim();
    final localeName = _localeNameController.text.trim();

    if (nickname.length < 2) {
      setState(() => _error = AppStrings.nicknameTooShort);
      return;
    }
    if (localeName.length < 2) {
      setState(() => _error = AppStrings.localeNameTooShort);
      return;
    }

    await _joinAction(() async {
      final result = await ref.read(roomRepositoryProvider).createRoom(
            name: localeName,
            nickname: nickname,
          );
      await ref.read(sessionProvider.notifier).saveSession(result);
      await ref.read(roomStateProvider.notifier).enterRoom(
            result.roomId,
            result.participantId,
          );
      if (mounted) context.go('/room/${result.roomId}');
    });
  }

  Future<void> _joinRoom() async {
    final nickname = _nicknameController.text.trim();
    final code = _roomCodeController.text.trim();

    if (nickname.length < 2) {
      setState(() => _error = AppStrings.nicknameTooShort);
      return;
    }
    if (code.isEmpty) {
      setState(() => _error = AppStrings.roomCodeRequired);
      return;
    }

    await _joinAction(() async {
      final result = await ref.read(roomRepositoryProvider).joinRoom(
            code: code,
            nickname: nickname,
          );
      await ref.read(sessionProvider.notifier).saveSession(result);
      await ref.read(roomStateProvider.notifier).enterRoom(
            result.roomId,
            result.participantId,
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
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configured = SupabaseConfig.isConfigured;

    return Scaffold(
      body: DecoratedBox(
        decoration: AppDecorations.heroGradient(),
        child: SafeArea(
          child: Column(
            children: [
              if (!configured)
                const ConnectionBanner(
                  message:
                      'Supabase non configurato — usa --dart-define-from-file=env.json',
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
                                AppStrings.appName,
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
                                AppStrings.tagline,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 32),
                              if (_mode == _HomeMode.welcome)
                                _buildWelcomeActions(configured)
                              else
                                _buildForm(context),
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

  Widget _buildWelcomeActions(bool configured) {
    return Column(
      children: [
        SpritzActionTile(
          icon: Icons.storefront_outlined,
          title: AppStrings.openLocale,
          subtitle: 'Crea una stanza per il tuo team',
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
          title: AppStrings.enterBancone,
          subtitle: 'Unisciti con il codice bancone',
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

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nicknameController,
          decoration: const InputDecoration(
            labelText: AppStrings.nicknameLabel,
            hintText: AppStrings.nicknameHint,
            prefixIcon: Icon(Icons.person_outline_rounded),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        if (_mode == _HomeMode.create)
          TextField(
            controller: _localeNameController,
            decoration: const InputDecoration(
              labelText: AppStrings.localeNameLabel,
              hintText: AppStrings.localeNameHint,
              prefixIcon: Icon(Icons.store_outlined),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _createRoom(),
          ),
        if (_mode == _HomeMode.join)
          TextField(
            controller: _roomCodeController,
            decoration: const InputDecoration(
              labelText: AppStrings.roomCodeLabel,
              hintText: AppStrings.roomCodeHint,
              prefixIcon: Icon(Icons.qr_code_rounded),
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
                      ? AppStrings.openLocale
                      : AppStrings.enterBancone,
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
          child: const Text('Indietro'),
        ),
      ],
    );
  }
}

enum _HomeMode { welcome, create, join }
