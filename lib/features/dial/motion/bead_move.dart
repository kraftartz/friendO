import 'package:equatable/equatable.dart';
import 'package:friendo/features/dial/bloc/dial_state.dart'
    show MeetingLogged, PackingCause;
import 'package:friendo_domain/friendo_domain.dart' show Orbit;

/// How long a Bead takes to reach where it belongs.
///
/// A two-stage move is longer than a straight one, and this covers both. Above
/// about 600 ms the Dial feels slow on the one action the User repeats.
const moveDuration = Duration(milliseconds: 500);

/// How long a Bead that a Meeting sends into the Overflow rests at 12:00.
///
/// For this long the Dial draws a picture the packer disagrees with. That is
/// deliberate: logging a Meeting is the one rewarding act in the app, and a
/// Bead that vanishes on touch reads as a fault rather than as a result.
const restAtTop = Duration(seconds: 1);

/// Which way round the lap a Bead travels.
enum WayRound { clockwise, anticlockwise }

/// One Bead's journey from where it is drawn to where it belongs.
final class BeadMove extends Equatable {
  const BeadMove({
    required this.from,
    required this.way,
    required this.sweep,
    required this.stages,
  });

  /// Where the Bead starts, in laps clockwise from 12:00.
  final double from;

  final WayRound way;

  /// How far the Bead travels, in laps. Never negative: [way] carries the
  /// direction.
  final double sweep;

  /// Two when the Bead changes Orbit, one when it does not.
  ///
  /// A Bead that changes Orbit travels its own Orbit to the finishing angle
  /// first and steps across after, so it never drags over the Beads between
  /// the two. A Bead that keeps its Orbit runs the same rule with an empty
  /// second stage, which is why this is a count rather than two rules.
  final int stages;

  /// Where the Bead is drawn [t] of the way through the move, as a lap
  /// fraction inside one lap.
  double lapFractionAt(double t) =>
      (from + (way == WayRound.clockwise ? sweep : -sweep) * t) % 1.0;

  /// How far through the whole move the first stage ends.
  ///
  /// A Bead that keeps its Orbit travels for all of it.
  double get travelUntil => stages == 1 ? 1 : 0.7;

  @override
  List<Object?> get props => [from, way, sweep, stages];
}

/// Works out how the Bead for [friendId] travels from [from] to [to].
///
/// A logged Meeting **completes** the lap, so its Bead carries on clockwise to
/// the top however far that is. Everything else **rescales** the lap: nothing
/// was completed, so the Bead takes the shorter of the two ways.
///
/// A change the Dial did not cause carries no cause and takes the short way.
/// The User was not looking at the Dial when they made it, so there is no lap
/// to narrate.
BeadMove moveOf({
  required String friendId,
  required double from,
  required double to,
  required Orbit fromOrbit,
  required Orbit toOrbit,
  required PackingCause? cause,
}) {
  final start = from % 1.0;
  final clockwise = (to % 1.0 - start) % 1.0;
  final stages = fromOrbit == toOrbit ? 1 : 2;
  final completesTheLap = cause is MeetingLogged && cause.friendId == friendId;

  if (completesTheLap || clockwise <= 0.5) {
    return BeadMove(
      from: start,
      way: WayRound.clockwise,
      sweep: clockwise,
      stages: stages,
    );
  }

  return BeadMove(
    from: start,
    way: WayRound.anticlockwise,
    sweep: 1 - clockwise,
    stages: stages,
  );
}
