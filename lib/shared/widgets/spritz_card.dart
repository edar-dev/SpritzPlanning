import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/deck_values.dart';
import '../../core/theme/app_colors.dart';

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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.primary
            : const Color(AppColors.voteCard),
        borderRadius: BorderRadius.circular(16),
        elevation: selected ? 6 : 2,
        child: InkWell(
          onTap: disabled
              ? null
              : () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: revealed ? 80 : 72,
            height: revealed ? 110 : 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : const Color(AppColors.oliveGreen).withValues(alpha: 0.3),
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: value.length > 2 ? 24 : 32,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : const Color(AppColors.darkWood),
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
                        color: selected
                            ? Colors.white70
                            : const Color(AppColors.darkWood).withValues(alpha: 0.7),
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
