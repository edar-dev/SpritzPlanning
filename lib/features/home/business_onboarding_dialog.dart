import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/app_preferences.dart';
import '../../core/theme/app_colors.dart';

/// Guided time-to-value tour (#87): room → backlog → invite → estimate & report.
enum BusinessOnboardingAction { dismissed, startCreate }

class BusinessOnboardingDialog {
  BusinessOnboardingDialog._();

  static Future<void> maybeShow(
    BuildContext context, {
    void Function()? onStartCreate,
  }) async {
    if (!context.mounted) return;
    final alreadySeen = await AppPreferences.loadHasSeenBusinessOnboarding();
    if (!context.mounted) return;
    if (alreadySeen) return;

    final joinCode = GoRouterState.of(context).uri.queryParameters['code'];
    if (joinCode != null && joinCode.trim().isNotEmpty) return;

    if (!context.mounted) return;
    await _show(context, onStartCreate: onStartCreate);
  }

  /// Replay from help or settings (does not reset outcome metrics).
  static Future<void> showAgain(
    BuildContext context, {
    void Function()? onStartCreate,
  }) {
    return _show(context, onStartCreate: onStartCreate, replay: true);
  }

  static Future<void> _show(
    BuildContext context, {
    void Function()? onStartCreate,
    bool replay = false,
  }) async {
    final action = await showDialog<BusinessOnboardingAction>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _BusinessOnboardingDialogBody(replay: replay),
    );
    if (!context.mounted || action == null) return;
    if (action == BusinessOnboardingAction.startCreate) {
      onStartCreate?.call();
    }
  }
}

class _BusinessOnboardingDialogBody extends StatefulWidget {
  const _BusinessOnboardingDialogBody({this.replay = false});

  final bool replay;

  @override
  State<_BusinessOnboardingDialogBody> createState() =>
      _BusinessOnboardingDialogBodyState();
}

class _BusinessOnboardingDialogBodyState
    extends State<_BusinessOnboardingDialogBody> {
  final _pageController = PageController();
  int _page = 0;

  static const _pageCount = 4;

  Future<void> _skip() async {
    if (!widget.replay) {
      await AppPreferences.markBusinessOnboardingSkipped();
    }
    if (!mounted) return;
    Navigator.pop(context, BusinessOnboardingAction.dismissed);
  }

  Future<void> _complete({required bool startCreate}) async {
    if (!widget.replay) {
      await AppPreferences.markBusinessOnboardingCompleted();
    }
    if (!mounted) return;
    Navigator.pop(
      context,
      startCreate
          ? BusinessOnboardingAction.startCreate
          : BusinessOnboardingAction.dismissed,
    );
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
      (
        Icons.storefront_outlined,
        l10n.businessOnboardingStep1Title,
        l10n.businessOnboardingStep1Body,
      ),
      (
        Icons.upload_file_outlined,
        l10n.businessOnboardingStep2Title,
        l10n.businessOnboardingStep2Body,
      ),
      (
        Icons.group_add_outlined,
        l10n.businessOnboardingStep3Title,
        l10n.businessOnboardingStep3Body,
      ),
      (
        Icons.summarize_outlined,
        l10n.businessOnboardingStep4Title,
        l10n.businessOnboardingStep4Body,
      ),
    ];

    final isLast = _page == _pageCount - 1;
    final progress = (_page + 1) / _pageCount;

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.businessOnboardingTitle),
          const SizedBox(height: 4),
          Text(
            l10n.businessOnboardingSubtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(AppColors.textSecondary),
                ),
          ),
        ],
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
              backgroundColor: const Color(AppColors.border),
              color: const Color(AppColors.spritzOrange),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.businessOnboardingProgress(_page + 1, _pageCount),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(AppColors.textSecondary),
                  ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pageCount,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        page.$1,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page.$2,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        page.$3,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => unawaited(_skip()),
          child: Text(l10n.businessOnboardingSkip),
        ),
        if (!isLast)
          FilledButton(
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            ),
            child: Text(l10n.businessOnboardingNext),
          )
        else ...[
          TextButton(
            onPressed: () => unawaited(_complete(startCreate: false)),
            child: Text(l10n.businessOnboardingDoneLater),
          ),
          FilledButton(
            onPressed: () => unawaited(_complete(startCreate: true)),
            child: Text(l10n.businessOnboardingStart),
          ),
        ],
      ],
    );
  }
}
