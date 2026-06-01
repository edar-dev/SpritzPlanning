import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_theme.dart';

/// Forza tema chiaro per card/form su superfici bianche.
///
/// Con [ThemeMode.dark] o sistema scuro, i widget figli ereditano altrimenti
/// testi chiari e campi scuri su card bianche (contrasto illeggibile).
class LightSurfaceScope extends StatelessWidget {
  const LightSurfaceScope({super.key, required this.child});

  final Widget child;

  static ThemeData get theme {
    final base = AppTheme.light;
    const onSurface = Color(AppColors.textPrimary);
    const onSurfaceVariant = Color(AppColors.textSecondary);

    return base.copyWith(
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(AppColors.spritzOrangeDark),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: base.inputDecorationTheme.copyWith(
        fillColor: const Color(AppColors.surfaceMuted),
        labelStyle: const TextStyle(
          color: onSurface,
          fontWeight: FontWeight.w600,
        ),
        floatingLabelStyle: const TextStyle(
          color: onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: const TextStyle(color: Color(AppColors.textMuted)),
        prefixIconColor: onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(data: theme, child: child);
  }
}
