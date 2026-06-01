import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/app_preferences.dart';

/// First-visit walkthrough (#60).
class OnboardingDialog {
  OnboardingDialog._();

  static Future<void> maybeShow(BuildContext context) async {
    if (!context.mounted) return;
    if (await AppPreferences.loadHasSeenOnboarding()) return;

    if (!context.mounted) return;
    final joinCode = GoRouterState.of(context).uri.queryParameters['code'];
    if (joinCode != null && joinCode.trim().isNotEmpty) return;

    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _OnboardingDialogBody(),
    );
  }
}

class _OnboardingDialogBody extends StatefulWidget {
  const _OnboardingDialogBody();

  @override
  State<_OnboardingDialogBody> createState() => _OnboardingDialogBodyState();
}

class _OnboardingDialogBodyState extends State<_OnboardingDialogBody> {
  final _pageController = PageController();
  int _page = 0;

  static const _pageCount = 4;

  Future<void> _finish({bool openHelp = false}) async {
    await AppPreferences.markOnboardingSeen();
    if (!mounted) return;
    Navigator.pop(context);
    if (openHelp && mounted) {
      context.push('/help');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = [
      (Icons.local_bar_rounded, l10n.onboardingWelcomeTitle, l10n.onboardingWelcomeBody),
      (Icons.storefront_outlined, l10n.onboardingCreateTitle, l10n.onboardingCreateBody),
      (Icons.door_front_door_outlined, l10n.onboardingJoinTitle, l10n.onboardingJoinBody),
      (Icons.help_outline_rounded, l10n.onboardingHelpTitle, l10n.onboardingHelpBody),
    ];

    final isLast = _page == _pageCount - 1;

    return AlertDialog(
      title: Text(pages[_page].$2),
      content: SizedBox(
        width: 360,
        height: 220,
        child: PageView.builder(
          controller: _pageController,
          itemCount: _pageCount,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (context, index) {
            final page = pages[index];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(page.$1, size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 16),
                Text(
                  page.$3,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => unawaited(_finish()),
          child: Text(l10n.onboardingSkip),
        ),
        if (!isLast)
          FilledButton(
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            ),
            child: Text(l10n.onboardingNext),
          )
        else
          FilledButton(
            onPressed: () => unawaited(_finish(openHelp: true)),
            child: Text(l10n.onboardingDone),
          ),
      ],
    );
  }
}
