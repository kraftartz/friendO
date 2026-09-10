import 'dart:math' show min;

import 'package:equatable/equatable.dart';
import 'package:friendo_domain/friendo_domain.dart'
    show Orbit, Placing, PriorityOrder;

import 'package:friendo/features/dial/packing/dial_geometry.dart'
    show DialGeometry;

/// One Friend, and the Phase their Bead is drawn at.
///
/// [phase] is not always the Friend's own Phase. A Bead that catches the back
/// of the Beads Queue is drawn where the queue leaves room, which is why the
/// packing is a reading of its own rather than a Phase read twice.
final class PlacedBead extends Equatable {
  const PlacedBead({required this.placing, required this.phase});

  final Placing placing;

  /// Where the Bead rests, in laps clockwise from 12:00. It runs below zero
  /// once a Beads Queue passes the top of the lap.
  final double phase;

  /// Where the Bead is drawn, in laps clockwise from 12:00, inside one lap.
  double get lapFraction => phase % 1.0;

  @override
  List<Object?> get props => [placing, phase];
}

/// What one Orbit holds after packing: the Beads it has room for, and the
/// Friends it has not.
final class PackedOrbit extends Equatable {
  const PackedOrbit({
    required this.orbit,
    required this.beads,
    required this.overflow,
  });

  final Orbit orbit;

  /// The Beads that fit, in Priority Order.
  final List<PlacedBead> beads;

  /// The Friends the lap had no room for, in Priority Order.
  final List<Placing> overflow;

  @override
  List<Object?> get props => [orbit, beads, overflow];
}

/// The three Orbits after packing. Every Orbit is present, even an empty one.
final class BeadPacking extends Equatable {
  const BeadPacking(this.orbits);

  final Map<Orbit, PackedOrbit> orbits;

  PackedOrbit on(Orbit orbit) => orbits[orbit]!;

  @override
  List<Object?> get props => [orbits];
}

/// Places every Friend in [order] on the Orbit their Cadence names.
///
/// Each Orbit is packed on its own, so Orbits never compete for arc they do
/// not share. The partition keeps the order it is given, so the order inside
/// an Orbit can never contradict the Priority Order.
BeadPacking packBeads(
  PriorityOrder order, {
  DialGeometry geometry = const DialGeometry(),
}) {
  final ranked = order.all;

  return BeadPacking({
    for (final orbit in Orbit.values)
      orbit: _packOrbit(orbit, [
        for (final placing in ranked)
          if (placing.cadence.orbit == orbit) placing,
      ], geometry.minGapOf(orbit)),
  });
}

PackedOrbit _packOrbit(Orbit orbit, List<Placing> members, double minGap) {
  final beads = <PlacedBead>[];
  final overflow = <Placing>[];

  // 12:00, in Phase units. It walks down the lap, and below zero once the
  // Beads Queue passes the top.
  var cursor = 1.0;
  double? first;

  for (final placing in members) {
    // A Phase above one clamps to one, and a Bead that catches the queue
    // slows into the back of it. One expression covers both, so being Overdue
    // asks for no branch of its own.
    final placed = min(placing.phase.value, cursor);

    // Phase 1.0 and Phase 0.0 are the same place, so the last Bead has to keep
    // a full gap from the first one, measured the short way round. Stopping at
    // a cursor of zero instead admits one Bead too many.
    if (first != null && placed < minGap + first - 1) {
      overflow.add(placing);
      continue;
    }

    first ??= placed;
    beads.add(PlacedBead(placing: placing, phase: placed));
    cursor = placed - minGap;
  }

  return PackedOrbit(
    orbit: orbit,
    beads: List.unmodifiable(beads),
    overflow: List.unmodifiable(overflow),
  );
}
