import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Decorazioni e superfici condivise.
abstract final class AppDecorations {
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 20;
  static const double radiusXl = 24;

  static BoxDecoration surfaceCard({
    Color? color,
    double radius = radiusLg,
    bool highlight = false,
  }) {
    return BoxDecoration(
      color: color ?? const Color(AppColors.surface),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: highlight
            ? const Color(AppColors.spritzOrange).withValues(alpha: 0.35)
            : const Color(AppColors.border),
      ),
      boxShadow: highlight
          ? [
              BoxShadow(
                color: const Color(AppColors.spritzOrange).withValues(alpha: 0.12),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
    );
  }

  static BoxDecoration heroGradient() {
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
  static BoxDecoration preferencesBar() {
    return BoxDecoration(
      color: const Color(AppColors.surface),
      borderRadius: BorderRadius.circular(radiusMd),
      border: Border.all(color: const Color(AppColors.border)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  static BoxDecoration iconBadge({bool primary = true}) {
    return BoxDecoration(
      color: primary
          ? const Color(AppColors.primarySoft)
          : const Color(AppColors.surfaceMuted),
      shape: BoxShape.circle,
    );
  }
}
