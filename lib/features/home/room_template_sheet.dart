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
  List<RoomTemplate> _customTemplates = [];
  bool _loading = true;

  List<_TemplateOption> _businessTemplates() {
    final l10n = context.l10n;
    return [
      _TemplateOption(
        template: RoomTemplate(
          id: 'business-discovery',
          name: l10n.templateBusinessDiscoveryName,
          deckValues: List<String>.from(DeckValues.defaultDeck),
          allowCoffeeBreak: true,
          storyTitles: const [
            'Problem framing',
            'Customer interview synthesis',
            'MVP scope',
            'Go-to-market hypothesis',
          ],
          updatedAt: DateTime.now(),
        ),
        subtitle: l10n.templateBusinessDiscoveryDescription,
        isBuiltIn: true,
      ),
      _TemplateOption(
        template: RoomTemplate(
          id: 'business-delivery-refinement',
          name: l10n.templateBusinessRefinementName,
          deckValues: List<String>.from(DeckValues.defaultDeck),
          allowCoffeeBreak: true,
          storyTitles: const [
            'Dependency check',
            'Acceptance criteria review',
            'Risk and unknowns',
            'Ready for sprint',
          ],
          updatedAt: DateTime.now(),
          autoRevealWhenAllVoted: true,
        ),
        subtitle: l10n.templateBusinessRefinementDescription,
        isBuiltIn: true,
      ),
      _TemplateOption(
        template: RoomTemplate(
          id: 'business-maintenance-fast-track',
          name: l10n.templateBusinessMaintenanceName,
          deckValues: List<String>.from(DeckValues.defaultDeck),
          allowCoffeeBreak: false,
          storyTitles: const [
            'Incident triage',
            'Impact and urgency',
            'Hotfix estimation',
            'Post-mortem follow-up',
          ],
          updatedAt: DateTime.now(),
          autoRevealWhenAllVoted: true,
        ),
        subtitle: l10n.templateBusinessMaintenanceDescription,
        isBuiltIn: true,
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    unawaited(_reload());
  }

  Future<void> _reload() async {
    final list = await RoomTemplateStorage.load();
    if (!mounted) return;
    setState(() {
      _customTemplates = list;
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
            child: Text(l10n.cancel),
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
    final businessTemplates = _businessTemplates();

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
            else
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _SectionTitle(label: l10n.businessTemplatesTitle),
                    ...businessTemplates.map((option) => _TemplateTile(
                          option: option,
                          onTap: () => Navigator.pop(context, option.template),
                        )),
                    const SizedBox(height: 12),
                    _SectionTitle(label: l10n.customTemplatesTitle),
                    if (_customTemplates.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          l10n.customTemplatesEmpty,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ..._customTemplates.map((template) {
                      final option = _TemplateOption(
                        template: template,
                        subtitle:
                            '${template.storyTitles.length} · ${template.deckValues.length}',
                        isBuiltIn: false,
                      );
                      return _TemplateTile(
                        option: option,
                        onTap: () => Navigator.pop(context, template),
                        onDelete: () async {
                          await RoomTemplateStorage.delete(template.id);
                          await _reload();
                        },
                      );
                    }),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            if (!widget.selectOnly ||
                _customTemplates.length < RoomTemplateStorage.maxTemplates)
              OutlinedButton.icon(
                onPressed:
                    _customTemplates.length >= RoomTemplateStorage.maxTemplates
                    ? null
                    : () => unawaited(_createTemplate()),
                icon: const Icon(Icons.add),
                label: Text(l10n.createCustomTemplate),
              ),
          ],
        ),
      ),
    );
  }
}

class _TemplateOption {
  const _TemplateOption({
    required this.template,
    required this.subtitle,
    required this.isBuiltIn,
  });

  final RoomTemplate template;
  final String subtitle;
  final bool isBuiltIn;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({
    required this.option,
    required this.onTap,
    this.onDelete,
  });

  final _TemplateOption option;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(option.template.name),
      subtitle: Text(option.subtitle),
      onTap: onTap,
      trailing: option.isBuiltIn
          ? const Icon(Icons.business_center_outlined)
          : IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
    );
  }
}
