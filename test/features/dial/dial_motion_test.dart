import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/theme.dart' show friendoTheme;
import 'package:friendo/core/friends/dial_friend.dart' show DialFriend;
import 'package:friendo/features/dial/bloc/dial_state.dart'
    show DialBead, DialOrbit, DialState, MeetingLogged, OverflowBadge;
import 'package:friendo/features/dial/motion/bead_move.dart'
    show moveDuration, restAtTop;
import 'package:friendo/features/dial/packing/dial_geometry.dart'
    show DialGeometry;
import 'package:friendo/features/dial/view/dial_view.dart' show DialView;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, DialCounts, Orbit, Standing;

void main() {
  const geometry = DialGeometry();
  const noCounts = DialCounts(
    freshlyReset: 0,
    inOrbit: 0,
    nearing: 0,
    overdue: 0,
  );

  final today = DateTime(2026, 9, 10);

  DialFriend aFriend(String id, {int cadenceDays = 7}) => DialFriend(
    id: id,
    name: id,
    cadence: Cadence.ofDays(cadenceDays),
    lastMet: CivilDate.from(today),
  );

  DialState reading(
    List<DialOrbit> orbits, {
    MeetingLogged? cause,
    String? emphasisedId,
  }) => DialState(
    orbits: [
      for (final orbit in Orbit.values)
        orbits.firstWhere(
          (held) => held.orbit == orbit,
          orElse: () => DialOrbit(orbit: orbit, beads: const []),
        ),
    ],
    counts: noCounts,
    emphasisedId: emphasisedId,
    cause: cause,
  );

  DialBead aBead(String id, double phase, {int cadenceDays = 7}) => DialBead(
    friend: aFriend(id, cadenceDays: cadenceDays),
    phase: phase,
    standing: Standing.inOrbit,
  );

  Future<void> show(WidgetTester tester, DialState held) => tester.pumpWidget(
    MaterialApp(
      theme: friendoTheme(),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: geometry.size,
            height: geometry.size,
            child: DialView(reading: held, geometry: geometry),
          ),
        ),
      ),
    ),
  );

  /// Where the Bead sits relative to the middle of the Dial.
  Offset offsetOf(WidgetTester tester, String id) {
    final middle = tester.getCenter(find.byType(DialView));

    return tester.getCenter(find.byKey(Key('bead-$id'))) - middle;
  }

  testWidgets('a logged Meeting carries the Bead round the far side', (
    tester,
  ) async {
    // Phase 0.3 is past 3:00, so the long way clockwise passes 6:00 and 9:00.
    await show(
      tester,
      reading([
        DialOrbit(orbit: Orbit.inner, beads: [aBead('ola', 0.3)]),
      ]),
    );
    expect(offsetOf(tester, 'ola').dx, greaterThan(0));

    await show(
      tester,
      reading([
        DialOrbit(orbit: Orbit.inner, beads: [aBead('ola', 0)]),
      ], cause: const MeetingLogged('ola')),
    );
    await tester.pump();
    await tester.pump(moveDuration ~/ 2);

    // Halfway round the long way is about 8:00: left of the middle, and low.
    final halfway = offsetOf(tester, 'ola');
    expect(halfway.dx, lessThan(0));
    expect(halfway.dy, greaterThan(0));
  });

  testWidgets('a move with no cause takes the short way, and never the far '
      'side', (tester) async {
    await show(
      tester,
      reading([
        DialOrbit(orbit: Orbit.inner, beads: [aBead('ola', 0.3)]),
      ]),
    );

    await show(
      tester,
      reading([
        DialOrbit(orbit: Orbit.inner, beads: [aBead('ola', 0)]),
      ]),
    );
    await tester.pump();
    await tester.pump(moveDuration ~/ 2);

    // Back the way it came: still right of the middle, and higher than it was.
    final halfway = offsetOf(tester, 'ola');
    expect(halfway.dx, greaterThan(0));
    expect(halfway.dy, lessThan(0));
  });

  testWidgets('the movement is over within 600 ms', (tester) async {
    await show(
      tester,
      reading([
        DialOrbit(orbit: Orbit.inner, beads: [aBead('ola', 0.3)]),
      ]),
    );
    await show(
      tester,
      reading([
        DialOrbit(orbit: Orbit.inner, beads: [aBead('ola', 0)]),
      ], cause: const MeetingLogged('ola')),
    );
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 600));

    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(offsetOf(tester, 'ola').dx, closeTo(0, 0.5));
    expect(offsetOf(tester, 'ola').dy, lessThan(0));
  });

  testWidgets('a Bead a Meeting sends into the Overflow rests at 12:00 '
      'before it collapses', (tester) async {
    await show(
      tester,
      reading([
        DialOrbit(
          orbit: Orbit.inner,
          beads: [aBead('ola', 0.3), aBead('zos', 1)],
        ),
      ]),
    );

    await show(
      tester,
      reading([
        DialOrbit(
          orbit: Orbit.inner,
          beads: [aBead('zos', 1)],
          badge: const OverflowBadge(count: 2, phase: 0.9),
        ),
      ], cause: const MeetingLogged('ola')),
    );
    await tester.pump();
    await tester.pump(moveDuration);

    // It reached the top, and the Badge has not counted it yet.
    expect(find.byKey(const Key('bead-ola')), findsOneWidget);
    expect(offsetOf(tester, 'ola').dy, lessThan(0));
    expect(find.text('+1'), findsOneWidget);

    await tester.pump(restAtTop);

    expect(find.byKey(const Key('bead-ola')), findsNothing);
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('a Bead that changes Orbit travels before it steps across', (
    tester,
  ) async {
    await show(
      tester,
      reading([
        DialOrbit(
          orbit: Orbit.outer,
          beads: [aBead('ola', 0.5, cadenceDays: 90)],
        ),
      ]),
    );
    final outer = offsetOf(tester, 'ola').distance;

    await show(
      tester,
      reading([
        DialOrbit(orbit: Orbit.inner, beads: [aBead('ola', 0.25)]),
      ]),
    );
    await tester.pump();
    await tester.pump(moveDuration ~/ 2);

    // Halfway through it is still out on the Orbit it started from.
    expect(offsetOf(tester, 'ola').distance, closeTo(outer, 1));

    await tester.pump(moveDuration);

    expect(
      offsetOf(tester, 'ola').distance,
      closeTo(geometry.radiusOf(Orbit.inner), 1),
    );
  });
}
