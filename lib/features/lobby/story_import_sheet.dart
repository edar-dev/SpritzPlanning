import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/import/jira_ado_parser.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/error_snackbar.dart';

enum _ImportMode { paste, jiraAdo }

class StoryImportSheet extends ConsumerStatefulWidget {
  const StoryImportSheet({
    super.key,
    required this.participantId,
  });

  final String participantId;

  static Future<void> show(
    BuildContext context, {
    required String participantId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => StoryImportSheet(participantId: participantId),
    );
  }

  @override
  ConsumerState<StoryImportSheet> createState() => _StoryImportSheetState();
}

class _StoryImportSheetState extends ConsumerState<StoryImportSheet> {
  final _controller = TextEditingController();
  bool _importing = false;
  _ImportMode _mode = _ImportMode.paste;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<String> _parseTitles() {
    if (_mode == _ImportMode.jiraAdo) {
      return JiraAdoParser.parse(_controller.text)
          .map((r) => r.title)
          .toList();
    }
    final lines = _controller.text.split(RegExp(r'\r?\n'));
    final titles = <String>[];
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      final title = trimmed.split(',').first.trim();
      if (title.isNotEmpty) titles.add(title);
    }
    return titles.take(50).toList();
  }

  Future<void> _import() async {
    final l10n = context.l10n;
    final titles = _parseTitles();
    if (titles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.importStoriesEmpty)),
      );
      return;
    }

    setState(() => _importing = true);

    try {
      final count = await ref.read(roomRepositoryProvider).addStories(
            participantId: widget.participantId,
            titles: titles,
          );
      await ref.read(roomStateProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.importStoriesSuccess(count))),
      );
    } catch (e, st) {
      if (!mounted) return;
      await showUserError(context, e, stackTrace: st);
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final preview = _parseTitles();

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.importStories,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            SegmentedButton<_ImportMode>(
              segments: [
                ButtonSegment(
                  value: _ImportMode.paste,
                  label: Text(l10n.importPasteTab),
                ),
                ButtonSegment(
                  value: _ImportMode.jiraAdo,
                  label: Text(l10n.importJiraAdoTab),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selected) {
                setState(() => _mode = selected.first);
              },
            ),
            const SizedBox(height: 12),
            Text(
              _mode == _ImportMode.jiraAdo
                  ? l10n.importJiraAdoHint
                  : l10n.importPasteHint,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(AppColors.textSecondary),
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: _mode == _ImportMode.jiraAdo
                    ? l10n.importJiraAdoHint
                    : l10n.importPasteHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            if (preview.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                l10n.importPreview(preview.length),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _importing || preview.isEmpty ? null : _import,
              child: _importing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.importStoriesAction),
            ),
          ],
        ),
      ),
    );
  }
}
