import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spritz_planning/core/preferences/recent_rooms_storage.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('normalizeCode uppercases and trims', () {
    expect(RecentRoomsStorage.normalizeCode(' sprt-ab12 '), 'SPRT-AB12');
  });

  test('remove drops entry by code', () async {
    await RecentRoomsStorage.add(code: 'SPRT-AAAA', name: 'Alpha');
    await RecentRoomsStorage.add(code: 'SPRT-BBBB', name: 'Beta');
    await RecentRoomsStorage.remove(code: 'sprt-aaaa');

    final list = await RecentRoomsStorage.load();
    expect(list, hasLength(1));
    expect(list.first.code, 'SPRT-BBBB');
  });
}
