import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/deck_values.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/projector_theme.dart';

class SpritzCard extends StatelessWidget {
  const SpritzCard({
    super.key,
    required this.value,
    required this.selected,
    required this.onTap,
    this.onLongPress,
    this.disabled = false,
    this.revealed = false,
  });

  final String value;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool disabled;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final semanticsLabel =
        l10n?.voteCardSemantics(value) ?? 'Vote $value';
    final projector = ProjectorMode.of(context);
    final scale = projector.cardScale;
    final baseW = revealed ? 80.0 : 68.0;
    final baseH = revealed ? 104.0 : 92.0;
    final cardW = baseW * scale;
    final cardH = baseH * scale;

    return Semantics(
      button: !disabled,
      label: semanticsLabel,
      selected: selected,
      child: AnimatedScale(
      scale: selected ? 1.05 : 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
          onLongPress: disabled ? null : onLongPress,
          borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
          child: Ink(
            width: cardW,
            height: cardH,
            decoration: BoxDecoration(
              color: selected
                  ? const Color(AppColors.spritzOrange)
                  : const Color(AppColors.surface),
              borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
              border: Border.all(
                color: selected
                    ? const Color(AppColors.spritzOrange)
                    : const Color(AppColors.border),
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(AppColors.spritzOrange)
                            .withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: value.length > 2 ? 22 : 28,
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? Colors.white
                        : const Color(AppColors.textPrimary),
                  ),
                ),
                if (revealed) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      DeckValues.label(context, value),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? Colors.white.withValues(alpha: 0.85)
                            : const Color(AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
