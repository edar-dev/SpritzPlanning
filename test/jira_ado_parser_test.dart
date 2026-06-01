import 'package:flutter_test/flutter_test.dart';
import 'package:spritz_planning/core/import/jira_ado_parser.dart';

void main() {
  test('JiraAdoParser parses tab-separated export', () {
    const input = '''
Summary\tStory Points\tDescription
Login OAuth\t5\tAuth flow
Dashboard\t3\t
''';
    final rows = JiraAdoParser.parse(input);
    expect(rows, hasLength(2));
    expect(rows[0].title, 'Login OAuth');
    expect(rows[0].estimate, '5');
    expect(rows[1].title, 'Dashboard');
    expect(rows[1].estimate, '3');
  });

  test('JiraAdoParser skips malformed lines', () {
    const input = '''
Title\tStory Points
\t
Valid story\t8
''';
    final rows = JiraAdoParser.parse(input);
    expect(rows, hasLength(1));
    expect(rows.first.title, 'Valid story');
  });
}
