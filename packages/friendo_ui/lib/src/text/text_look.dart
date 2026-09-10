import 'package:flutter/material.dart';

/// The one letter that stands for [text].
///
/// It answers a question mark for text that holds nothing but spaces, so that
/// a caller always has something to draw.
String initialOf(String text) {
  final trimmed = text.trim();

  return trimmed.isEmpty ? '?' : trimmed.characters.first.toUpperCase();
}

/// A colour worked out from [text].
///
/// The same text always gives the same colour, and the colour is worked out on
/// every read and stored nowhere. Two different texts may land on the same
/// colour, so a colour decorates and never identifies: it belongs beside a
/// name, and never instead of one.
Color colourOf(String text) {
  final hue = text.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % 360;

  return HSLColor.fromAHSL(1, hue.toDouble(), 0.45, 0.65).toColor();
}
