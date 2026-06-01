import 'dart:convert';

import '../../data/models/models.dart';

class SessionReportRow {
  const SessionReportRow({
    required this.title,
    required this.estimate,
    required this.completedAt,
  });

  final String title;
  final String estimate;
  final DateTime completedAt;
}

class SessionReport {
  const SessionReport({
    required this.roomName,
    required this.roomCode,
    required this.rows,
    required this.exportedAt,
  });

  final String roomName;
  final String roomCode;
  final List<SessionReportRow> rows;
  final DateTime exportedAt;

  bool get isEmpty => rows.isEmpty;

  factory SessionReport.fromRoomState(RoomState state) {
    final rows = state.stories
        .where(
          (s) => s.status == StoryStatus.done && s.finalEstimate != null,
        )
        .map(
          (s) => SessionReportRow(
            title: s.title,
            estimate: s.finalEstimate!,
            completedAt: s.createdAt,
          ),
        )
        .toList();

    return SessionReport(
      roomName: state.room.name,
      roomCode: state.room.code,
      rows: rows,
      exportedAt: DateTime.now().toUtc(),
    );
  }

  String toCsv() {
    final buffer = StringBuffer(
      'locale,codice,ordine,stima_finale,completato_il\n',
    );
    for (final row in rows) {
      buffer.writeln(
        [
          _csvField(roomName),
          _csvField(roomCode),
          _csvField(row.title),
          _csvField(row.estimate),
          _csvField(row.completedAt.toIso8601String()),
        ].join(','),
      );
    }
    return buffer.toString();
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
      ..writeln()
      ..writeln('| Ordine | Stima |')
      ..writeln('|--------|-------|');

    for (final row in rows) {
      buffer.writeln('| ${_escapeMd(row.title)} | ${row.estimate} |');
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

  static String _escapeMd(String value) =>
      value.replaceAll('|', '\\|').replaceAll('\n', ' ');
}
