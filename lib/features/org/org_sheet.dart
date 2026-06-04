import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/user_facing_error.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../data/auth/auth_providers.dart';
import '../../core/preferences/preferences_providers.dart';
import '../../data/org/org_providers.dart';
import 'org_invite_sheet.dart';
import '../auth/sign_in_sheet.dart';

class OrgSheet extends ConsumerStatefulWidget {
  const OrgSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => const OrgSheet(),
    );
  }

  @override
  ConsumerState<OrgSheet> createState() => _OrgSheetState();
}

class _OrgSheetState extends ConsumerState<OrgSheet> {
  final _nameController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createOrg() async {
    final name = _nameController.text.trim();
    if (name.length < 2) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref.read(organizationRepositoryProvider).createOrganization(name);
      ref.invalidate(myOrganizationsProvider);
      ref.invalidate(activeOrganizationProvider);
      ref.invalidate(orgEntitlementsProvider);
      ref.invalidate(cloudWorkspacesProvider);
      await ref.read(activeWorkspaceProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.pop(context);
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
    final signedIn = ref.watch(isSignedInProvider);

    if (!signedIn) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.orgSignInRequired),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  SignInSheet.show(context);
                },
                child: Text(l10n.accountSignIn),
              ),
            ],
          ),
        ),
      );
    }

    final orgsAsync = ref.watch(myOrganizationsProvider);
    final active = ref.watch(activeOrganizationProvider).valueOrNull;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.orgTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            orgsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(userFacingMessage(e, l10n: l10n)),
              data: (orgs) {
                if (orgs.isEmpty) {
                  return Text(l10n.orgEmpty);
                }
                return Column(
                  children: orgs
                      .map(
                        (org) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(org.name),
                            subtitle: Text(
                              '${org.slug} · ${org.planTier.name}',
                            ),
                            trailing: active?.id == org.id
                                ? const Icon(Icons.check)
                                : null,
                            onTap: _loading
                                ? null
                                : () async {
                                    await ref
                                        .read(organizationRepositoryProvider)
                                        .setActiveOrganization(org.id);
                                    ref.invalidate(activeOrganizationProvider);
                                    ref.invalidate(orgEntitlementsProvider);
                                    ref.invalidate(cloudWorkspacesProvider);
                                    await ref
                                        .read(activeWorkspaceProvider.notifier)
                                        .refresh();
                                    if (mounted) setState(() {});
                                  },
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            if (active != null && active.isAdmin) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _loading
                    ? null
                    : () {
                        Navigator.pop(context);
                        OrgInviteSheet.show(context, orgId: active.id);
                      },
                icon: const Icon(Icons.person_add_outlined),
                label: Text(l10n.orgInviteMember),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.orgCreateNameLabel,
                hintText: l10n.orgCreateNameHint,
              ),
              enabled: !_loading,
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
              onPressed: _loading ? null : _createOrg,
              child: Text(l10n.orgCreateAction),
            ),
          ],
        ),
      ),
    );
  }
}
