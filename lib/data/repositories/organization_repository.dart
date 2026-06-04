import '../models/organization.dart';
import '../supabase/supabase_client.dart';

class OrganizationRepository {
  Future<Map<String, dynamic>> createOrganization(String name) async {
    final response = await supabase.rpc(
      'create_organization',
      params: {'p_name': name},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  Future<List<OrganizationSummary>> listMyOrganizations() async {
    final response = await supabase.rpc('list_my_organizations');
    final list = response as List<dynamic>? ?? [];
    return list
        .map(
          (e) => OrganizationSummary.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<OrganizationSummary?> getActiveOrganization() async {
    final response = await supabase.rpc('get_active_organization');
    if (response == null) return null;
    return OrganizationSummary.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<void> setActiveOrganization(String orgId) async {
    await supabase.rpc(
      'set_active_organization',
      params: {'p_org_id': orgId},
    );
  }

  Future<String> createOrgInvite({
    required String orgId,
    required String email,
  }) async {
    final response = await supabase.rpc(
      'create_org_invite',
      params: {'p_org_id': orgId, 'p_email': email},
    );
    return Map<String, dynamic>.from(response as Map)['token'] as String;
  }

  Future<String> acceptOrgInvite(String token) async {
    final response = await supabase.rpc(
      'accept_org_invite',
      params: {'p_token': token},
    );
    return Map<String, dynamic>.from(response as Map)['org_id'] as String;
  }

  Future<List<CloudWorkspace>> listWorkspaces(String orgId) async {
    final response = await supabase.rpc(
      'list_workspaces',
      params: {'p_org_id': orgId},
    );
    final list = response as List<dynamic>? ?? [];
    return list
        .map(
          (e) => CloudWorkspace.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<CloudWorkspace> upsertWorkspace({
    required String orgId,
    required String name,
    String? brandColor,
    List<String>? deckValues,
    String? logoEmoji,
    String? workspaceId,
  }) async {
    final response = await supabase.rpc(
      'upsert_workspace',
      params: {
        'p_org_id': orgId,
        'p_name': name,
        if (brandColor != null) 'p_brand_color': brandColor,
        if (deckValues != null) 'p_deck_values': deckValues,
        if (logoEmoji != null) 'p_logo_emoji': logoEmoji,
        if (workspaceId != null) 'p_workspace_id': workspaceId,
      },
    );
    return CloudWorkspace.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<int> importLocalWorkspaces({
    required String orgId,
    required List<Map<String, dynamic>> payload,
  }) async {
    final response = await supabase.rpc(
      'import_local_workspaces',
      params: {'p_org_id': orgId, 'p_payload': payload},
    );
    return response as int? ?? 0;
  }

  Future<OrgEntitlements> getOrgEntitlements(String orgId) async {
    final response = await supabase.rpc(
      'get_org_entitlements',
      params: {'p_org_id': orgId},
    );
    return OrgEntitlements.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<OrgEntitlements> setOrgPlanTier({
    required String orgId,
    required String tier,
  }) async {
    final response = await supabase.rpc(
      'set_org_plan_tier',
      params: {'p_org_id': orgId, 'p_tier': tier},
    );
    return OrgEntitlements.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }
}
