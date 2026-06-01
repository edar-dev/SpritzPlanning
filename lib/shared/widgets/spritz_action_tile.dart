import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_focus.dart';

/// Pulsante azione stile card per la home e menu.
class SpritzActionTile extends StatefulWidget {
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
  State<SpritzActionTile> createState() => _SpritzActionTileState();
}

class _SpritzActionTileState extends State<SpritzActionTile> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      enabled: enabled,
      label: '${widget.title}. ${widget.subtitle}',
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: AppFocusBorder(
          focusNode: _focusNode,
          borderRadius: AppDecorations.radiusLg,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              focusNode: _focusNode,
              onTap: enabled
                  ? () {
                      HapticFeedback.lightImpact();
                      widget.onTap!();
                    }
                  : null,
              borderRadius: BorderRadius.circular(AppDecorations.radiusLg),
              child: Ink(
                decoration: AppDecorations.surfaceCard(
                  highlight: widget.primary,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: AppDecorations.iconBadge(
                          primary: widget.primary,
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.primary
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
                              widget.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(AppColors.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.subtitle,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: const Color(AppColors.textSecondary),
                        semanticLabel: '',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
