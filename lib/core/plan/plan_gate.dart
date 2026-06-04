import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../preferences/preferences_providers.dart';
import '../../features/home/plan_upgrade_sheet.dart';
import 'plan_tier.dart';

/// Shows upgrade sheet when [feature] is not included in the active plan.
bool planAllows(WidgetRef ref, bool Function(PlanTier tier) feature) {
  final tier = ref.watch(planTierProvider).valueOrNull ?? PlanTier.free;
  return feature(tier);
}

Future<bool> ensurePlanFeature(
  BuildContext context,
  WidgetRef ref, {
  required bool Function(PlanTier tier) feature,
  required PlanTier minimumTier,
}) async {
  if (planAllows(ref, feature)) return true;
  if (!context.mounted) return false;
  await PlanUpgradeSheet.show(context, minimumTier: minimumTier);
  return planAllows(ref, feature);
}
