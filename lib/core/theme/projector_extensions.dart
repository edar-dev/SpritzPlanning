import 'package:flutter/material.dart';

/// Viewport / accessibility heuristics for auto projector mode (#119).
abstract final class ProjectorAutoDetect {
  static const wideViewportBreakpoint = 1200.0;
  static const largeTextScaleThreshold = 1.15;

  static bool shouldAutoEnable(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width >= wideViewportBreakpoint) return true;
    return MediaQuery.textScalerOf(context).scale(1) >= largeTextScaleThreshold;
  }

  /// Manual global toggle wins; otherwise auto when preference is on.
  static bool effectiveProjector({
    required BuildContext context,
    required bool globalManual,
    required bool autoPrefEnabled,
    required bool sessionDisabled,
  }) {
    if (globalManual) return true;
    if (sessionDisabled || !autoPrefEnabled) return false;
    return shouldAutoEnable(context);
  }
}
