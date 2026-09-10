import 'dart:math' show pi;

import 'package:friendo_domain/friendo_domain.dart' show Orbit;

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

  /// The smallest space two Beads on [orbit] may keep, as a fraction of one
  /// lap. It falls as the radius grows, which is what gives each Orbit its own
  /// capacity.
  double minGapOf(Orbit orbit) =>
      (beadWidth + beadPadding) / circumferenceOf(orbit);
}
