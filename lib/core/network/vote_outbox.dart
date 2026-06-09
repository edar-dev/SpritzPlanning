import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Pending optimistic vote waiting for network (#126).
class VoteOutboxEntry {
  const VoteOutboxEntry({
    required this.participantId,
    required this.storyId,
    required this.value,
    required this.enqueuedAt,
  });

  final String participantId;
  final String storyId;
  final String value;
  final DateTime enqueuedAt;

  Map<String, dynamic> toJson() => {
        'participantId': participantId,
        'storyId': storyId,
        'value': value,
        'enqueuedAt': enqueuedAt.toIso8601String(),
      };

  factory VoteOutboxEntry.fromJson(Map<String, dynamic> json) {
    return VoteOutboxEntry(
      participantId: json['participantId'] as String,
      storyId: json['storyId'] as String,
      value: json['value'] as String,
      enqueuedAt: DateTime.parse(json['enqueuedAt'] as String),
    );
  }
}

abstract final class VoteOutbox {
  static const _key = 'vote_outbox_v1';

  static Future<List<VoteOutboxEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) => VoteOutboxEntry.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<List<VoteOutboxEntry>> loadForParticipant(
    String participantId,
  ) async {
    final all = await loadAll();
    return all.where((e) => e.participantId == participantId).toList()
      ..sort((a, b) => a.enqueuedAt.compareTo(b.enqueuedAt));
  }

  static Future<bool> hasPending(String participantId) async {
    final pending = await loadForParticipant(participantId);
    return pending.isNotEmpty;
  }

  static Future<void> enqueue(VoteOutboxEntry entry) async {
    final all = await loadAll();
    all.removeWhere(
      (e) =>
          e.participantId == entry.participantId &&
          e.storyId == entry.storyId,
    );
    all.add(entry);
    await _save(all);
  }

  static Future<void> remove({
    required String participantId,
    required String storyId,
  }) async {
    final all = await loadAll();
    all.removeWhere(
      (e) => e.participantId == participantId && e.storyId == storyId,
    );
    await _save(all);
  }

  static Future<void> _save(List<VoteOutboxEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }
}
