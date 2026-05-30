import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

/// Pulsante azione stile card per la home e menu.
class SpritzActionTile extends StatelessWidget {
  const SpritzActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
        child: Ink(
          decoration: AppDecorations.surfaceCard(
            highlight: primary,
            radius: AppDecorations.radiusLg,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: AppDecorations.iconBadge(primary: primary),
                  child: Icon(
                    icon,
                    color: primary
                        ? const Color(AppColors.spritzOrange)
                        : const Color(AppColors.oliveGreen),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(AppColors.textPrimary),
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(AppColors.textSecondary),
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: const Color(AppColors.textSecondary).withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
