import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spritz_planning/core/preferences/app_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('business onboarding not seen by default', () async {
    expect(await AppPreferences.loadHasSeenBusinessOnboarding(), isFalse);
    expect(await AppPreferences.loadBusinessOnboardingOutcome(), isNull);
  });

  test('skip records skipped outcome without completed timestamp', () async {
    await AppPreferences.markBusinessOnboardingSkipped();

    expect(await AppPreferences.loadHasSeenBusinessOnboarding(), isTrue);
    expect(await AppPreferences.loadBusinessOnboardingOutcome(), 'skipped');
  });

  test('complete records completed outcome', () async {
    await AppPreferences.markBusinessOnboardingCompleted();

    expect(await AppPreferences.loadHasSeenBusinessOnboarding(), isTrue);
    expect(await AppPreferences.loadBusinessOnboardingOutcome(), 'completed');
  });
}
