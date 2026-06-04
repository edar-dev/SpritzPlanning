import 'package:flutter_test/flutter_test.dart';
import 'package:spritz_planning/core/plan/plan_tier.dart';

void main() {
  test('free tier limits executive and sync', () {
    const tier = PlanTier.free;
    expect(tier.canUseExecutiveReport, isFalse);
    expect(tier.canUseExternalSync, isFalse);
    expect(tier.canUseMultiWorkspace, isFalse);
    expect(tier.canUseAuditTrail, isFalse);
  });

  test('pro tier unlocks executive and health', () {
    const tier = PlanTier.pro;
    expect(tier.canUseExecutiveReport, isTrue);
    expect(tier.canUseOpsHealth, isTrue);
    expect(tier.canUseExternalSync, isFalse);
  });

  test('team tier unlocks workspace audit and sync', () {
    const tier = PlanTier.team;
    expect(tier.canUseMultiWorkspace, isTrue);
    expect(tier.canUseAuditTrail, isTrue);
    expect(tier.canUseExternalSync, isTrue);
  });
}
