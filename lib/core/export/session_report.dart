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

  bool get isEmpty => rows.isEmpty;

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

  String _jiraDescription(SessionReportRow row) {
    final parts = <String>[];
    if (row.description.isNotEmpty) parts.add(row.description);
    if (includeFacilitatorNotes && row.facilitatorNote.isNotEmpty) {
      parts.add('Note: ${row.facilitatorNote}');
    }
    return parts.join('\n\n');
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

  String toMarkdown() {
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

    buffer
      ..writeln()
      ..writeln(
        '_Esportato il ${exportedAt.toIso8601String()}_',
      );

    return buffer.toString();
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
