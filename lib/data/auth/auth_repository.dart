import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';
import '../supabase/supabase_client.dart';

class AuthRepository {
  Stream<AuthState> get authStateChanges =>
      Supabase.instance.client.auth.onAuthStateChange;

  User? get currentUser => supabase.auth.currentUser;

  bool get isSignedIn => currentUser != null;

  String get redirectUrl => SupabaseAuthRedirect.url;

  Future<void> signInWithMagicLink(String email) async {
    await supabase.auth.signInWithOtp(
      email: email.trim(),
      emailRedirectTo: redirectUrl,
    );
  }

  Future<void> signInWithGoogle() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUrl,
      authScreenLaunchMode:
          kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
  }

  Future<void> signInWithMicrosoft() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.azure,
      redirectTo: redirectUrl,
      scopes: 'email openid profile',
      authScreenLaunchMode:
          kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<UserProfile> fetchMyProfile() async {
    final response = await supabase.rpc('get_my_profile');
    return UserProfile.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<UserProfile> upsertMyProfile({
    required String displayName,
    String? preferredLocale,
  }) async {
    final response = await supabase.rpc(
      'upsert_my_profile',
      params: {
        'p_display_name': displayName,
        if (preferredLocale != null) 'p_preferred_locale': preferredLocale,
      },
    );
    return UserProfile.fromJson(
      Map<String, dynamic>.from(response as Map),
    );
  }

  Future<void> linkParticipantToUser(String participantId) async {
    await supabase.rpc(
      'link_participant_to_user',
      params: {'p_participant_id': participantId},
    );
  }

  /// Web OAuth / magic-link return URL handler.
  Future<bool> handleAuthCallbackUri(Uri uri) async {
    if (!kIsWeb) return false;
    try {
      await supabase.auth.getSessionFromUrl(uri);
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Redirect target for Supabase Auth (dashboard must allow these URLs).
class SupabaseAuthRedirect {
  static String get url {
    if (kIsWeb) {
      return Uri(
        scheme: Uri.base.scheme,
        host: Uri.base.host,
        port: Uri.base.hasPort ? Uri.base.port : null,
        path: '/app/auth/callback',
      ).toString();
    }
    return 'io.supabase.spritzplanning://auth/callback';
  }
}
