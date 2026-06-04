import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/user_facing_error.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../data/org/org_providers.dart';

class OrgInviteSheet extends ConsumerStatefulWidget {
  const OrgInviteSheet({super.key, required this.orgId});

  final String orgId;

  static Future<void> show(BuildContext context, {required String orgId}) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: OrgInviteSheet(orgId: orgId),
      ),
    );
  }

  @override
  ConsumerState<OrgInviteSheet> createState() => _OrgInviteSheetState();
}

class _OrgInviteSheetState extends ConsumerState<OrgInviteSheet> {
  final _emailController = TextEditingController();
  String? _inviteLink;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _createInvite() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = await ref.read(organizationRepositoryProvider).createOrgInvite(
            orgId: widget.orgId,
            email: email,
          );
      final base = Uri.base.origin;
      if (!mounted) return;
      setState(() {
        _inviteLink = '$base/invite/$token';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = userFacingMessage(e, l10n: context.l10n));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
              l10n.orgInviteTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: l10n.accountEmailLabel,
                hintText: l10n.accountEmailHint,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _loading ? null : _createInvite,
              child: Text(l10n.orgInviteSend),
            ),
            if (_inviteLink != null) ...[
              const SizedBox(height: 16),
              SelectableText(_inviteLink!),
              const SizedBox(height: 8),
              Text(
                l10n.orgInviteLinkHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
