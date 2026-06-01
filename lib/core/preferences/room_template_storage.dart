import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class RoomTemplate {
  const RoomTemplate({
    required this.id,
    required this.name,
    required this.deckValues,
    required this.allowCoffeeBreak,
    required this.storyTitles,
    required this.updatedAt,
    this.autoRevealWhenAllVoted = false,
    this.hideVotersUntilReveal = false,
  });

  final String id;
  final String name;
  final List<String> deckValues;
  final bool allowCoffeeBreak;
  final List<String> storyTitles;
  final DateTime updatedAt;
  final bool autoRevealWhenAllVoted;
  final bool hideVotersUntilReveal;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'deckValues': deckValues,
        'allowCoffeeBreak': allowCoffeeBreak,
        'storyTitles': storyTitles,
        'updatedAt': updatedAt.toIso8601String(),
        'autoRevealWhenAllVoted': autoRevealWhenAllVoted,
        'hideVotersUntilReveal': hideVotersUntilReveal,
      };

  factory RoomTemplate.fromJson(Map<String, dynamic> json) {
    return RoomTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      deckValues: (json['deckValues'] as List).map((e) => e.toString()).toList(),
      allowCoffeeBreak: json['allowCoffeeBreak'] as bool? ?? true,
      storyTitles:
          (json['storyTitles'] as List).map((e) => e.toString()).toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      autoRevealWhenAllVoted:
          json['autoRevealWhenAllVoted'] as bool? ?? false,
      hideVotersUntilReveal: json['hideVotersUntilReveal'] as bool? ?? false,
    );
  }
}

abstract final class RoomTemplateStorage {
  static const _key = 'room_templates_v1';
  static const maxTemplates = 10;

  static Future<List<RoomTemplate>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => RoomTemplate.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAll(List<RoomTemplate> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = templates.take(maxTemplates).toList();
    await prefs.setString(
      _key,
      jsonEncode(trimmed.map((t) => t.toJson()).toList()),
    );
  }

  static Future<void> upsert(RoomTemplate template) async {
    final list = await load();
    list.removeWhere((t) => t.id == template.id);
    list.insert(0, template);
    await saveAll(list);
  }

  static Future<void> delete(String id) async {
    final list = await load();
    list.removeWhere((t) => t.id == id);
    await saveAll(list);
  }
}
