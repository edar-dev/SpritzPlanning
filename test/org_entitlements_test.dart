import 'package:flutter_test/flutter_test.dart';
import 'package:spritz_planning/core/plan/plan_tier.dart';
import 'package:spritz_planning/data/models/organization.dart';

void main() {
  test('OrgEntitlements.fromJson maps server flags', () {
    final ent = OrgEntitlements.fromJson({
      'org_id': '550e8400-e29b-41d4-a716-446655440000',
      'plan_tier': 'team',
      'can_use_executive_report': true,
      'can_use_advanced_kpi': true,
      'can_use_ops_health': true,
      'can_use_multi_workspace': true,
      'can_use_audit_trail': true,
      'can_use_external_sync': true,
    });

    expect(ent.planTier, PlanTier.team);
    expect(ent.canUseMultiWorkspace, isTrue);
    expect(ent.canUseExecutiveReport, isTrue);
  });

  test('OrganizationSummary parses role and tier', () {
    final org = OrganizationSummary.fromJson({
      'id': 'id-1',
      'name': 'Alpha',
      'slug': 'alpha',
      'role': 'owner',
      'plan_tier': 'pro',
    });

    expect(org.isAdmin, isTrue);
    expect(org.planTier, PlanTier.pro);
  });
}
