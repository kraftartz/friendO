import 'package:flutter/material.dart';

/// The one letter that stands for a Profile called [displayName].
String initialOf(String displayName) {
  final name = displayName.trim();

  return name.isEmpty ? '?' : name.characters.first.toUpperCase();
}

/// The colour that stands for the Profile with [profileId].
///
/// It comes from the id and never from the name, so that a rename leaves the
/// colour alone. It is worked out on every read and stored nowhere.
Color colourOf(String profileId) {
  final hue = profileId.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % 360;

  return HSLColor.fromAHSL(1, hue.toDouble(), 0.45, 0.65).toColor();
}
