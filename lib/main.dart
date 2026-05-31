import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'app.dart';
import 'core/config/sentry_config.dart';
import 'core/deep_link/deep_link_bootstrap.dart';
import 'core/pwa/pwa_install_listener.dart';
import 'data/providers/providers.dart';
import 'data/supabase/supabase_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Future<void> bootstrap() async {
    if (kIsWeb) {
      PwaInstallListener.instance.init();
    }
    await initializeSupabase();
    runApp(
      const ProviderScope(
        child: DeepLinkBootstrap(
          child: SessionRestoreWrapper(
            child: SpritzPlanningApp(),
          ),
        ),
      ),
    );
  }

  if (SentryConfig.isConfigured) {
    await SentryFlutter.init(
      (options) {
        options.dsn = SentryConfig.dsn;
        options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
        options.environment = kReleaseMode ? 'production' : 'development';
      },
      appRunner: bootstrap,
    );
  } else {
    await bootstrap();
  }
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
