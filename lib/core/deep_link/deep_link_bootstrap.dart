import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/router.dart';

/// Listens for incoming deep links and routes join codes to home.
class DeepLinkBootstrap extends ConsumerStatefulWidget {
  const DeepLinkBootstrap({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DeepLinkBootstrap> createState() => _DeepLinkBootstrapState();
}

class _DeepLinkBootstrapState extends ConsumerState<DeepLinkBootstrap> {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _initDeepLinks();
    }
  }

  Future<void> _initDeepLinks() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleUri(initial);
        });
      }
      _subscription = _appLinks.uriLinkStream.listen(_handleUri);
    } catch (e) {
      debugPrint('Deep link init failed: $e');
    }
  }

  void _handleUri(Uri uri) {
    final code = uri.queryParameters['code'];
    if (code == null || code.trim().isEmpty) return;

    final router = ref.read(routerProvider);
    final path = '/?code=${Uri.encodeComponent(code.trim())}';
    if (router.state.uri.toString() != path) {
      router.go(path);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
