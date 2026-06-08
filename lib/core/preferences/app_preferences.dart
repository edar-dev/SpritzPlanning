import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class AppPreferences {
  static const _themeModeKey = 'theme_mode';
  static const _localeKey = 'locale_code';
  static const _lastNicknameKey = 'last_nickname';
  static const _hasCompletedSessionKey = 'has_completed_session';
  static const _projectorModeKey = 'projector_mode';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _alwaysUseVotingTimerKey = 'always_use_voting_timer';
  /// JSON null = senza timer; omitted = non impostato.
  static const _lastVotingTimerSecondsKey = 'last_voting_timer_seconds';

  static Future<ThemeMode> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return switch (prefs.getString(_themeModeKey)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.system,
    };
  }

  static Future<void> saveThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeModeKey, value);
  }

  static Future<Locale?> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_localeKey);
    if (code == null || code.isEmpty) return null;
    return Locale(code);
  }

  static Future<void> saveLocale(Locale? locale) async {
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_localeKey);
      return;
    }
    await prefs.setString(_localeKey, locale.languageCode);
  }

  static Future<String?> loadLastNickname() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastNicknameKey);
  }

  static Future<void> saveLastNickname(String nickname) async {
    final trimmed = nickname.trim();
    if (trimmed.length < 2) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastNicknameKey, trimmed);
  }

  static Future<bool> loadHasCompletedSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedSessionKey) ?? false;
  }

  static Future<void> markSessionCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedSessionKey, true);
  }

  static Future<bool> loadProjectorMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_projectorModeKey) ?? false;
  }

  static Future<void> saveProjectorMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_projectorModeKey, enabled);
  }

  static Future<bool> loadNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? false;
  }

  static Future<void> saveNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  /// `null` = senza timer.
  static Future<int?> loadLastVotingTimerSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_lastVotingTimerSecondsKey)) return null;
    final value = prefs.getInt(_lastVotingTimerSecondsKey)!;
    return value < 0 ? null : value;
  }

  static Future<void> saveLastVotingTimerSeconds(int? seconds) async {
    final prefs = await SharedPreferences.getInstance();
    if (seconds == null) {
      await prefs.setInt(_lastVotingTimerSecondsKey, -1);
    } else {
      await prefs.setInt(_lastVotingTimerSecondsKey, seconds);
    }
  }

  static Future<bool> loadAlwaysUseVotingTimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_alwaysUseVotingTimerKey) ?? false;
  }

  static Future<void> saveAlwaysUseVotingTimer(bool always) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alwaysUseVotingTimerKey, always);
  }

  static const _autoStartNextOrderKey = 'auto_start_next_order';

  static Future<bool> loadAutoStartNextOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoStartNextOrderKey) ?? false;
  }

  static Future<void> saveAutoStartNextOrder(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoStartNextOrderKey, enabled);
  }

  static const _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const _hasSubmittedFeedbackKey = 'has_submitted_feedback';
  static const _soundEffectsEnabledKey = 'sound_effects_enabled';
  static const _hapticEnabledKey = 'haptic_enabled';
  static const _pushNotificationsEnabledKey = 'push_notifications_enabled';

  static Future<bool> loadHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  static const _hasSeenBusinessOnboardingKey = 'has_seen_business_onboarding';
  static const _businessOnboardingOutcomeKey = 'business_onboarding_outcome';
  static const _businessOnboardingCompletedAtKey =
      'business_onboarding_completed_at';

  /// `skipped` or `completed` — set when the user finishes the business tour.
  static Future<String?> loadBusinessOnboardingOutcome() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_businessOnboardingOutcomeKey);
  }

  static Future<bool> loadHasSeenBusinessOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenBusinessOnboardingKey) ?? false;
  }

  static Future<void> markBusinessOnboardingSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenBusinessOnboardingKey, true);
    await prefs.setString(_businessOnboardingOutcomeKey, 'skipped');
    await prefs.remove(_businessOnboardingCompletedAtKey);
  }

  static Future<void> markBusinessOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenBusinessOnboardingKey, true);
    await prefs.setString(_businessOnboardingOutcomeKey, 'completed');
    await prefs.setString(
      _businessOnboardingCompletedAtKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }

  static Future<bool> loadHasSubmittedFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSubmittedFeedbackKey) ?? false;
  }

  static Future<void> markFeedbackSubmitted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSubmittedFeedbackKey, true);
  }

  static Future<bool> loadSoundEffectsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEffectsEnabledKey) ?? false;
  }

  static Future<void> saveSoundEffectsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEffectsEnabledKey, enabled);
  }

  static Future<bool> loadHapticEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticEnabledKey) ?? false;
  }

  static Future<void> saveHapticEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticEnabledKey, enabled);
  }

  static Future<bool> loadPushNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pushNotificationsEnabledKey) ?? false;
  }

  static Future<void> savePushNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushNotificationsEnabledKey, enabled);
  }
}
