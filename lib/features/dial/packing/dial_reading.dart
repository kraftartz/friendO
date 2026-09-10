import 'package:friendo/core/friends/dial_friend.dart' show DialFriend;
import 'package:friendo/features/dial/bloc/dial_state.dart'
    show DialBead, DialOrbit, DialState, OverflowBadge, PackingCause;
import 'package:friendo/features/dial/packing/bead_packer.dart'
    show PackedOrbit, packBeads;
import 'package:friendo/features/dial/packing/dial_geometry.dart'
    show DialGeometry;
import 'package:friendo_domain/friendo_domain.dart' show Orbit, PriorityOrder;

/// Turns the Friends the store gave into the picture the Dial draws.
///
/// One `now` for the whole packing. Two readings a millisecond apart would be
/// indistinguishable on screen, and would leave two Beads that were compared
/// against different instants.
DialState readDial({
  required List<DialFriend> friends,
  required DateTime now,
  required DialGeometry geometry,
  required PackingCause? cause,
}) {
  final byId = {for (final friend in friends) friend.id: friend};
  final order = PriorityOrder([
    for (final friend in friends) friend.placingAt(now),
  ]);
  final packed = packBeads(order, geometry: geometry);

  return DialState(
    orbits: [
      for (final orbit in Orbit.values) _drawOrbit(packed.on(orbit), byId),
    ],
    counts: order.counts,
    emphasisedId: order.next?.friendId,
    cause: cause,
  );
}

DialOrbit _drawOrbit(PackedOrbit packed, Map<String, DialFriend> byId) {
  final beads = [
    for (final bead in packed.beads)
      DialBead(
        friend: byId[bead.placing.friendId]!,
        phase: bead.phase,
        standing: bead.placing.standing,
      ),
  ];

  if (packed.overflow.isEmpty) {
    return DialOrbit(orbit: packed.orbit, beads: beads);
  }

  // The Badge takes the last place on the Orbit, so the Bead that would have
  // rested there is one of the Friends it stands for.
  final displaced = beads.last;

  return DialOrbit(
    orbit: packed.orbit,
    beads: beads.sublist(0, beads.length - 1),
    badge: OverflowBadge(
      count: packed.overflow.length + 1,
      phase: displaced.phase,
    ),
  );
}
