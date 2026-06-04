/// In-app commercial tiers (#88). Defaults to [PlanTier.free].
enum PlanTier {
  free,
  pro,
  team,
}

extension PlanTierX on PlanTier {
  String get storageKey => name;

  static PlanTier fromStorage(String? value) {
    return PlanTier.values.firstWhere(
      (t) => t.name == value,
      orElse: () => PlanTier.free,
    );
  }

  bool get canUseExecutiveReport => index >= PlanTier.pro.index;

  bool get canUseAdvancedKpi => index >= PlanTier.pro.index;

  bool get canUseMultiWorkspace => index >= PlanTier.team.index;

  bool get canUseAuditTrail => index >= PlanTier.team.index;

  bool get canUseExternalSync => index >= PlanTier.team.index;

  bool get canUseOpsHealth => index >= PlanTier.pro.index;
}
