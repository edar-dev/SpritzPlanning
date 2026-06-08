import 'package:flutter_test/flutter_test.dart';
import 'package:spritz_planning/core/constants/app_config.dart';

void main() {
  test('joinUrlForCode uses /app/ path', () {
    final url = AppConfig.joinUrlForCode('AB12');
    expect(url, contains('/app/?code=AB12'));
  });

  test('shareJoinUrlForCode uses short /j/ path', () {
    final url = AppConfig.shareJoinUrlForCode('xy99');
    expect(url, endsWith('/j/xy99'));
  });

  test('helpUrl points to crawlable static guide', () {
    expect(AppConfig.helpUrl, endsWith('/help'));
  });
}
