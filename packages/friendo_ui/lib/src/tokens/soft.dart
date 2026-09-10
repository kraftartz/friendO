import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// The friendO design tokens.
///
/// Flutter has no CSS variables. [ThemeExtension] is the nearest thing, so the
/// tokens ride inside [ThemeData.extensions] and every widget reads them from
/// the [BuildContext].
///
/// Read these values, never copy them. A colour written straight into a widget
/// stops following the theme the moment the theme changes.
@immutable
class Soft extends ThemeExtension<Soft> {
  /// Create a token set from explicit values.
  const Soft({
    required this.surface,
    required this.glow,
    required this.radius,
    this.well = const Color(0xFF090711),
  });

  /// Create the dark token set.
  ///
  /// This is the only set that exists today. Add `Soft.light()` beside it if a
  /// second appearance is ever wanted.
  const Soft.dark()
    : surface = const Color(0xFF211C33),
      glow = const Color(0xFFD0BCFF),
      radius = 20,
      well = const Color(0xFF090711);

  /// The colour of a raised surface.
  final Color surface;

  /// The colour that surrounds a surface and suggests light behind it.
  final Color glow;

  /// The corner radius of a surface, in logical pixels.
  final double radius;

  /// The fill of a surface that sinks into the one behind it: an input, a
  /// Phase track, an empty Orbit.
  final Color well;

  @override
  Soft copyWith({Color? surface, Color? glow, double? radius, Color? well}) =>
      Soft(
        surface: surface ?? this.surface,
        glow: glow ?? this.glow,
        radius: radius ?? this.radius,
        well: well ?? this.well,
      );

  @override
  Soft lerp(covariant ThemeExtension<Soft>? other, double t) {
    if (other is! Soft) return this;
    return Soft(
      surface: Color.lerp(surface, other.surface, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
      radius: lerpDouble(radius, other.radius, t)!,
      well: Color.lerp(well, other.well, t)!,
    );
  }
}
