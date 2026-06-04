import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/plan/plan_tier.dart';
import '../../core/preferences/preferences_providers.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(planTierProvider).valueOrNull ?? PlanTier.free;

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
              onSelect: () => ref.read(planTierProvider.notifier).setTier(
                    PlanTier.free,
                  ),
            ),
            const SizedBox(height: 8),
            _TierCard(
              title: l10n.planTierPro,
              subtitle: l10n.planTierProFeatures,
              selected: current == PlanTier.pro,
              onSelect: () => ref.read(planTierProvider.notifier).setTier(
                    PlanTier.pro,
                  ),
            ),
            const SizedBox(height: 8),
            _TierCard(
              title: l10n.planTierTeam,
              subtitle: l10n.planTierTeamFeatures,
              selected: current == PlanTier.team,
              onSelect: () => ref.read(planTierProvider.notifier).setTier(
                    PlanTier.team,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.planUpgradeDemoNote,
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
