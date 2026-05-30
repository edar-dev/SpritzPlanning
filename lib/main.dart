import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/providers/providers.dart';
import 'data/supabase/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeSupabase();

  runApp(
    const ProviderScope(
      child: SessionRestoreWrapper(
        child: SpritzPlanningApp(),
      ),
    ),
  );
}

/// Entry point helper for session restore on app start.
class SessionRestoreWrapper extends ConsumerStatefulWidget {
  const SessionRestoreWrapper({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SessionRestoreWrapper> createState() =>
      _SessionRestoreWrapperState();
}

class _SessionRestoreWrapperState extends ConsumerState<SessionRestoreWrapper> {
  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final session = await ref.read(sessionProvider.future);
    if (session != null && mounted) {
      await ref.read(roomStateProvider.notifier).enterRoom(
            session.roomId,
            session.participantId,
          );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
