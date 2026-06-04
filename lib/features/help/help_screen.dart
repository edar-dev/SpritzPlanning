import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../home/business_onboarding_dialog.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/light_surface_scope.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final features = [
      (Icons.dashboard_customize_outlined, l10n.helpFeatTemplates),
      (Icons.upload_file_outlined, l10n.helpFeatImport),
      (Icons.bolt_outlined, l10n.helpFeatSpike),
      (Icons.lock_outline, l10n.helpFeatPin),
      (Icons.auto_awesome_outlined, l10n.helpFeatAutoReveal),
      (Icons.copy_all_outlined, l10n.helpFeatDuplicate),
      (Icons.summarize_outlined, l10n.helpFeatReport),
      (Icons.notifications_outlined, l10n.helpFeatNotify),
      (Icons.tv_outlined, l10n.helpFeatProjector),
      (Icons.restore_rounded, l10n.helpFeatResume),
    ];

    final faqs = [
      (l10n.helpFaqNicknameTitle, l10n.helpFaqNicknameBody),
      (l10n.helpFaqRejoinTitle, l10n.helpFaqRejoinBody),
      (l10n.helpFaqPinTitle, l10n.helpFaqPinBody),
      (l10n.helpFaqObserverTitle, l10n.helpFaqObserverBody),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.helpTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: LightSurfaceScope(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _SectionCard(
              title: l10n.appName,
              body: l10n.helpIntro,
              icon: Icons.local_bar_rounded,
            ),
            _SectionCard(
              title: l10n.helpRolesTitle,
              body: l10n.helpRolesBody,
              icon: Icons.people_outline,
            ),
            _SectionCard(
              title: l10n.helpFlowTitle,
              body: l10n.helpFlowBody,
              icon: Icons.route_outlined,
            ),
            Text(
              l10n.helpFeaturesTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            ...features.map(
              (f) => ListTile(
                leading: Icon(f.$1, color: const Color(AppColors.spritzOrange)),
                title: Text(f.$2, style: Theme.of(context).textTheme.bodyMedium),
                dense: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.helpFaqTitle,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            ...faqs.map(
              (f) => ExpansionTile(
                title: Text(f.$1),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(f.$2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => BusinessOnboardingDialog.showAgain(context),
              icon: const Icon(Icons.play_lesson_outlined),
              label: Text(l10n.helpReplayBusinessOnboarding),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: l10n.helpShortcutsTitle,
              body:
                  '${l10n.keyboardShortcutReveal}\n${l10n.keyboardShortcutNext}\n${l10n.keyboardShortcutStartVote}',
              icon: Icons.keyboard_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: AppDecorations.surfaceCard(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(AppColors.spritzOrange)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(body),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
