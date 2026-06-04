import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/error_snackbar.dart';

class StoryExternalLinkSheet extends ConsumerStatefulWidget {
  const StoryExternalLinkSheet({
    super.key,
    required this.story,
    required this.participantId,
  });

  final Story story;
  final String participantId;

  static Future<void> show(
    BuildContext context, {
    required Story story,
    required String participantId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StoryExternalLinkSheet(
        story: story,
        participantId: participantId,
      ),
    );
  }

  @override
  ConsumerState<StoryExternalLinkSheet> createState() =>
      _StoryExternalLinkSheetState();
}

class _StoryExternalLinkSheetState extends ConsumerState<StoryExternalLinkSheet> {
  final _keyController = TextEditingController();
  String _provider = 'jira';
  bool _busy = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _link() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) return;
    setState(() => _busy = true);
    try {
      await ref.read(roomRepositoryProvider).linkStoryExternal(
            participantId: widget.participantId,
            storyId: widget.story.id,
            provider: _provider,
            externalKey: key,
          );
      if (mounted) Navigator.pop(context);
    } catch (e, st) {
      if (mounted) await showUserError(context, e, stackTrace: st);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pushEstimate() async {
    final estimate = widget.story.finalEstimate;
    if (estimate == null || estimate.isEmpty) return;
    setState(() => _busy = true);
    try {
      final result = await ref.read(roomRepositoryProvider).recordExternalSyncPush(
            participantId: widget.participantId,
            storyId: widget.story.id,
            estimate: estimate,
          );
      final text = '${result['provider']}: ${result['external_key']} → ${result['estimate']}';
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.externalSyncCopied)),
        );
      }
    } catch (e, st) {
      if (mounted) await showUserError(context, e, stackTrace: st);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
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
              l10n.externalSyncTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(widget.story.title),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'jira', label: Text(l10n.externalSyncJira)),
                ButtonSegment(value: 'ado', label: Text(l10n.externalSyncAdo)),
              ],
              selected: {_provider},
              onSelectionChanged: (s) => setState(() => _provider = s.first),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _keyController,
              decoration: InputDecoration(
                labelText: l10n.externalSyncKeyLabel,
                hintText: l10n.externalSyncKeyHint,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _link,
              child: Text(l10n.externalSyncLinkAction),
            ),
            if (widget.story.finalEstimate != null) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _busy ? null : _pushEstimate,
                child: Text(l10n.externalSyncPushAction),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
