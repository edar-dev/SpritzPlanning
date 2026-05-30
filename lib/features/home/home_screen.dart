import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../data/providers/providers.dart';
import '../../data/supabase/supabase_client.dart';
import '../../shared/widgets/connection_banner.dart';

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
      body: SafeArea(
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
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.local_bar,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.appName,
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.tagline,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey.shade700,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),
                        if (_mode == _HomeMode.welcome) ...[
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: configured && !_isLoading
                                  ? () => setState(() {
                                        _mode = _HomeMode.create;
                                        _error = null;
                                      })
                                  : null,
                              icon: const Icon(Icons.storefront),
                              label: const Text(AppStrings.openLocale),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: configured && !_isLoading
                                  ? () => setState(() {
                                        _mode = _HomeMode.join;
                                        _error = null;
                                      })
                                  : null,
                              icon: const Icon(Icons.door_front_door),
                              label: const Text(AppStrings.enterBancone),
                            ),
                          ),
                        ] else ...[
                          TextField(
                            controller: _nicknameController,
                            decoration: const InputDecoration(
                              labelText: AppStrings.nicknameLabel,
                              hintText: AppStrings.nicknameHint,
                              prefixIcon: Icon(Icons.person),
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
                                prefixIcon: Icon(Icons.store),
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
                                prefixIcon: Icon(Icons.qr_code),
                              ),
                              textCapitalization: TextCapitalization.characters,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _joinRoom(),
                            ),
                          const SizedBox(height: 24),
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _isLoading
                                  ? null
                                  : (_mode == _HomeMode.create
                                      ? _createRoom
                                      : _joinRoom),
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _HomeMode { welcome, create, join }
