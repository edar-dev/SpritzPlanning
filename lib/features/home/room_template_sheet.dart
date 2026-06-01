import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/deck_values.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/room_template_storage.dart';

/// Pick or manage saved room templates (client-only).
class RoomTemplateSheet extends StatefulWidget {
  const RoomTemplateSheet({super.key, this.selectOnly = true});

  final bool selectOnly;

  static Future<RoomTemplate?> pick(BuildContext context) {
    return showModalBottomSheet<RoomTemplate>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => const RoomTemplateSheet(),
    );
  }

  @override
  State<RoomTemplateSheet> createState() => _RoomTemplateSheetState();
}

class _RoomTemplateSheetState extends State<RoomTemplateSheet> {
  List<RoomTemplate> _templates = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    unawaited(_reload());
  }

  Future<void> _reload() async {
    final list = await RoomTemplateStorage.load();
    if (!mounted) return;
    setState(() {
      _templates = list;
      _loading = false;
    });
  }

  Future<void> _createTemplate() async {
    final l10n = context.l10n;
    final nameController = TextEditingController();
    final storiesController = TextEditingController();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.roomTemplates),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.localeNameLabel),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: storiesController,
                decoration: InputDecoration(
                  labelText: l10n.importStories,
                  hintText: l10n.importStoriesEmpty,
                ),
                maxLines: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.salvaOrdine),
          ),
        ],
      ),
    );

    if (saved != true || nameController.text.trim().isEmpty) {
      nameController.dispose();
      storiesController.dispose();
      return;
    }

    final titles = storiesController.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final template = RoomTemplate(
      id: const Uuid().v4(),
      name: nameController.text.trim(),
      deckValues: List<String>.from(DeckValues.defaultDeck),
      allowCoffeeBreak: true,
      storyTitles: titles,
      updatedAt: DateTime.now(),
    );
    nameController.dispose();
    storiesController.dispose();

    await RoomTemplateStorage.upsert(template);
    await _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.roomTemplates,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_templates.isEmpty)
              Text(
                l10n.reportEmpty,
                textAlign: TextAlign.center,
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final t = _templates[index];
                    return ListTile(
                      title: Text(t.name),
                      subtitle: Text(
                        '${t.storyTitles.length} · ${t.deckValues.length}',
                      ),
                      onTap: () => Navigator.pop(context, t),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await RoomTemplateStorage.delete(t.id);
                          await _reload();
                        },
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 12),
            if (!widget.selectOnly || _templates.length < RoomTemplateStorage.maxTemplates)
              OutlinedButton.icon(
                onPressed: _templates.length >= RoomTemplateStorage.maxTemplates
                    ? null
                    : () => unawaited(_createTemplate()),
                icon: const Icon(Icons.add),
                label: Text(l10n.roomTemplates),
              ),
          ],
        ),
      ),
    );
  }
}
