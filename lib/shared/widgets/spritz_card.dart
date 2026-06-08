import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/deck_values.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_focus.dart';
import '../../core/theme/projector_theme.dart';

/// Carta dose stile sottobicchiere / cartellino bancone.
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

  bool get _isCoffee => widget.value == '☕';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final semanticsLabel =
        l10n != null ? l10n.voteCardSemantics(widget.value) : 'Vote ${widget.value}';
    final projector = ProjectorMode.of(context);
    final scale = projector.cardScale;
    final revealScale = projector.voteRevealFontScale;
    final baseW = widget.revealed ? 80.0 : 72.0;
    final baseH = widget.revealed ? 108.0 : 96.0;
    final cardW = baseW * scale;
    final cardH = baseH * scale;

    final unselectedGradient = isDark
        ? [
            const Color(0xFF3D3835),
            scheme.surfaceContainerLowest,
          ]
        : [
            const Color(0xFFFFF8F3),
            const Color(0xFFF5EDE4),
          ];

    return Semantics(
      button: !widget.disabled,
      label: semanticsLabel,
      selected: widget.selected,
      child: AppFocusBorder(
        focusNode: _focusNode,
        child: AnimatedScale(
          scale: widget.selected ? 1.06 : 1,
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
              borderRadius: BorderRadius.circular(18),
              child: Ink(
                width: cardW,
                height: cardH,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: widget.selected
                        ? [
                            const Color(0xFFFF8A50),
                            const Color(AppColors.spritzOrange),
                          ]
                        : unselectedGradient,
                  ),
                  border: Border.all(
                    color: widget.selected
                        ? const Color(AppColors.spritzOrangeDark)
                        : scheme.outline.withValues(alpha: 0.8),
                    width: widget.selected ? 2.5 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: widget.selected ? 0.28 : 0.12,
                      ),
                      blurRadius: widget.selected ? 14 : 8,
                      offset: Offset(0, widget.selected ? 5 : 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 0,
                      left: 12,
                      right: 12,
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: widget.selected
                              ? Colors.white.withValues(alpha: 0.35)
                              : scheme.primary.withValues(alpha: 0.35),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isCoffee)
                            Icon(
                              Icons.local_cafe_rounded,
                              size: (widget.revealed ? 28 : 32) * revealScale,
                              color: widget.selected
                                  ? scheme.onPrimary
                                  : const Color(AppColors.spritzOrange),
                            )
                          else
                            Text(
                              widget.value,
                              style: TextStyle(
                                fontSize:
                                    (widget.value.length > 2 ? 22 : 30) *
                                        revealScale,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                color: widget.selected
                                    ? scheme.onPrimary
                                    : scheme.onSurface,
                              ),
                            ),
                          if (widget.revealed) ...[
                            const SizedBox(height: 6),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Text(
                                DeckValues.label(context, widget.value),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10 * revealScale,
                                  fontWeight: FontWeight.w600,
                                  color: widget.selected
                                      ? scheme.onPrimary.withValues(alpha: 0.92)
                                      : scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (widget.selected && !widget.revealed)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: scheme.onPrimary.withValues(alpha: 0.95),
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
