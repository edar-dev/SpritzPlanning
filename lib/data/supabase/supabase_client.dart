import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'in_memory_gotrue_storage.dart';

class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}

/// [forIntegrationTest]: in-memory auth storage and no session persistence so
/// `flutter test` can use real HTTP without [TestWidgetsFlutterBinding].
Future<void> initializeSupabase({bool forIntegrationTest = false}) async {
  if (!SupabaseConfig.isConfigured) {
    debugPrint(
      'Supabase non configurato. Usa --dart-define-from-file=env.json',
    );
    return;
  }

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
    authOptions: forIntegrationTest
        ? FlutterAuthClientOptions(
            localStorage: const EmptyLocalStorage(),
            pkceAsyncStorage: InMemoryGotrueAsyncStorage(),
          )
        : const FlutterAuthClientOptions(),
  );
}

SupabaseClient get supabase => Supabase.instance.client;
