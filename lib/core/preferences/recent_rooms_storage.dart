import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RecentRoomEntry {
  const RecentRoomEntry({
    required this.code,
    required this.name,
    required this.visitedAt,
    this.roomId,
  });

  final String code;
  final String name;
  final DateTime visitedAt;
  final String? roomId;

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'visitedAt': visitedAt.toIso8601String(),
        if (roomId != null) 'roomId': roomId,
      };

  factory RecentRoomEntry.fromJson(Map<String, dynamic> json) {
    return RecentRoomEntry(
      code: RecentRoomsStorage.normalizeCode(json['code'] as String),
      name: json['name'] as String,
      visitedAt: DateTime.parse(json['visitedAt'] as String),
      roomId: json['roomId'] as String?,
    );
  }
}

abstract final class RecentRoomsStorage {
  static const _key = 'recent_rooms';
  static const maxEntries = 5;

  static String normalizeCode(String code) => code.trim().toUpperCase();

  static Future<List<RecentRoomEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => RecentRoomEntry.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> add({
    required String code,
    required String name,
    String? roomId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = normalizeCode(code);
    final existing = await load();
    final filtered = existing
        .where((e) => e.code != normalized)
        .toList();
    filtered.insert(
      0,
      RecentRoomEntry(
        code: normalized,
        name: name,
        visitedAt: DateTime.now(),
        roomId: roomId,
      ),
    );
    final trimmed = filtered.take(maxEntries).toList();
    await prefs.setString(
      _key,
      jsonEncode(trimmed.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> remove({required String code}) async {
    final normalized = normalizeCode(code);
    final prefs = await SharedPreferences.getInstance();
    final existing = await load();
    final filtered = existing.where((e) => e.code != normalized).toList();
    if (filtered.length == existing.length) return;
    await prefs.setString(
      _key,
      jsonEncode(filtered.map((e) => e.toJson()).toList()),
    );
  }
}
