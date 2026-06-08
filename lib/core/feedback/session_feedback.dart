import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../preferences/app_preferences.dart';

/// Opt-in sound and haptic feedback for session events (#76).
abstract final class SessionFeedback {
  static Future<void> onReveal() async {
    if (await AppPreferences.loadSoundEffectsEnabled()) {
      await SystemSound.play(SystemSoundType.click);
    }
    if (!kIsWeb && await AppPreferences.loadHapticEnabled()) {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> onTimerWarning() async {
    if (await AppPreferences.loadSoundEffectsEnabled()) {
      await SystemSound.play(SystemSoundType.alert);
    }
    if (!kIsWeb && await AppPreferences.loadHapticEnabled()) {
      await HapticFeedback.heavyImpact();
    }
  }

  static Future<void> onConsensusSuggested() async {
    if (!kIsWeb && await AppPreferences.loadHapticEnabled()) {
      await HapticFeedback.lightImpact();
    }
  }

  static Future<void> onVoteCast() async {
    if (await AppPreferences.loadSoundEffectsEnabled()) {
      await SystemSound.play(SystemSoundType.click);
    }
    if (!kIsWeb && await AppPreferences.loadHapticEnabled()) {
      await HapticFeedback.selectionClick();
    }
  }

  static Future<void> onRevealCountdownTick() async {
    if (await AppPreferences.loadSoundEffectsEnabled()) {
      await SystemSound.play(SystemSoundType.click);
    }
    if (!kIsWeb && await AppPreferences.loadHapticEnabled()) {
      await HapticFeedback.lightImpact();
    }
  }

  static Future<void> onRevealCountdownGo() async {
    if (await AppPreferences.loadSoundEffectsEnabled()) {
      await SystemSound.play(SystemSoundType.alert);
    }
    if (!kIsWeb && await AppPreferences.loadHapticEnabled()) {
      await HapticFeedback.mediumImpact();
    }
  }
}
