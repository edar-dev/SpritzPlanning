import 'package:supabase_flutter/supabase_flutter.dart';

/// In-memory PKCE storage for integration tests (no SharedPreferences / binding).
class InMemoryGotrueAsyncStorage extends GotrueAsyncStorage {
  final Map<String, String> _store = {};

  @override
  Future<String?> getItem({required String key}) async => _store[key];

  @override
  Future<void> removeItem({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<void> setItem({required String key, required String value}) async {
    _store[key] = value;
  }
}
