import 'package:equatable/equatable.dart';

import 'phase.dart';

/// The Phase a Friend stops being Freshly Reset at.
const inOrbitFrom = 0.25;

/// The Phase a Friend starts Nearing their Due Date at.
///
/// It is one number and not two. The last quarter of a lap is also the last
/// quarter of the Dial, from 9:00 round to 12:00, so a drawing that warms that
/// arc reads this rather than an angle of its own. A second copy would let the
/// picture contradict the count printed beside it, which is the failure a
/// boundary in Phase was chosen to avoid.
const nearingFrom = 0.75;

/// How far through their Cadence a Friend has reached, said as a name.
///
/// Phase gives the number and Standing gives the name. The Dial counts Friends
/// by it.
///
/// The boundaries are fractions of a Cadence and not counts of days. A Bead's
/// place on the Dial is its Phase, so a Phase boundary means a count agrees
/// with the screen. "Three days before the Due Date" would call a quarterly
/// Friend Nearing while their Bead still sits a long way from the top.
///
/// See ADR-0029.
enum Standing {
  /// Seen lately. Phase below 0.25.
  freshlyReset,

  /// Travelling, with no call to act. Phase from 0.25 up to 0.75.
  inOrbit,

  /// Close to the Due Date, or resting on it. Phase from 0.75 up to the end of
  /// the Due Date.
  nearing,

  /// The Due Date has passed.
  overdue;

  /// Name the Standing that a Phase falls in.
  ///
  /// [isOverdue] settles the last two apart. It compares two Civil Dates, which
  /// a Phase cannot do.
  static Standing of({required Phase phase, required bool isOverdue}) {
    if (isOverdue) return Standing.overdue;
    if (phase.value < inOrbitFrom) return Standing.freshlyReset;
    if (phase.value < nearingFrom) return Standing.inOrbit;
    return Standing.nearing;
  }
}

/// How many Friends stand in each Standing.
///
/// The four counts add up to every Friend, so a Friend is never counted twice
/// and never left out.
final class DialCounts extends Equatable {
  const DialCounts({
    required this.freshlyReset,
    required this.inOrbit,
    required this.nearing,
    required this.overdue,
  });

  /// Count a run of Standings.
  factory DialCounts.from(Iterable<Standing> standings) {
    var freshlyReset = 0;
    var inOrbit = 0;
    var nearing = 0;
    var overdue = 0;
    for (final standing in standings) {
      switch (standing) {
        case Standing.freshlyReset:
          freshlyReset++;
        case Standing.inOrbit:
          inOrbit++;
        case Standing.nearing:
          nearing++;
        case Standing.overdue:
          overdue++;
      }
    }
    return DialCounts(
      freshlyReset: freshlyReset,
      inOrbit: inOrbit,
      nearing: nearing,
      overdue: overdue,
    );
  }

  final int freshlyReset;
  final int inOrbit;
  final int nearing;
  final int overdue;

  /// Every Friend counted.
  int get total => freshlyReset + inOrbit + nearing + overdue;

  @override
  List<Object?> get props => [freshlyReset, inOrbit, nearing, overdue];
}
