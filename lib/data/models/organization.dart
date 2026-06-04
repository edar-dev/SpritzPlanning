import '../../core/plan/plan_tier.dart';

class OrganizationSummary {
  const OrganizationSummary({
    required this.id,
    required this.name,
    required this.slug,
    required this.role,
    required this.planTier,
    this.joinedAt,
  });

  final String id;
  final String name;
  final String slug;
  final String role;
  final PlanTier planTier;
  final DateTime? joinedAt;

  factory OrganizationSummary.fromJson(Map<String, dynamic> json) {
    return OrganizationSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
      role: json['role'] as String? ?? 'member',
      planTier: PlanTierX.fromStorage(json['plan_tier'] as String?),
      joinedAt: json['joined_at'] != null
          ? DateTime.tryParse(json['joined_at'] as String)
          : null,
    );
  }

  bool get isAdmin =>
      role == 'owner' || role == 'admin';
}

class OrgEntitlements {
  const OrgEntitlements({
    required this.orgId,
    required this.planTier,
    required this.canUseExecutiveReport,
    required this.canUseAdvancedKpi,
    required this.canUseOpsHealth,
    required this.canUseMultiWorkspace,
    required this.canUseAuditTrail,
    required this.canUseExternalSync,
  });

  final String orgId;
  final PlanTier planTier;
  final bool canUseExecutiveReport;
  final bool canUseAdvancedKpi;
  final bool canUseOpsHealth;
  final bool canUseMultiWorkspace;
  final bool canUseAuditTrail;
  final bool canUseExternalSync;

  factory OrgEntitlements.fromJson(Map<String, dynamic> json) {
    return OrgEntitlements(
      orgId: json['org_id'] as String,
      planTier: PlanTierX.fromStorage(json['plan_tier'] as String?),
      canUseExecutiveReport:
          json['can_use_executive_report'] as bool? ?? false,
      canUseAdvancedKpi: json['can_use_advanced_kpi'] as bool? ?? false,
      canUseOpsHealth: json['can_use_ops_health'] as bool? ?? false,
      canUseMultiWorkspace:
          json['can_use_multi_workspace'] as bool? ?? false,
      canUseAuditTrail: json['can_use_audit_trail'] as bool? ?? false,
      canUseExternalSync: json['can_use_external_sync'] as bool? ?? false,
    );
  }
}

class CloudWorkspace {
  const CloudWorkspace({
    required this.id,
    required this.orgId,
    required this.name,
    this.brandColor,
    required this.deckValues,
    this.logoEmoji,
    this.updatedAt,
  });

  final String id;
  final String orgId;
  final String name;
  final String? brandColor;
  final List<String> deckValues;
  final String? logoEmoji;
  final DateTime? updatedAt;

  int get brandColorArgb {
    final hex = brandColor?.replaceFirst('#', '') ?? '5c6b42';
    if (hex.length == 6) {
      return int.parse('FF$hex', radix: 16);
    }
    return 0xFF5C6B42;
  }

  factory CloudWorkspace.fromJson(Map<String, dynamic> json) {
    final deck = json['deck_values'];
    return CloudWorkspace(
      id: json['id'] as String,
      orgId: json['org_id'] as String,
      name: json['name'] as String,
      brandColor: json['brand_color'] as String?,
      deckValues: deck is List
          ? deck.map((e) => e.toString()).toList()
          : const [],
      logoEmoji: json['logo_emoji'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }
}
