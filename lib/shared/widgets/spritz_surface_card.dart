import 'package:flutter/material.dart';

import '../../core/theme/app_decorations.dart';

/// Card con superficie e contenuto allineati al tema corrente.
class SpritzSurfaceCard extends StatelessWidget {
  const SpritzSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.highlight = false,
    this.radius,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool highlight;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: AppDecorations.surfaceCard(
        context,
        highlight: highlight,
        radius: radius ?? AppDecorations.radiusLg,
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
