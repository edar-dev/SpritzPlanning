import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/user_facing_error.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/plan/plan_tier.dart';
import '../../core/preferences/preferences_providers.dart';
import '../../data/org/org_providers.dart';

class PlanUpgradeSheet extends ConsumerWidget {
  const PlanUpgradeSheet({super.key, required this.minimumTier});

  final PlanTier minimumTier;

  static Future<void> show(
    BuildContext context, {
    required PlanTier minimumTier,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => PlanUpgradeSheet(minimumTier: minimumTier),
    );
  }

  Future<void> _selectTier(
    BuildContext context,
    WidgetRef ref,
    PlanTier tier,
  ) async {
    final org = ref.read(activeOrganizationProvider).valueOrNull;
    try {
      if (org != null && org.role == 'owner') {
        await ref.read(organizationRepositoryProvider).setOrgPlanTier(
              orgId: org.id,
              tier: tier.name,
            );
        ref.invalidate(orgEntitlementsProvider);
        ref.invalidate(activeOrganizationProvider);
      } else {
        await ref.read(planTierProvider.notifier).setTier(tier);
      }
      if (context.mounted) Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userFacingMessage(e, l10n: context.l10n))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(effectivePlanTierProvider);
    final org = ref.watch(activeOrganizationProvider).valueOrNull;
    final serverManaged = org != null && org.role == 'owner';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.planUpgradeTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(l10n.planUpgradeBody(minimumTier.name)),
            const SizedBox(height: 16),
            _TierCard(
              title: l10n.planTierFree,
              subtitle: l10n.planTierFreeFeatures,
              selected: current == PlanTier.free,
              onSelect: () => _selectTier(context, ref, PlanTier.free),
            ),
            const SizedBox(height: 8),
            _TierCard(
              title: l10n.planTierPro,
              subtitle: l10n.planTierProFeatures,
              selected: current == PlanTier.pro,
              onSelect: () => _selectTier(context, ref, PlanTier.pro),
            ),
            const SizedBox(height: 8),
            _TierCard(
              title: l10n.planTierTeam,
              subtitle: l10n.planTierTeamFeatures,
              selected: current == PlanTier.team,
              onSelect: () => _selectTier(context, ref, PlanTier.team),
            ),
            const SizedBox(height: 12),
            Text(
              serverManaged
                  ? l10n.planUpgradeOrgNote
                  : l10n.planUpgradeDemoNote,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onSelect,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: selected ? const Icon(Icons.check_circle) : null,
        onTap: onSelect,
      ),
    );
  }
}
