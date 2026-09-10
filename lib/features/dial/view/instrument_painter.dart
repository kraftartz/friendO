import 'package:flutter/material.dart';
import 'package:friendo/features/dial/packing/dial_geometry.dart'
    show DialGeometry;
import 'package:friendo_domain/friendo_domain.dart' show Orbit, nearingFrom;

/// The instrument the Beads travel on: three debossed troughs, the 12:00 axis,
/// and the conic glow over the last quarter of the lap.
///
/// Every shape here is one shape and none of them takes a tap, which is why
/// they are painted rather than built. The Beads are widgets, because they are
/// what moves and what a finger lands on.
///
/// The glow starts where a Friend starts Nearing, and it reads that Phase from
/// the domain. A hand-tuned angle would be a second copy of a number the count
/// beside the Dial also uses, and the two would drift.
///
/// Flutter's BoxShadow has no inset, so the sunk look is drawn here: a dark
/// stroke pushed up and left, and a pale one pushed down and right, both
/// clipped to the trough they belong to.
class InstrumentPainter extends CustomPainter {
  const InstrumentPainter({
    required this.geometry,
    required this.trough,
    required this.shade,
    required this.rim,
    required this.glow,
  });

  final DialGeometry geometry;

  /// The fill of an empty trough.
  final Color trough;

  /// The occlusion that gives a trough its depth.
  final Color shade;

  /// The pale edge opposite the occlusion, and the 12:00 axis.
  final Color rim;

  /// The warmth over the last quarter of the lap.
  final Color glow;

  @override
  void paint(Canvas canvas, Size size) {
    for (final orbit in Orbit.values) {
      _paintTrough(canvas, orbit);
    }
    _paintGlow(canvas);
    _paintAxis(canvas);
  }

  @override
  bool shouldRepaint(InstrumentPainter old) =>
      old.geometry != geometry ||
      old.trough != trough ||
      old.shade != shade ||
      old.rim != rim ||
      old.glow != glow;

  void _paintTrough(Canvas canvas, Orbit orbit) {
    final radius = geometry.radiusOf(orbit);
    final width = geometry.troughWidth;
    final band = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = trough;

    canvas.drawCircle(geometry.centre, radius, band);

    canvas
      ..save()
      ..clipPath(_ringOf(radius, width));
    canvas
      ..drawCircle(
        geometry.centre.translate(-4, -4),
        radius,
        _blurred(shade, width),
      )
      ..drawCircle(
        geometry.centre.translate(3, 3),
        radius,
        _blurred(rim.withValues(alpha: 0.12), width),
      )
      ..restore();
  }

  /// The last quarter of the lap, warmed. It runs from 9:00 round to 12:00,
  /// which is [nearingFrom] of one lap clockwise from the top.
  void _paintGlow(Canvas canvas) {
    final width = geometry.troughWidth;
    final reach = geometry.radiusOf(Orbit.outer) + width / 2;
    final hub = geometry.radiusOf(Orbit.inner) - width / 2;
    final face = Rect.fromCircle(center: geometry.centre, radius: reach);
    final sweep = Paint()
      ..shader = SweepGradient(
        startAngle: geometry.angleOf(nearingFrom),
        endAngle: geometry.angleOf(1),
        colors: [glow.withValues(alpha: 0), glow.withValues(alpha: 0.45)],
        tileMode: TileMode.decal,
      ).createShader(face);

    // Only where a Bead can travel. Warming the hub as well would say the
    // middle of the Dial meant something, and it means nothing.
    canvas
      ..save()
      ..clipPath(
        Path.combine(
          PathOperation.difference,
          Path()..addOval(face),
          Path()
            ..addOval(Rect.fromCircle(center: geometry.centre, radius: hub)),
        ),
      );
    canvas
      ..drawCircle(geometry.centre, reach, sweep)
      ..restore();
  }

  void _paintAxis(Canvas canvas) {
    final outer = geometry.radiusOf(Orbit.outer) + geometry.troughWidth / 2;
    final inner = geometry.radiusOf(Orbit.inner) - geometry.troughWidth / 2;

    canvas.drawLine(
      geometry.centre.translate(0, -outer),
      geometry.centre.translate(0, -inner),
      Paint()
        ..strokeWidth = 2
        ..color = rim.withValues(alpha: 0.55),
    );
  }

  Path _ringOf(double radius, double width) => Path.combine(
    PathOperation.difference,
    Path()..addOval(
      Rect.fromCircle(center: geometry.centre, radius: radius + width / 2),
    ),
    Path()..addOval(
      Rect.fromCircle(center: geometry.centre, radius: radius - width / 2),
    ),
  );

  Paint _blurred(Color colour, double width) => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..color = colour
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
}
