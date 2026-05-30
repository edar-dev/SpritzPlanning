import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

Future<void> initializeSupabase() async {
  if (!SupabaseConfig.isConfigured) {
    debugPrint(
      'Supabase non configurato. Usa --dart-define-from-file=env.json',
    );
    return;
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
}

SupabaseClient get supabase => Supabase.instance.client;
