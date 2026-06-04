import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_providers.dart';
import '../models/organization.dart';
import '../repositories/organization_repository.dart';
import '../../core/plan/plan_tier.dart';
import '../../core/preferences/preferences_providers.dart';
import '../../core/preferences/workspace_storage.dart';

final organizationRepositoryProvider = Provider<OrganizationRepository>(
  (ref) => OrganizationRepository(),
);

final myOrganizationsProvider = FutureProvider<List<OrganizationSummary>>(
  (ref) async {
    if (!ref.watch(isSignedInProvider)) return [];
    return ref.read(organizationRepositoryProvider).listMyOrganizations();
  },
);

final activeOrganizationProvider = FutureProvider<OrganizationSummary?>(
  (ref) async {
    if (!ref.watch(isSignedInProvider)) return null;
    ref.watch(authSessionProvider);
    return ref.read(organizationRepositoryProvider).getActiveOrganization();
  },
);

final orgEntitlementsProvider = FutureProvider<OrgEntitlements?>((ref) async {
  final org = await ref.watch(activeOrganizationProvider.future);
  if (org == null) return null;
  return ref
      .read(organizationRepositoryProvider)
      .getOrgEntitlements(org.id);
});

/// Server org tier when signed in with active org; else local demo tier.
final effectivePlanTierProvider = Provider<PlanTier>((ref) {
  final entitlements = ref.watch(orgEntitlementsProvider).valueOrNull;
  if (entitlements != null) return entitlements.planTier;
  return ref.watch(planTierProvider).valueOrNull ?? PlanTier.free;
});

final cloudWorkspacesProvider = FutureProvider<List<CloudWorkspace>>((ref) async {
  final org = await ref.watch(activeOrganizationProvider.future);
  if (org == null) return [];
  return ref.read(organizationRepositoryProvider).listWorkspaces(org.id);
});

/// Sync local workspaces to cloud once per org (best-effort).
final workspaceCloudSyncProvider = FutureProvider<void>((ref) async {
  if (!ref.watch(isSignedInProvider)) return;
  final org = await ref.watch(activeOrganizationProvider.future);
  if (org == null || !org.isAdmin) return;

  final cloud = await ref.read(cloudWorkspacesProvider.future);
  if (cloud.isNotEmpty) return;

  final local = await WorkspaceStorage.loadAll();
  if (local.isEmpty) return;

  final payload = local
      .map(
        (w) => {
          'name': w.name,
          'brand_color': _hexFromArgb(w.brandColorArgb),
          'deck_values': w.deckValues,
          'logo_emoji': w.logoEmoji,
        },
      )
      .toList();

  await ref.read(organizationRepositoryProvider).importLocalWorkspaces(
        orgId: org.id,
        payload: payload,
      );
  ref.invalidate(cloudWorkspacesProvider);
});

String _hexFromArgb(int argb) {
  final r = (argb >> 16) & 0xFF;
  final g = (argb >> 8) & 0xFF;
  final b = argb & 0xFF;
  return '#${r.toRadixString(16).padLeft(2, '0')}'
      '${g.toRadixString(16).padLeft(2, '0')}'
      '${b.toRadixString(16).padLeft(2, '0')}';
}

bool orgFeatureAllowed(
  WidgetRef ref,
  bool Function(OrgEntitlements e) feature,
) {
  final ent = ref.watch(orgEntitlementsProvider).valueOrNull;
  if (ent != null) return feature(ent);
  final tier = ref.watch(planTierProvider).valueOrNull ?? PlanTier.free;
  return feature(OrgEntitlements(
    orgId: '',
    planTier: tier,
    canUseExecutiveReport: tier.canUseExecutiveReport,
    canUseAdvancedKpi: tier.canUseAdvancedKpi,
    canUseOpsHealth: tier.canUseOpsHealth,
    canUseMultiWorkspace: tier.canUseMultiWorkspace,
    canUseAuditTrail: tier.canUseAuditTrail,
    canUseExternalSync: tier.canUseExternalSync,
  ));
}
