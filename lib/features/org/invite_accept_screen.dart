import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../data/auth/auth_providers.dart';
import '../../data/org/org_providers.dart';
import '../auth/sign_in_sheet.dart';

class InviteAcceptScreen extends ConsumerStatefulWidget {
  const InviteAcceptScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<InviteAcceptScreen> createState() => _InviteAcceptScreenState();
}

class _InviteAcceptScreenState extends ConsumerState<InviteAcceptScreen> {
  String? _error;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_accept()));
  }

  Future<void> _accept() async {
    if (!ref.read(isSignedInProvider)) {
      await SignInSheet.show(context);
      if (!ref.read(isSignedInProvider)) return;
    }
    try {
      await ref
          .read(organizationRepositoryProvider)
          .acceptOrgInvite(widget.token);
      ref.invalidate(myOrganizationsProvider);
      ref.invalidate(activeOrganizationProvider);
      ref.invalidate(orgEntitlementsProvider);
      if (!mounted) return;
      setState(() => _done = true);
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (mounted) context.go('/');
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = userFacingMessage(e, l10n: context.l10n));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null) ...[
                Text(_error!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () => context.go('/'),
                  child: Text(l10n.back),
                ),
              ] else if (_done) ...[
                const Icon(Icons.check_circle_outline, size: 48),
                const SizedBox(height: 12),
                Text(l10n.orgInviteAccepted),
              ] else ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(l10n.orgInviteAccepting),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
