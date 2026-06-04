import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/org/org_providers.dart';
import '../../features/home/plan_upgrade_sheet.dart';
import 'plan_tier.dart';

/// Shows upgrade sheet when [feature] is not included in the active plan.
bool planAllows(WidgetRef ref, bool Function(PlanTier tier) feature) {
  return orgFeatureAllowed(ref, (e) => feature(e.planTier));
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
