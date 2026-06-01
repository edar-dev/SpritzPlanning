import 'dart:convert';

import '../../data/models/models.dart';

class SessionReportRow {
  const SessionReportRow({
    required this.title,
    required this.estimate,
    required this.description,
    required this.facilitatorNote,
    required this.completedAt,
    required this.isSpike,
  });

  final String title;
  final String estimate;
  final String description;
  final String facilitatorNote;
  final DateTime completedAt;
  final bool isSpike;
}

class SessionReport {
  const SessionReport({
    required this.roomName,
    required this.roomCode,
    required this.rows,
    required this.exportedAt,
    this.includeFacilitatorNotes = false,
  });

  final String roomName;
  final String roomCode;
  final List<SessionReportRow> rows;
  final DateTime exportedAt;
  final bool includeFacilitatorNotes;

  factory SessionReport.fromRoomState(
    RoomState state, {
    bool includeFacilitatorNotes = false,
  }) {
    final rows = state.stories
        .where(
          (s) => s.status == StoryStatus.done && s.finalEstimate != null,
        )
        .map(
          (s) => SessionReportRow(
            title: s.title,
            estimate: s.finalEstimate!,
            description: s.description,
            facilitatorNote: s.facilitatorNote,
            completedAt: s.createdAt,
            isSpike: s.isSpike,
          ),
        )
        .toList();

    return SessionReport(
      roomName: state.room.name,
      roomCode: state.room.code,
      rows: rows,
      exportedAt: DateTime.now().toUtc(),
      includeFacilitatorNotes: includeFacilitatorNotes,
    );
  }

  bool get isEmpty => rows.isEmpty;

  factory SessionReport.fromJson(
    Map<String, dynamic> json, {
    bool includeFacilitatorNotes = true,
  }) {
    final stories = (json['stories'] as List? ?? [])
        .map((e) {
          final m = Map<String, dynamic>.from(e as Map);
          return SessionReportRow(
            title: m['title'] as String,
            estimate: m['estimate'] as String,
            description: m['description'] as String? ?? '',
            facilitatorNote: m['facilitatorNote'] as String? ?? '',
            completedAt: DateTime.parse(m['completedAt'] as String),
            isSpike: m['isSpike'] as bool? ?? false,
          );
        })
        .toList();
    return SessionReport(
      roomName: json['roomName'] as String,
      roomCode: json['roomCode'] as String,
      rows: stories,
      exportedAt: DateTime.parse(json['exportedAt'] as String),
      includeFacilitatorNotes: includeFacilitatorNotes,
    );
  }

  String toCsv() {
    final buffer = StringBuffer(
      includeFacilitatorNotes
          ? 'locale,codice,ordine,stima,descrizione,nota_barman,completato_il\n'
          : 'locale,codice,ordine,stima,descrizione,completato_il\n',
    );
    for (final row in rows) {
      final fields = [
        _csvField(roomName),
        _csvField(roomCode),
        _csvField(row.title),
        _csvField(row.estimate),
        _csvField(row.description),
        if (includeFacilitatorNotes) _csvField(row.facilitatorNote),
        _csvField(row.completedAt.toIso8601String()),
      ];
      buffer.writeln(fields.join(','));
    }
    return buffer.toString();
  }

  String toJira() {
    final buffer = StringBuffer('Summary\tStory Points\tDescription\n');
    for (final row in rows) {
      final desc = _jiraDescription(row);
      buffer.writeln(
        '${_tabField(row.title)}\t${_tabField(row.estimate)}\t${_tabField(desc)}',
      );
    }
    return buffer.toString();
  }

  String toAzureDevOps() {
    final buffer = StringBuffer('Title\tStory Points\tDescription\n');
    for (final row in rows) {
      final desc = _jiraDescription(row);
      buffer.writeln(
        '${_tabField(row.title)}\t${_tabField(row.estimate)}\t${_tabField(desc)}',
      );
    }
    return buffer.toString();
  }

  String toLinear() {
    final buffer = StringBuffer('Title\tEstimate\tDescription\tLabels\n');
    for (final row in rows) {
      final labels = row.isSpike ? 'spike' : 'story';
      buffer.writeln(
        '${_tabField(row.title)}\t${_tabField(row.estimate)}\t${_tabField(_jiraDescription(row))}\t$labels',
      );
    }
    return buffer.toString();
  }

  String toGitHubIssues() {
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(
        '- [ ] **${row.title}** (points: ${row.estimate})',
      );
      if (row.description.isNotEmpty) {
        buffer.writeln('  ${row.description.replaceAll('\n', ' ')}');
      }
    }
    return buffer.toString().trim();
  }

  String toJson() {
    return jsonEncode({
      'roomName': roomName,
      'roomCode': roomCode,
      'exportedAt': exportedAt.toIso8601String(),
      'stories': rows
          .map(
            (r) => {
              'title': r.title,
              'estimate': r.estimate,
              'description': r.description,
              if (includeFacilitatorNotes) 'facilitatorNote': r.facilitatorNote,
              'isSpike': r.isSpike,
              'completedAt': r.completedAt.toIso8601String(),
            },
          )
          .toList(),
    });
  }

  String toMarkdown({String retroNotes = ''}) {
    final buffer = StringBuffer()
      ..writeln('# SpritzPlanning — Riepilogo')
      ..writeln()
      ..writeln('**Locale:** $roomName (`$roomCode`)')
      ..writeln();

    if (includeFacilitatorNotes) {
      buffer
        ..writeln('| Ordine | Stima | Note |')
        ..writeln('|--------|-------|------|');
      for (final row in rows) {
        buffer.writeln(
          '| ${_escapeMd(row.title)} | ${row.estimate} | ${_escapeMd(row.facilitatorNote)} |',
        );
      }
    } else {
      buffer
        ..writeln('| Ordine | Stima |')
        ..writeln('|--------|-------|');
      for (final row in rows) {
        buffer.writeln('| ${_escapeMd(row.title)} | ${row.estimate} |');
      }
    }

    if (retroNotes.trim().isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('## Retro')
        ..writeln(retroNotes.trim());
    }

    buffer
      ..writeln()
      ..writeln(
        '_Esportato il ${exportedAt.toIso8601String()}_',
      );

    return buffer.toString();
  }

  String _jiraDescription(SessionReportRow row) {
    final parts = <String>[];
    if (row.description.isNotEmpty) parts.add(row.description);
    if (includeFacilitatorNotes && row.facilitatorNote.isNotEmpty) {
      parts.add('Note: ${row.facilitatorNote}');
    }
    return parts.join('\n\n');
  }

  static String _csvField(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  static String _tabField(String value) => value.replaceAll('\t', ' ').replaceAll('\n', ' ');

  static String _escapeMd(String value) =>
      value.replaceAll('|', '\\|').replaceAll('\n', ' ');
}
