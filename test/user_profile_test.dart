import 'package:flutter_test/flutter_test.dart';
import 'package:spritz_planning/data/models/user_profile.dart';

void main() {
  test('UserProfile.fromJson parses RPC payload', () {
    final profile = UserProfile.fromJson({
      'id': '550e8400-e29b-41d4-a716-446655440000',
      'display_name': 'Marco',
      'avatar_url': null,
      'preferred_locale': 'it',
      'updated_at': '2026-06-09T12:00:00Z',
    });

    expect(profile.id, '550e8400-e29b-41d4-a716-446655440000');
    expect(profile.displayName, 'Marco');
    expect(profile.preferredLocale, 'it');
    expect(profile.updatedAt, isNotNull);
  });
}
