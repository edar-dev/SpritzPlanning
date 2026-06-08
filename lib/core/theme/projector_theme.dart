import 'package:flutter/material.dart';

/// Theme extension: larger cards and text when projector / room mode is on.
class ProjectorMode extends ThemeExtension<ProjectorMode> {
  const ProjectorMode({this.enabled = false});

  final bool enabled;

  static ProjectorMode of(BuildContext context) {
    return Theme.of(context).extension<ProjectorMode>() ??
        const ProjectorMode();
  }

  double get cardScale => enabled ? 1.25 : 1.0;

  double get deckSpacing => enabled ? 18.0 : 12.0;

  double get voteRevealFontScale => enabled ? 1.25 : 1.0;

  double get appBarHeight => enabled ? 80.0 : 64.0;

  @override
  ProjectorMode copyWith({bool? enabled}) {
    return ProjectorMode(enabled: enabled ?? this.enabled);
  }

  @override
  ProjectorMode lerp(ThemeExtension<ProjectorMode>? other, double t) {
    if (other is! ProjectorMode) return this;
    return ProjectorMode(enabled: t < 0.5 ? enabled : other.enabled);
  }
}
