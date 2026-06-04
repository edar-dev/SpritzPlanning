import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/user_facing_error.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/auth/auth_providers.dart';
import '../../data/supabase/supabase_client.dart';

class SignInSheet extends ConsumerStatefulWidget {
  const SignInSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: const SignInSheet(),
      ),
    );
  }

  @override
  ConsumerState<SignInSheet> createState() => _SignInSheetState();
}

class _SignInSheetState extends ConsumerState<SignInSheet> {
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _magicLinkSent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (!SupabaseConfig.isConfigured) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = userFacingMessage(e, l10n: context.l10n));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendMagicLink() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = context.l10n.accountEmailHint);
      return;
    }
    await _run(() async {
      await ref.read(authRepositoryProvider).signInWithMagicLink(email);
      if (!mounted) return;
      setState(() => _magicLinkSent = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.accountSignIn,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.accountSignInSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.textSecondary),
                  ),
            ),
            const SizedBox(height: 20),
            if (_magicLinkSent) ...[
              Icon(
                Icons.mark_email_read_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.accountMagicLinkSent,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.back),
              ),
            ] else ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(
                  labelText: l10n.accountEmailLabel,
                  hintText: l10n.accountEmailHint,
                ),
                enabled: !_loading,
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _loading ? null : _sendMagicLink,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.accountMagicLinkSend),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _loading
                    ? null
                    : () => _run(
                          () => ref
                              .read(authRepositoryProvider)
                              .signInWithGoogle(),
                        ),
                icon: const Icon(Icons.g_mobiledata_rounded),
                label: Text(l10n.accountOAuthGoogle),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _loading
                    ? null
                    : () => _run(
                          () => ref
                              .read(authRepositoryProvider)
                              .signInWithMicrosoft(),
                        ),
                icon: const Icon(Icons.business_rounded),
                label: Text(l10n.accountOAuthMicrosoft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
