import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../data/models/models.dart';
import '../../data/providers/providers.dart';
import '../../shared/widgets/error_snackbar.dart';

class StoryPublicCommentSheet extends ConsumerStatefulWidget {
  const StoryPublicCommentSheet({
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
      isScrollControlled: true,
      builder: (ctx) => StoryPublicCommentSheet(
        story: story,
        participantId: participantId,
      ),
    );
  }

  @override
  ConsumerState<StoryPublicCommentSheet> createState() =>
      _StoryPublicCommentSheetState();
}

class _StoryPublicCommentSheetState
    extends ConsumerState<StoryPublicCommentSheet> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.story.publicComment);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(roomRepositoryProvider).setStoryPublicComment(
            participantId: widget.participantId,
            storyId: widget.story.id,
            comment: _controller.text.trim(),
          );
      await ref.read(roomStateProvider.notifier).refresh();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e, st) {
      if (!mounted) return;
      await showUserError(context, e, stackTrace: st);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

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
              l10n.storyPublicCommentTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(widget.story.title),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: l10n.storyPublicCommentHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.salvaOrdine),
            ),
          ],
        ),
      ),
    );
  }
}
