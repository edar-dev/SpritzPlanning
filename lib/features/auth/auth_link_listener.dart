import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/auth/auth_providers.dart';

/// Links the active room participant when auth session appears.
class AuthLinkListener extends ConsumerStatefulWidget {
  const AuthLinkListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AuthLinkListener> createState() => _AuthLinkListenerState();
}

class _AuthLinkListenerState extends ConsumerState<AuthLinkListener> {
  @override
  Widget build(BuildContext context) {
    ref.listen(authSessionProvider, (previous, next) {
      final session = next.valueOrNull;
      final prevSession = previous?.valueOrNull;
      if (session != null &&
          (prevSession == null || prevSession.user.id != session.user.id)) {
        unawaited(ref.read(authParticipantLinkProvider)());
      }
    });
    return widget.child;
  }
}
