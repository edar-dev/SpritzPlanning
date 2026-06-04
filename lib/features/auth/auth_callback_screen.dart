import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../data/auth/auth_providers.dart';

/// Handles OAuth / magic-link return on web at `/auth/callback`.
class AuthCallbackScreen extends ConsumerStatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  ConsumerState<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends ConsumerState<AuthCallbackScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_finish()));
  }

  Future<void> _finish() async {
    final repo = ref.read(authRepositoryProvider);
    final ok = await repo.handleAuthCallbackUri(Uri.base);
    if (!mounted) return;
    if (ok) {
      await ref.read(authParticipantLinkProvider)();
    }
    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.accountCallbackLoading),
          ],
        ),
      ),
    );
  }
}
