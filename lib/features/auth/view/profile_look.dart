import 'package:flutter/material.dart';

/// The letter the picker draws for a Profile called [displayName].
String initialOf(String displayName) {
  final name = displayName.trim();

  return name.isEmpty ? '?' : name.characters.first.toUpperCase();
}

/// The colour the picker draws for the Profile with [profileId].
///
/// It comes from the id and never from the name, so that a rename leaves the
/// colour alone. Nothing stores it.
Color colourOf(String profileId) {
  final hue = profileId.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % 360;

  return HSLColor.fromAHSL(1, hue.toDouble(), 0.45, 0.65).toColor();
}
