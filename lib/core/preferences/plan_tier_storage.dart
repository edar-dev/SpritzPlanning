import 'package:shared_preferences/shared_preferences.dart';

import '../plan/plan_tier.dart';

abstract final class PlanTierStorage {
  static const _key = 'plan_tier_v1';

  static Future<PlanTier> load() async {
    final prefs = await SharedPreferences.getInstance();
    return PlanTierX.fromStorage(prefs.getString(_key));
  }

  static Future<void> save(PlanTier tier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, tier.storageKey);
  }
}
