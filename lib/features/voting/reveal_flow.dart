import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/feedback/session_feedback.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/app_preferences.dart';

/// Runs theatrical 3-2-1 countdown when opted in, then [reveal].
Future<void> runRevealWithOptionalCountdown({
  required BuildContext context,
  required Future<void> Function() reveal,
}) async {
  if (MediaQuery.disableAnimationsOf(context)) {
    await reveal();
    return;
  }
  if (!await AppPreferences.loadTheatricalReveal()) {
    await reveal();
    return;
  }

  if (!context.mounted) return;
  final revealDone = Completer<void>();
  var revealScheduled = false;

  Future<void> finishWithReveal() async {
    if (revealScheduled) return;
    revealScheduled = true;
    await reveal();
    if (!revealDone.isCompleted) revealDone.complete();
  }

  await showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: context.l10n.revealCountdownSkip,
    barrierColor: Colors.black54,
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return _TheatricalCountdownOverlay(
        onComplete: () async {
          Navigator.of(dialogContext).pop();
          await finishWithReveal();
        },
        onSkip: () async {
          Navigator.of(dialogContext).pop();
          await finishWithReveal();
        },
      );
    },
  );

  if (revealScheduled) await revealDone.future;
}

class _TheatricalCountdownOverlay extends StatefulWidget {
  const _TheatricalCountdownOverlay({
    required this.onComplete,
    required this.onSkip,
  });

  final Future<void> Function() onComplete;
  final Future<void> Function() onSkip;

  @override
  State<_TheatricalCountdownOverlay> createState() =>
      _TheatricalCountdownOverlayState();
}

class _TheatricalCountdownOverlayState extends State<_TheatricalCountdownOverlay> {
  int _step = 3;
  Timer? _timer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    unawaited(SessionFeedback.onRevealCountdownTick());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    if (_step > 1) {
      setState(() => _step--);
      unawaited(SessionFeedback.onRevealCountdownTick());
      return;
    }
    _timer?.cancel();
    setState(() => _step = 0);
    _finished = true;
    unawaited(SessionFeedback.onRevealCountdownGo());
    Future<void>.delayed(const Duration(milliseconds: 450), () async {
      if (!mounted) return;
      await widget.onComplete();
    });
  }

  void _skip() {
    if (_finished) return;
    _timer?.cancel();
    unawaited(widget.onSkip());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final label = _step > 0 ? '$_step' : l10n.revealGo;

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyR): _SkipCountdownIntent(),
      },
      child: Actions(
        actions: {
          _SkipCountdownIntent: CallbackAction<_SkipCountdownIntent>(
            onInvoke: (_) {
              _skip();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _skip,
            child: Material(
              color: Colors.transparent,
              child: Center(
                child: Semantics(
                  liveRegion: true,
                  label: _step > 0 ? l10n.revealCountdown(_step) : l10n.revealGo,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontSize: 120,
                              fontWeight: FontWeight.w900,
                              color: scheme.onInverseSurface,
                              shadows: const [
                                Shadow(
                                  blurRadius: 24,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.revealCountdownSkip,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: scheme.onInverseSurface.withValues(alpha: 0.85),
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkipCountdownIntent extends Intent {
  const _SkipCountdownIntent();
}
