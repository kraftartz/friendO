import 'package:equatable/equatable.dart';
import 'package:friendo/core/friends/dial_friend.dart' show DialFriend;
import 'package:friendo_domain/friendo_domain.dart'
    show DialCounts, Orbit, Standing;

/// Why the newest packing differs from the one before it.
///
/// The difference between two packings does not say what made it. A Bead that
/// moves from Phase 0.3 to Phase 0 completed a lap when a Meeting caused it,
/// and was rescaled when a Cadence change did, and the two travel opposite
/// ways round. So the reason travels with the packing.
sealed class PackingCause extends Equatable {
  const PackingCause(this.friendId);

  final String friendId;

  @override
  List<Object?> get props => [friendId];
}

/// The User logged a Meeting with this Friend on the Dial.
final class MeetingLogged extends PackingCause {
  const MeetingLogged(super.friendId);
}

/// The User changed this Friend's Cadence on the Dial.
final class CadenceChanged extends PackingCause {
  const CadenceChanged(super.friendId);
}

/// One Friend, as the Dial draws them.
final class DialBead extends Equatable {
  const DialBead({
    required this.friend,
    required this.phase,
    required this.standing,
  });

  final DialFriend friend;

  /// Where the Bead rests, in laps clockwise from 12:00. It runs below zero
  /// once a Beads Queue passes the top of the lap.
  final double phase;

  final Standing standing;

  String get id => friend.id;

  String get name => friend.name;

  /// Where the Bead is drawn, in laps clockwise from 12:00, inside one lap.
  double get lapFraction => phase % 1.0;

  @override
  List<Object?> get props => [friend, phase, standing];
}

/// The last place on a crowded Orbit.
///
/// It takes the place of the Bead that would have rested there, and [count]
/// holds the Friends behind it including that one. It names no Friend and
/// carries no Avatar, so it is not a Bead.
final class OverflowBadge extends Equatable {
  const OverflowBadge({required this.count, required this.phase});

  final int count;

  final double phase;

  double get lapFraction => phase % 1.0;

  @override
  List<Object?> get props => [count, phase];
}

/// One Orbit, as the Dial draws it.
final class DialOrbit extends Equatable {
  const DialOrbit({required this.orbit, required this.beads, this.badge});

  final Orbit orbit;

  /// The Beads that fit, in Priority Order, starting nearest 12:00.
  final List<DialBead> beads;

  /// The Overflow Badge, or null when every Friend on this Orbit is drawn.
  final OverflowBadge? badge;

  @override
  List<Object?> get props => [orbit, beads, badge];
}

/// Everything the Dial draws.
///
/// Locked and empty are different readings and the screen draws them
/// differently. An empty Dial invites the User to add their first Friend; a
/// locked one invites nothing, because there is nothing to say until the
/// Profile is open.
final class DialState extends Equatable {
  const DialState({
    required this.orbits,
    required this.counts,
    this.emphasisedId,
    this.cause,
    this.isLocked = false,
  });

  /// The reading before any Friend has been read, which is also the reading a
  /// lock returns to. It holds no Friend, no name and no count.
  const DialState.locked()
    : orbits = const [],
      counts = const DialCounts(
        freshlyReset: 0,
        inOrbit: 0,
        nearing: 0,
        overdue: 0,
      ),
      emphasisedId = null,
      cause = null,
      isLocked = true;

  /// The three Orbits, inner first. Empty only while locked.
  final List<DialOrbit> orbits;

  /// The four Standings counted. The screen draws three of them: the Overdue
  /// Friends are the Beads Queue, and the User is looking straight at it.
  final DialCounts counts;

  /// The Friend at the head of the Priority Order, or null when there is
  /// nobody to name.
  final String? emphasisedId;

  final PackingCause? cause;

  final bool isLocked;

  /// Whether the Profile is open and holds no Friend.
  bool get isEmpty => !isLocked && orbits.every((orbit) => orbit.isEmpty);

  DialOrbit orbitOf(Orbit orbit) =>
      orbits.firstWhere((held) => held.orbit == orbit);

  @override
  List<Object?> get props => [orbits, counts, emphasisedId, cause, isLocked];
}

extension on DialOrbit {
  bool get isEmpty => beads.isEmpty && badge == null;
}
