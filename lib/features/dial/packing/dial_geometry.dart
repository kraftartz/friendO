import 'dart:math' show cos, pi, sin;
import 'dart:ui' show Offset;

import 'package:friendo_domain/friendo_domain.dart' show Orbit;

/// Where [phase] falls inside one lap, clockwise from 12:00.
///
/// A placed Phase runs to one and below zero, because a Beads Queue that
/// reaches the top carries on past it. Every reading of a place on the lap
/// comes through here, so a drawing cannot forget the wrap and put a Bead off
/// the top of the Dial.
double lapFractionOf(double phase) => phase % 1.0;

/// The measurements of the Dial, in design units.
///
/// Nothing here is a device pixel. The instrument is laid out at [size] and
/// scaled uniformly to the width it is given, so [minGapOf] is a ratio that a
/// scale leaves alone and the capacity of each Orbit holds on every screen.
/// Holding the Bead at a fixed pixel width while the radii grew would change
/// the capacity with the screen, and ADR-0014 measured the capacities once.
class DialGeometry {
  const DialGeometry({
    this.size = 340,
    this.beadWidth = 28,
    this.beadPadding = 4,
    this.innerRadius = 62,
    this.middleRadius = 102,
    this.outerRadius = 142,
  });

  /// The width and the height of the square the instrument is drawn in.
  final double size;

  /// The width of one Bead. One size on every Orbit: Bead width buys arc, and
  /// the outer Orbit holds the longest Cadences, so it needs arc most.
  final double beadWidth;

  /// The clear space between two Beads that rest side by side.
  final double beadPadding;

  final double innerRadius;
  final double middleRadius;
  final double outerRadius;

  double radiusOf(Orbit orbit) => switch (orbit) {
    Orbit.inner => innerRadius,
    Orbit.middle => middleRadius,
    Orbit.outer => outerRadius,
  };

  double circumferenceOf(Orbit orbit) => 2 * pi * radiusOf(orbit);

  /// The width of a trough, which is a Bead and the clear space beside it.
  double get troughWidth => beadWidth + beadPadding;

  /// The middle of the instrument.
  Offset get centre => Offset(size / 2, size / 2);

  /// Where a lap fraction points, in radians, for a canvas whose zero is at
  /// 3:00. The lap runs clockwise from 12:00, so nothing on the Dial needs a
  /// second convention.
  double angleOf(double lapFraction) => -pi / 2 + lapFraction * 2 * pi;

  /// The middle of a Bead resting at [lapFraction] on [orbit].
  Offset placeOn(Orbit orbit, double lapFraction) =>
      placeAt(radiusOf(orbit), lapFraction);

  /// The middle of a Bead at [lapFraction], [radius] out from the centre.
  ///
  /// The radius is free of the three Orbits, because a Bead stepping across
  /// from one to another passes through the space between them.
  Offset placeAt(double radius, double lapFraction) {
    final angle = angleOf(lapFraction);

    return centre + Offset(cos(angle) * radius, sin(angle) * radius);
  }

  /// The smallest space two Beads on [orbit] may keep, as a fraction of one
  /// lap. It falls as the radius grows, which is what gives each Orbit its own
  /// capacity.
  double minGapOf(Orbit orbit) =>
      (beadWidth + beadPadding) / circumferenceOf(orbit);
}
