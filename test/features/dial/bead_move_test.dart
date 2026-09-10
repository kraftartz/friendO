import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/features/dial/bloc/dial_state.dart'
    show CadenceChanged, MeetingLogged, PackingCause;
import 'package:friendo/features/dial/motion/bead_move.dart'
    show WayRound, moveDuration, moveOf, restAtTop;
import 'package:friendo_domain/friendo_domain.dart' show Orbit;

void main() {
  /// The move the Bead for 'ola' makes.
  ({WayRound way, double sweep, int stages, double from}) move({
    required double from,
    required double to,
    PackingCause? cause,
    Orbit fromOrbit = Orbit.inner,
    Orbit toOrbit = Orbit.inner,
  }) {
    final made = moveOf(
      friendId: 'ola',
      from: from,
      to: to,
      fromOrbit: fromOrbit,
      toOrbit: toOrbit,
      cause: cause,
    );

    return (
      way: made.way,
      sweep: made.sweep,
      stages: made.stages,
      from: made.from,
    );
  }

  group('a logged Meeting', () {
    test('carries the Bead clockwise, the long way, from Phase 0.3', () {
      final made = move(from: 0.3, to: 0, cause: const MeetingLogged('ola'));

      expect(made.way, WayRound.clockwise);
      expect(made.sweep, closeTo(0.7, 1e-9));
    });

    test('carries the Bead clockwise, the short way, from Phase 0.9', () {
      final made = move(from: 0.9, to: 0, cause: const MeetingLogged('ola'));

      expect(made.way, WayRound.clockwise);
      expect(made.sweep, closeTo(0.1, 1e-9));
    });

    test('sends the other Beads the shorter way, whoever it named', () {
      // The Meeting was not this Bead's, so it was only repacked.
      final made = move(from: 0.3, to: 0, cause: const MeetingLogged('zosia'));

      expect(made.way, WayRound.anticlockwise);
      expect(made.sweep, closeTo(0.3, 1e-9));
    });
  });

  group('a rescale', () {
    test('takes the shorter way from Phase 1.0 to Phase 0.22', () {
      final made = move(from: 1, to: 0.22, cause: const CadenceChanged('ola'));

      expect(made.from, 0);
      expect(made.way, WayRound.clockwise);
      expect(made.sweep, closeTo(0.22, 1e-9));
    });

    test('takes the shorter way across 12:00 when the Cadence shortens', () {
      // A shorter Cadence pushes the Bead further round, across the top.
      final made = move(
        from: 0.95,
        to: 0.05,
        cause: const CadenceChanged('ola'),
      );

      expect(made.way, WayRound.clockwise);
      expect(made.sweep, closeTo(0.1, 1e-9));
    });

    test('takes the shorter way back across 12:00 when it lengthens', () {
      final made = move(
        from: 0.05,
        to: 0.95,
        cause: const CadenceChanged('ola'),
      );

      expect(made.way, WayRound.anticlockwise);
      expect(made.sweep, closeTo(0.1, 1e-9));
    });
  });

  test('a move with no cause takes the shorter way', () {
    final made = move(from: 0.3, to: 0);

    expect(made.way, WayRound.anticlockwise);
    expect(made.sweep, closeTo(0.3, 1e-9));
  });

  group('stages', () {
    test('a move that changes Orbit reports two', () {
      expect(
        move(
          from: 0.3,
          to: 0.1,
          fromOrbit: Orbit.outer,
          toOrbit: Orbit.inner,
        ).stages,
        2,
      );
    });

    test('a move that keeps its Orbit reports one', () {
      expect(move(from: 0.3, to: 0.1).stages, 1);
    });
  });

  group('where the Bead is drawn along the way', () {
    test('starts where it was and ends where it belongs', () {
      final made = moveOf(
        friendId: 'ola',
        from: 0.3,
        to: 0,
        fromOrbit: Orbit.inner,
        toOrbit: Orbit.inner,
        cause: const MeetingLogged('ola'),
      );

      expect(made.lapFractionAt(0), closeTo(0.3, 1e-9));
      expect(made.lapFractionAt(1), closeTo(0, 1e-9));
    });

    test('passes the far side of the lap on the long way round', () {
      final made = moveOf(
        friendId: 'ola',
        from: 0.3,
        to: 0,
        fromOrbit: Orbit.inner,
        toOrbit: Orbit.inner,
        cause: const MeetingLogged('ola'),
      );

      // Halfway through, 0.35 of a lap clockwise of where it started.
      expect(made.lapFractionAt(0.5), closeTo(0.65, 1e-9));
    });

    test('stays inside one lap when it crosses 12:00', () {
      final made = moveOf(
        friendId: 'ola',
        from: 0.95,
        to: 0.05,
        fromOrbit: Orbit.inner,
        toOrbit: Orbit.inner,
        cause: null,
      );

      expect(made.lapFractionAt(0.5), closeTo(0, 1e-9));
      expect(made.lapFractionAt(1), closeTo(0.05, 1e-9));
    });
  });

  test('the whole movement finishes under 600 ms', () {
    expect(moveDuration, lessThan(const Duration(milliseconds: 600)));
  });

  test('a Bead bound for the Overflow rests at 12:00 for about a second', () {
    expect(restAtTop, const Duration(seconds: 1));
  });
}
