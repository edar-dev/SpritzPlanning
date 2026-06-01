import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Keyboard shortcuts for the facilitator (web/desktop).
class FacilitatorShortcuts extends StatelessWidget {
  const FacilitatorShortcuts({
    super.key,
    required this.enabled,
    required this.onReveal,
    required this.onNextStory,
    required this.onStartVoting,
    required this.child,
  });

  final bool enabled;
  final VoidCallback? onReveal;
  final VoidCallback? onNextStory;
  final VoidCallback? onStartVoting;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyR): _RevealVoteIntent(),
        SingleActivator(LogicalKeyboardKey.keyN): _NextStoryIntent(),
        SingleActivator(LogicalKeyboardKey.keyV): _StartVotingIntent(),
      },
      child: Actions(
        actions: {
          _RevealVoteIntent: CallbackAction<_RevealVoteIntent>(
            onInvoke: (_) {
              onReveal?.call();
              return null;
            },
          ),
          _NextStoryIntent: CallbackAction<_NextStoryIntent>(
            onInvoke: (_) {
              onNextStory?.call();
              return null;
            },
          ),
          _StartVotingIntent: CallbackAction<_StartVotingIntent>(
            onInvoke: (_) {
              onStartVoting?.call();
              return null;
            },
          ),
        },
        child: child,
      ),
    );
  }
}

class _RevealVoteIntent extends Intent {
  const _RevealVoteIntent();
}

class _NextStoryIntent extends Intent {
  const _NextStoryIntent();
}

class _StartVotingIntent extends Intent {
  const _StartVotingIntent();
}
