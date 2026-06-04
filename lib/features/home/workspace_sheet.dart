import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/deck_values.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/plan/plan_tier.dart';
import 'plan_upgrade_sheet.dart';
import '../../core/preferences/preferences_providers.dart';
import '../../core/preferences/workspace_storage.dart';
import '../../core/theme/app_colors.dart';

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
  List<WorkspaceProfile> _workspaces = [];
  String? _activeId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await WorkspaceStorage.loadAll();
    final activeId = await WorkspaceStorage.loadActiveId();
    if (!mounted) return;
    setState(() {
      _workspaces = all;
      _activeId = activeId ?? (all.isNotEmpty ? all.first.id : null);
    });
  }

  Future<void> _addWorkspace() async {
    final tier = ref.read(planTierProvider).valueOrNull ?? PlanTier.free;
    if (!tier.canUseMultiWorkspace && _workspaces.isNotEmpty) {
      if (!mounted) return;
      await PlanUpgradeSheet.show(context, minimumTier: PlanTier.team);
      return;
    }
    final ws = WorkspaceProfile(
      id: const Uuid().v4(),
      name: 'Workspace ${_workspaces.length + 1}',
      brandColorArgb: AppColors.oliveGreen,
      deckValues: DeckValues.defaultDeck,
      updatedAt: DateTime.now().toUtc(),
      logoEmoji: '🍹',
    );
    await WorkspaceStorage.upsert(ws);
    await WorkspaceStorage.setActiveId(ws.id);
    await ref.read(activeWorkspaceProvider.notifier).refresh();
    await _load();
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
              l10n.workspaceTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            if (_workspaces.isEmpty)
              Text(l10n.workspaceEmpty)
            else
              ..._workspaces.map((ws) {
                final selected = ws.id == _activeId;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(ws.brandColorArgb).withValues(
                        alpha: 0.2,
                      ),
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
                      await ref
                          .read(activeWorkspaceProvider.notifier)
                          .refresh();
                      await _load();
                    },
                  ),
                );
              }),
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
}
