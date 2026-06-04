import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/deck_values.dart';
import '../../core/errors/user_facing_error.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/plan/plan_gate.dart';
import '../../core/plan/plan_tier.dart';
import '../../core/preferences/preferences_providers.dart';
import '../../core/preferences/workspace_storage.dart';
import '../../data/auth/auth_providers.dart';
import '../../data/models/organization.dart';
import '../../data/org/org_providers.dart';
import 'plan_upgrade_sheet.dart';

class WorkspaceSheet extends ConsumerStatefulWidget {
  const WorkspaceSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => const WorkspaceSheet(),
    );
  }

  @override
  ConsumerState<WorkspaceSheet> createState() => _WorkspaceSheetState();
}

class _WorkspaceSheetState extends ConsumerState<WorkspaceSheet> {
  List<WorkspaceProfile> _localWorkspaces = [];
  String? _activeId;
  bool _useCloud = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final signedIn = ref.read(isSignedInProvider);
    if (signedIn) {
      ref.invalidate(workspaceCloudSyncProvider);
      await ref.read(workspaceCloudSyncProvider.future);
      final cloud = await ref.read(cloudWorkspacesProvider.future);
      if (cloud.isNotEmpty) {
        final activeId = await WorkspaceStorage.loadActiveId();
        if (!mounted) return;
        setState(() {
          _useCloud = true;
          _activeId = activeId ?? cloud.first.id;
        });
        return;
      }
    }
    final all = await WorkspaceStorage.loadAll();
    final activeId = await WorkspaceStorage.loadActiveId();
    if (!mounted) return;
    setState(() {
      _useCloud = false;
      _localWorkspaces = all;
      _activeId = activeId ?? (all.isNotEmpty ? all.first.id : null);
    });
  }

  Future<void> _addWorkspace() async {
    final org = await ref.read(activeOrganizationProvider.future);
    if (_useCloud && org != null) {
      if (!orgFeatureAllowed(
        ref,
        (e) => e.canUseMultiWorkspace,
      )) {
        final cloud = ref.read(cloudWorkspacesProvider).valueOrNull ?? [];
        if (cloud.isNotEmpty) {
          if (!mounted) return;
          await PlanUpgradeSheet.show(context, minimumTier: PlanTier.team);
          return;
        }
      }
      try {
        final created = await ref.read(organizationRepositoryProvider).upsertWorkspace(
              orgId: org.id,
              name: 'Workspace ${(ref.read(cloudWorkspacesProvider).valueOrNull?.length ?? 0) + 1}',
              brandColor: '#5c6b42',
              deckValues: DeckValues.defaultDeck,
              logoEmoji: '🍹',
            );
        ref.invalidate(cloudWorkspacesProvider);
        await WorkspaceStorage.setActiveId(created.id);
        await ref.read(activeWorkspaceProvider.notifier).refresh();
        await _load();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(userFacingMessage(e, l10n: context.l10n))),
        );
      }
      return;
    }

    if (!planAllows(ref, (t) => t.canUseMultiWorkspace) && _localWorkspaces.isNotEmpty) {
      if (!mounted) return;
      await PlanUpgradeSheet.show(context, minimumTier: PlanTier.team);
      return;
    }
    final ws = WorkspaceProfile.defaultWorkspace();
    await WorkspaceStorage.upsert(ws);
    await WorkspaceStorage.setActiveId(ws.id);
    await ref.read(activeWorkspaceProvider.notifier).refresh();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cloudAsync = ref.watch(cloudWorkspacesProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.workspaceTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (_useCloud) ...[
              const SizedBox(height: 8),
              Text(
                l10n.workspaceCloudHint,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            if (_useCloud)
              cloudAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text(userFacingMessage(e, l10n: l10n)),
                data: (cloud) {
                  if (cloud.isEmpty) return Text(l10n.workspaceEmpty);
                  return Column(
                    children: cloud.map((ws) => _cloudTile(context, ws)).toList(),
                  );
                },
              )
            else if (_localWorkspaces.isEmpty)
              Text(l10n.workspaceEmpty)
            else
              ..._localWorkspaces.map((ws) => _localTile(context, ws)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addWorkspace,
              icon: const Icon(Icons.add),
              label: Text(l10n.workspaceAdd),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cloudTile(BuildContext context, CloudWorkspace ws) {
    final l10n = context.l10n;
    final selected = ws.id == _activeId;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(ws.brandColorArgb).withValues(alpha: 0.2),
          child: Text(ws.logoEmoji ?? '🍹'),
        ),
        title: Text(ws.name),
        subtitle: Text(
          l10n.workspaceBrandPreview,
          style: TextStyle(color: Color(ws.brandColorArgb)),
        ),
        trailing: selected ? const Icon(Icons.check) : null,
        onTap: () async {
          await WorkspaceStorage.setActiveId(ws.id);
          await ref.read(activeWorkspaceProvider.notifier).refresh();
          await _load();
        },
      ),
    );
  }

  Widget _localTile(BuildContext context, WorkspaceProfile ws) {
    final l10n = context.l10n;
    final selected = ws.id == _activeId;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(ws.brandColorArgb).withValues(alpha: 0.2),
          child: Text(ws.logoEmoji ?? '🍹'),
        ),
        title: Text(ws.name),
        subtitle: Text(
          l10n.workspaceBrandPreview,
          style: TextStyle(color: Color(ws.brandColorArgb)),
        ),
        trailing: selected ? const Icon(Icons.check) : null,
        onTap: () async {
          await WorkspaceStorage.setActiveId(ws.id);
          await ref.read(activeWorkspaceProvider.notifier).refresh();
          await _load();
        },
      ),
    );
  }
}
