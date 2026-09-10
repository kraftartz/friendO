import 'package:flutter/material.dart';
import 'package:friendo/features/dial/bloc/dial_state.dart'
    show DialBead, DialOrbit, DialState;
import 'package:friendo/features/dial/packing/dial_geometry.dart'
    show DialGeometry;
import 'package:friendo/features/dial/view/bead_view.dart' show BeadView;
import 'package:friendo/features/dial/view/instrument_painter.dart'
    show InstrumentPainter;
import 'package:friendo/features/dial/view/overflow_badge_view.dart'
    show OverflowBadgeView;
import 'package:friendo_domain/friendo_domain.dart' show Orbit;
import 'package:friendo_ui/friendo_ui.dart' show Soft;

/// The round instrument, with a Bead for every Friend it has room for.
///
/// It is laid out at the design size and scaled to the width it is given, so
/// the Bead keeps its share of the circumference and each Orbit holds the same
/// number of Friends on every screen.
class DialView extends StatelessWidget {
  const DialView({
    required this.reading,
    this.geometry = const DialGeometry(),
    this.onTapBead,
    this.onTapBadge,
    super.key,
  });

  final DialState reading;

  final DialGeometry geometry;

  final void Function(DialBead bead)? onTapBead;

  final void Function(Orbit orbit)? onTapBadge;

  @override
  Widget build(BuildContext context) {
    final soft = Theme.of(context).extension<Soft>() ?? const Soft.dark();

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: geometry.size,
        height: geometry.size,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: InstrumentPainter(
                  geometry: geometry,
                  trough: soft.well,
                  shade: const Color(0xFF06050C),
                  rim: soft.glow,
                  glow: soft.glow,
                ),
              ),
            ),
            for (final orbit in reading.orbits) ..._drawnOn(orbit),
          ],
        ),
      ),
    );
  }

  List<Widget> _drawnOn(DialOrbit orbit) {
    final badge = orbit.badge;

    return [
      for (final bead in orbit.beads)
        _at(
          orbit.orbit,
          bead.lapFraction,
          BeadView(
            key: Key('bead-${bead.id}'),
            bead: bead,
            width: geometry.beadWidth,
            isEmphasised: bead.id == reading.emphasisedId,
            onTap: () => onTapBead?.call(bead),
          ),
        ),
      if (badge != null)
        _at(
          orbit.orbit,
          badge.lapFraction,
          OverflowBadgeView(
            key: Key('overflow-${orbit.orbit.name}'),
            badge: badge,
            width: geometry.beadWidth,
            onTap: () => onTapBadge?.call(orbit.orbit),
          ),
        ),
    ];
  }

  Widget _at(Orbit orbit, double lapFraction, Widget drawn) {
    final middle = geometry.placeOn(orbit, lapFraction);

    return Positioned(
      left: middle.dx - geometry.beadWidth / 2,
      top: middle.dy - geometry.beadWidth / 2,
      child: drawn,
    );
  }
}
