import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_config.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/preferences/app_preferences.dart';

class FeedbackDialog {
  FeedbackDialog._();

  static Future<void> maybeShow(BuildContext context) async {
    if (!context.mounted) return;
    if (await AppPreferences.loadHasSubmittedFeedback()) return;

    if (!context.mounted) return;
    final l10n = context.l10n;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.feedbackTitle),
        content: Text(l10n.feedbackSubtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'dismiss'),
            child: Text(l10n.feedbackDismiss),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'negative'),
            child: Text(l10n.feedbackNegative),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, 'positive'),
            child: Text(l10n.feedbackPositive),
          ),
        ],
      ),
    );

    await AppPreferences.markFeedbackSubmitted();
    if (!context.mounted) return;

    if (result == 'negative' || result == 'positive') {
      final suggest = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.feedbackSuggest),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.feedbackDismiss),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.feedbackSuggest),
            ),
          ],
        ),
      );
      if (suggest == true) {
        await Share.share(AppConfig.feedbackUrl);
      }
    }
  }
}
