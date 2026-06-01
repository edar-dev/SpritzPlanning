import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionArchiveEntry {
  const SessionArchiveEntry({
    required this.id,
    required this.roomName,
    required this.roomCode,
    required this.completedAt,
    required this.reportJson,
    required this.statsJson,
  });

  final String id;
  final String roomName;
  final String roomCode;
  final DateTime completedAt;
  final String reportJson;
  final String statsJson;

  Map<String, dynamic> toJson() => {
        'id': id,
        'roomName': roomName,
        'roomCode': roomCode,
        'completedAt': completedAt.toIso8601String(),
        'reportJson': reportJson,
        'statsJson': statsJson,
      };

  factory SessionArchiveEntry.fromJson(Map<String, dynamic> json) {
    return SessionArchiveEntry(
      id: json['id'] as String,
      roomName: json['roomName'] as String,
      roomCode: json['roomCode'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      reportJson: json['reportJson'] as String,
      statsJson: json['statsJson'] as String? ?? '{}',
    );
  }
}

abstract final class SessionArchiveStorage {
  static const _key = 'session_archive_v1';
  static const maxEntries = 20;

  static Future<List<SessionArchiveEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => SessionArchiveEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList()
        ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    } catch (_) {
      return [];
    }
  }

  static Future<void> add(SessionArchiveEntry entry) async {
    final list = await load();
    list.removeWhere((e) => e.id == entry.id);
    list.insert(0, entry);
    final trimmed = list.take(maxEntries).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }
}
