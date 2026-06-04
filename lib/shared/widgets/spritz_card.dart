import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/deck_values.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import '../../core/theme/app_focus.dart';
import '../../core/theme/projector_theme.dart';

class SpritzCard extends StatefulWidget {
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
  State<SpritzCard> createState() => _SpritzCardState();
}

class _SpritzCardState extends State<SpritzCard> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final semanticsLabel =
        l10n != null ? l10n.voteCardSemantics(widget.value) : 'Vote ${widget.value}';
    final projector = ProjectorMode.of(context);
    final scale = projector.cardScale;
    final baseW = widget.revealed ? 80.0 : 68.0;
    final baseH = widget.revealed ? 104.0 : 92.0;
    final cardW = baseW * scale;
    final cardH = baseH * scale;

    return Semantics(
      button: !widget.disabled,
      label: semanticsLabel,
      selected: widget.selected,
      child: AppFocusBorder(
        focusNode: _focusNode,
        child: AnimatedScale(
          scale: widget.selected ? 1.05 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              focusNode: _focusNode,
              onTap: widget.disabled
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      widget.onTap();
                    },
              onLongPress: widget.disabled ? null : widget.onLongPress,
              borderRadius: BorderRadius.circular(AppDecorations.radiusMd),
              child: Ink(
                width: cardW,
                height: cardH,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? scheme.primary
                      : scheme.surfaceContainerLowest,
                  borderRadius:
                      BorderRadius.circular(AppDecorations.radiusMd),
                  border: Border.all(
                    color: widget.selected
                        ? const Color(AppColors.spritzOrangeDark)
                        : scheme.outline,
                    width: widget.selected ? 3 : 1,
                  ),
                  boxShadow: widget.selected
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.value,
                          style: TextStyle(
                            fontSize: widget.value.length > 2 ? 22 : 28,
                            fontWeight: FontWeight.w700,
                            color: widget.selected
                                ? scheme.onPrimary
                                : scheme.onSurface,
                          ),
                        ),
                        if (widget.revealed) ...[
                          const SizedBox(height: 4),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              DeckValues.label(context, widget.value),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: widget.selected
                                    ? scheme.onPrimary.withValues(alpha: 0.9)
                                    : scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (widget.selected && !widget.revealed)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Icon(
                          Icons.check_circle,
                          size: 18,
                          color: Colors.white.withValues(alpha: 0.95),
                          semanticLabel: '',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
