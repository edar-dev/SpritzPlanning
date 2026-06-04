import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/pwa/pwa_install_listener.dart';
import '../../core/theme/app_colors.dart';

/// Banner installazione PWA (solo web, dopo prima sessione completata).
class PwaInstallBanner extends StatefulWidget {
  const PwaInstallBanner({super.key});

  @override
  State<PwaInstallBanner> createState() => _PwaInstallBannerState();
}

class _PwaInstallBannerState extends State<PwaInstallBanner> {
  final _listener = PwaInstallListener.instance;
  bool _sessionCompleted = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _listener.canInstall.addListener(_onCanInstallChanged);
    _loadSessionFlag();
  }

  Future<void> _loadSessionFlag() async {
    final completed = await AppPreferences.loadHasCompletedSession();
    if (!mounted) return;
    setState(() {
      _sessionCompleted = completed;
      _loaded = true;
    });
  }

  @override
  void dispose() {
    _listener.canInstall.removeListener(_onCanInstallChanged);
    super.dispose();
  }

  void _onCanInstallChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded ||
        !_sessionCompleted ||
        !_listener.canInstall.value) {
      return const SizedBox.shrink();
    }

    final l10n = context.l10n;

    return Material(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            const Icon(
              Icons.install_mobile_rounded,
              color: Color(AppColors.spritzOrange),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n.installPwa,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            TextButton(
              onPressed: _listener.promptInstall,
              child: Text(l10n.installPwaAction),
            ),
          ],
        ),
      ),
    );
  }
}
