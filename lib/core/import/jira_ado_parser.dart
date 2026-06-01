/// Parses Jira / Azure DevOps export text back into import rows (#74).
class JiraAdoImportRow {
  const JiraAdoImportRow({
    required this.title,
    this.estimate,
  });

  final String title;
  final String? estimate;
}

abstract final class JiraAdoParser {
  static List<JiraAdoImportRow> parse(String text) {
    final lines = text.split(RegExp(r'\r?\n'));
    if (lines.isEmpty) return [];

    final rows = <JiraAdoImportRow>[];
    var startIndex = 0;

    final first = lines.first.trim();
    if (_isHeaderLine(first)) {
      startIndex = 1;
    }

    for (var i = startIndex; i < lines.length && rows.length < 50; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final parts = line.contains('\t')
          ? line.split('\t')
          : _splitCsvLine(line);

      if (parts.isEmpty) continue;
      final title = parts.first.trim();
      if (title.isEmpty || _isHeaderLine(title)) continue;

      String? estimate;
      if (parts.length >= 2) {
        final raw = parts[1].trim();
        if (raw.isNotEmpty && raw != '—' && raw != '-') {
          estimate = raw;
        }
      }

      rows.add(JiraAdoImportRow(title: title, estimate: estimate));
    }

    return rows;
  }

  static bool _isHeaderLine(String line) {
    final lower = line.toLowerCase();
    return lower.startsWith('summary') ||
        lower.startsWith('title') ||
        lower.contains('story points');
  }

  static List<String> _splitCsvLine(String line) {
    final result = <String>[];
    final buffer = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        inQuotes = !inQuotes;
        continue;
      }
      if (char == ',' && !inQuotes) {
        result.add(buffer.toString());
        buffer.clear();
        continue;
      }
      buffer.write(char);
    }
    result.add(buffer.toString());
    return result;
  }
}
