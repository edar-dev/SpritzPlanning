import 'package:flutter/material.dart';

/// Visible keyboard focus ring (WCAG 2.4.7). Child must use [focusNode] on InkWell/Button.
class AppFocusBorder extends StatelessWidget {
  const AppFocusBorder({
    super.key,
    required this.focusNode,
    required this.child,
    this.borderRadius = 16,
  });

  final FocusNode focusNode;
  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: focusNode,
      builder: (context, _) {
        final focused = focusNode.hasFocus;
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: focused
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2.5,
                  )
                : null,
          ),
          child: child,
        );
      },
    );
  }
}

/// Icon color for toolbars on hero gradient / preference bar.
Color appToolbarIconColor(BuildContext context) {
  return Theme.of(context).colorScheme.onSurface;
}
