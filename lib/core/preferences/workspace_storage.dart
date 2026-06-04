import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../constants/deck_values.dart';

class WorkspaceProfile {
  const WorkspaceProfile({
    required this.id,
    required this.name,
    required this.brandColorArgb,
    required this.deckValues,
    required this.updatedAt,
    this.logoEmoji,
  });

  final String id;
  final String name;
  final int brandColorArgb;
  final List<String> deckValues;
  final DateTime updatedAt;
  final String? logoEmoji;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brandColorArgb': brandColorArgb,
        'deckValues': deckValues,
        'updatedAt': updatedAt.toIso8601String(),
        if (logoEmoji != null) 'logoEmoji': logoEmoji,
      };

  factory WorkspaceProfile.fromJson(Map<String, dynamic> json) {
    return WorkspaceProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      brandColorArgb: json['brandColorArgb'] as int? ?? 0xFF5C6B42,
      deckValues: (json['deckValues'] as List? ?? DeckValues.defaultDeck)
          .map((e) => e.toString())
          .toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      logoEmoji: json['logoEmoji'] as String?,
    );
  }

  static WorkspaceProfile defaultWorkspace() {
    return WorkspaceProfile(
      id: const Uuid().v4(),
      name: 'Team',
      brandColorArgb: 0xFF5C6B42,
      deckValues: DeckValues.defaultDeck,
      updatedAt: DateTime.now().toUtc(),
      logoEmoji: '🍹',
    );
  }
}

abstract final class WorkspaceStorage {
  static const _workspacesKey = 'workspaces_v1';
  static const _activeIdKey = 'active_workspace_id_v1';
  static const maxWorkspaces = 8;

  static Future<List<WorkspaceProfile>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_workspacesKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) => WorkspaceProfile.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<String?> loadActiveId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeIdKey);
  }

  static Future<WorkspaceProfile> loadActive() async {
    final all = await loadAll();
    if (all.isEmpty) {
      final defaultWs = WorkspaceProfile.defaultWorkspace();
      await saveAll([defaultWs]);
      await setActiveId(defaultWs.id);
      return defaultWs;
    }
    final activeId = await loadActiveId();
    return all.firstWhere(
      (w) => w.id == activeId,
      orElse: () => all.first,
    );
  }

  static Future<void> saveAll(List<WorkspaceProfile> workspaces) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = workspaces.take(maxWorkspaces).toList();
    await prefs.setString(
      _workspacesKey,
      jsonEncode(trimmed.map((w) => w.toJson()).toList()),
    );
  }

  static Future<void> setActiveId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeIdKey, id);
  }

  static Future<void> upsert(WorkspaceProfile workspace) async {
    final list = await loadAll();
    list.removeWhere((w) => w.id == workspace.id);
    list.insert(0, workspace);
    await saveAll(list);
  }
}
