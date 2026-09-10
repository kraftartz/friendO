import 'dart:async';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:friendo/features/dial/bloc/dial_state.dart'
    show DialBead, DialOrbit, DialState, MeetingLogged, OverflowBadge;
import 'package:friendo/features/dial/motion/bead_move.dart'
    show BeadMove, moveDuration, moveOf, restAtTop;
import 'package:friendo/features/dial/packing/dial_geometry.dart'
    show DialGeometry;
import 'package:friendo/features/dial/view/bead_view.dart' show BeadView;
import 'package:friendo/features/dial/view/instrument_painter.dart'
    show InstrumentPainter;
import 'package:friendo/features/dial/view/overflow_badge_view.dart'
    show OverflowBadgeView;
import 'package:friendo_domain/friendo_domain.dart' show Orbit;
import 'package:friendo_ui/friendo_ui.dart' show Soft, colourOf, coloursFor;

/// Where one Bead is travelling, and between which two Orbits.
class _Journey {
  const _Journey({required this.move, required this.from, required this.to});

  final BeadMove move;

  final Orbit from;

  final Orbit to;
}

/// The round instrument, with a Bead for every Friend it has room for.
///
/// It is laid out at the design size and scaled to the width it is given, so
/// the Bead keeps its share of the circumference and each Orbit holds the same
/// number of Friends on every screen.
///
/// It holds the movement, and no bloc does. It is given successive packings
/// and works out the journeys between them. A movement that a lock interrupts
/// is dropped rather than resumed, because the reading it was travelling
/// towards is gone.
class DialView extends StatefulWidget {
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
  State<DialView> createState() => _DialViewState();
}

class _DialViewState extends State<DialView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _travel = AnimationController(
    vsync: this,
    duration: moveDuration,
  );

  Map<String, _Journey> _journeys = const {};

  /// The Bead a logged Meeting sent into the Overflow, resting at 12:00 until
  /// it collapses into the Badge.
  DialBead? _leaving;

  Timer? _resting;

  /// One colour per Friend on the Dial, worked out against the whole roster so
  /// that no two of them are alike.
  late Map<String, Color> _colours = _coloursIn(widget.reading);

  @override
  void didUpdateWidget(DialView old) {
    super.didUpdateWidget(old);
    if (widget.reading == old.reading) return;

    _setOff(from: old.reading, to: widget.reading);
  }

  @override
  void dispose() {
    _resting?.cancel();
    _travel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final soft = Soft.of(context);
    final geometry = widget.geometry;

    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: geometry.size,
        height: geometry.size,
        child: AnimatedBuilder(
          animation: _travel,
          builder: (_, _) => Stack(
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
              for (final orbit in widget.reading.orbits) ..._drawnOn(orbit),
              if (_leaving != null) _leavingBead(_leaving!),
            ],
          ),
        ),
      ),
    );
  }

  void _setOff({required DialState from, required DialState to}) {
    final was = _placesIn(from);
    final journeys = <String, _Journey>{};

    for (final orbit in to.orbits) {
      for (final bead in orbit.beads) {
        final before = was[bead.id];
        if (before == null) continue;

        journeys[bead.id] = _Journey(
          move: moveOf(
            friendId: bead.id,
            from: before.lapFraction,
            to: bead.lapFraction,
            fromOrbit: before.orbit,
            toOrbit: orbit.orbit,
            cause: to.cause,
          ),
          from: before.orbit,
          to: orbit.orbit,
        );
      }
    }

    final leaving = _beadIntoTheOverflow(from: from, to: to, was: was);
    if (leaving != null) {
      journeys[leaving.bead.id] = leaving.journey;
    }

    setState(() {
      _journeys = journeys;
      _leaving = leaving?.bead;
      _colours = _coloursIn(to, leaving: leaving?.bead);
    });

    _travel.forward(from: 0);

    _resting?.cancel();
    // The rest begins where the travel ends. Counting both from here would
    // spend the arrival inside the rest and leave half of it.
    _resting = leaving == null
        ? null
        : Timer(moveDuration + restAtTop, () {
            if (mounted) setState(() => _leaving = null);
          });
  }

  /// The Bead that the newest logged Meeting pushed behind an Overflow Badge,
  /// if there was one. It still travels to 12:00, so the tap that sent it
  /// there is confirmed before the Friend goes.
  ({DialBead bead, _Journey journey})? _beadIntoTheOverflow({
    required DialState from,
    required DialState to,
    required Map<String, ({Orbit orbit, double lapFraction})> was,
  }) {
    final cause = to.cause;
    if (cause is! MeetingLogged) return null;

    final drawn = to.orbits.any(
      (orbit) => orbit.beads.any((bead) => bead.id == cause.friendId),
    );
    if (drawn) return null;

    for (final orbit in from.orbits) {
      for (final bead in orbit.beads) {
        if (bead.id != cause.friendId) continue;

        final before = was[bead.id]!;

        return (
          bead: bead,
          journey: _Journey(
            move: moveOf(
              friendId: bead.id,
              from: before.lapFraction,
              to: 0,
              fromOrbit: before.orbit,
              toOrbit: before.orbit,
              cause: cause,
            ),
            from: before.orbit,
            to: before.orbit,
          ),
        );
      }
    }

    return null;
  }

  /// A colour for every Friend the Dial draws, the one resting on its way into
  /// the Overflow included. A Bead left out of the assignment would fall back
  /// to the colour it asked for, which another Bead may already hold.
  Map<String, Color> _coloursIn(DialState reading, {DialBead? leaving}) =>
      coloursFor([
        for (final orbit in reading.orbits)
          for (final bead in orbit.beads) bead.friend.avatarSeed,
        if (leaving != null) leaving.friend.avatarSeed,
      ]);

  Map<String, ({Orbit orbit, double lapFraction})> _placesIn(
    DialState reading,
  ) => {
    for (final orbit in reading.orbits)
      for (final bead in orbit.beads)
        bead.id: (orbit: orbit.orbit, lapFraction: bead.lapFraction),
  };

  List<Widget> _drawnOn(DialOrbit orbit) {
    final badge = orbit.badge;
    final count = _badgeCountOn(orbit);

    return [
      for (final bead in orbit.beads)
        _at(
          bead.id,
          orbit.orbit,
          bead.lapFraction,
          BeadView(
            key: Key('bead-${bead.id}'),
            bead: bead,
            colour: _colourOf(bead),
            width: widget.geometry.beadWidth,
            isEmphasised: bead.id == widget.reading.emphasisedId,
            onTap: () => widget.onTapBead?.call(bead),
          ),
        ),
      if (badge != null && count > 0)
        _at(
          null,
          orbit.orbit,
          badge.lapFraction,
          OverflowBadgeView(
            key: Key('overflow-${orbit.orbit.name}'),
            badge: OverflowBadge(count: count, phase: badge.phase),
            width: widget.geometry.beadWidth,
            onTap: () => widget.onTapBadge?.call(orbit.orbit),
          ),
        ),
    ];
  }

  /// The count the Badge shows now.
  ///
  /// A Bead still resting at 12:00 has not collapsed into the Badge yet, so
  /// the Badge does not count it until it has.
  int _badgeCountOn(DialOrbit orbit) {
    final badge = orbit.badge;
    if (badge == null) return 0;

    final leaving = _leaving;
    final waiting = leaving != null && leaving.orbit == orbit.orbit;

    return waiting ? badge.count - 1 : badge.count;
  }

  /// A Bead on its way into the Overflow is no longer in the roster the
  /// colours were worked out from, so it keeps the one it asked for.
  Color _colourOf(DialBead bead) =>
      _colours[bead.friend.avatarSeed] ?? colourOf(bead.friend.avatarSeed);

  Widget _leavingBead(DialBead bead) => _at(
    bead.id,
    bead.orbit,
    0,
    BeadView(
      key: Key('bead-${bead.id}'),
      bead: bead,
      colour: _colourOf(bead),
      width: widget.geometry.beadWidth,
      isEmphasised: bead.id == widget.reading.emphasisedId,
      onTap: () => widget.onTapBead?.call(bead),
    ),
  );

  /// Places [drawn] where its journey has reached, or where it belongs when it
  /// is not travelling.
  Widget _at(String? id, Orbit orbit, double lapFraction, Widget drawn) {
    final geometry = widget.geometry;
    final journey = id == null ? null : _journeys[id];

    var radius = geometry.radiusOf(orbit);
    var at = lapFraction;

    if (journey != null && _travel.isAnimating) {
      final t = _travel.value;
      final move = journey.move;
      final travelling = (t / move.travelUntil).clamp(0.0, 1.0);

      at = move.lapFractionAt(travelling);

      // The Bead travels its own Orbit first and steps across after, so it
      // never drags over the Beads between the two.
      final across = move.stages == 1
          ? 1.0
          : ((t - move.travelUntil) / (1 - move.travelUntil)).clamp(0.0, 1.0);
      radius = lerpDouble(
        geometry.radiusOf(journey.from),
        geometry.radiusOf(journey.to),
        across,
      )!;
    }

    final middle = geometry.placeAt(radius, at);

    return Positioned(
      left: middle.dx - geometry.beadWidth / 2,
      top: middle.dy - geometry.beadWidth / 2,
      child: drawn,
    );
  }
}
