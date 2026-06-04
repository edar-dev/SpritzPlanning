import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Decorazioni e superfici condivise — rispettano [Theme.of].
abstract final class AppDecorations {
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;

  static BoxDecoration surfaceCard(
    BuildContext context, {
    Color? color,
    double radius = radiusLg,
    bool highlight = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = color ?? scheme.surfaceContainerLowest;
    final borderColor =
        highlight ? scheme.primary.withValues(alpha: 0.35) : scheme.outline;

    return BoxDecoration(
      color: surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor),
      boxShadow: highlight
          ? [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }

  static BoxDecoration heroGradient(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A2522),
            Color(AppColors.darkBackground),
          ],
          stops: [0.0, 0.45],
        ),
      );
    }
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFEDE4),
          Color(AppColors.background),
        ],
        stops: [0.0, 0.45],
      ),
    );
  }

  /// Top bar on home (language / settings) — readable on hero gradient.
  static BoxDecoration preferencesBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: scheme.outline),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration iconBadge(BuildContext context, {bool primary = true}) {
    final scheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: primary ? scheme.primaryContainer : scheme.surfaceContainerLow,
      shape: BoxShape.circle,
    );
  }
}
