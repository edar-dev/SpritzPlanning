import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/deck_values.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';

class SpritzCard extends StatelessWidget {
  const SpritzCard({
    super.key,
    required this.value,
    required this.selected,
    required this.onTap,
    this.disabled = false,
    this.revealed = false,
  });

  final String value;
  final bool selected;
  final VoidCallback onTap;
  final bool disabled;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final label = DeckValues.label(value);

    return AnimatedScale(
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
          borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
          child: Ink(
            width: revealed ? 80 : 68,
            height: revealed ? 104 : 92,
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
                      label,
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
    );
  }
}
