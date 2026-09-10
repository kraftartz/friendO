import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/theme.dart' show canvasBase, friendoTheme;
import 'package:friendo/core/friends/dial_friend.dart' show DialFriend;
import 'package:friendo/features/dial/bloc/dial_state.dart'
    show DialBead, DialOrbit, DialState, OverflowBadge;
import 'package:friendo/features/dial/packing/dial_geometry.dart'
    show DialGeometry;
import 'package:friendo/features/dial/packing/dial_reading.dart' show readDial;
import 'package:friendo/features/dial/view/dial_body.dart' show DialBody;
import 'package:friendo/features/dial/view/dial_view.dart' show DialView;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, DialCounts, Orbit, Standing;

void main() {
  const geometry = DialGeometry();

  /// Local midnight, in a month no zone shifts its clock in.
  final today = DateTime(2026, 9, 10);

  DialFriend aFriend(String id, {int cadenceDays = 7, int daysAgo = 3}) =>
      DialFriend(
        id: id,
        name: id,
        cadence: Cadence.ofDays(cadenceDays),
        lastMet: CivilDate.from(today).addDays(-daysAgo),
      );

  DialBead aBead(
    String id,
    double phase, {
    Standing standing = Standing.inOrbit,
  }) => DialBead(friend: aFriend(id), phase: phase, standing: standing);

  DialState reading({
    required List<DialOrbit> orbits,
    String? emphasisedId,
    DialCounts counts = const DialCounts(
      freshlyReset: 0,
      inOrbit: 0,
      nearing: 0,
      overdue: 0,
    ),
  }) => DialState(
    orbits: [
      for (final orbit in Orbit.values)
        orbits.firstWhere(
          (held) => held.orbit == orbit,
          orElse: () => DialOrbit(orbit: orbit, beads: const []),
        ),
    ],
    counts: counts,
    emphasisedId: emphasisedId,
  );

  Future<void> show(
    WidgetTester tester,
    DialState held, {
    void Function(String friendId)? onLogMeeting,
  }) => tester.pumpWidget(
    MaterialApp(
      theme: friendoTheme(),
      home: Scaffold(
        body: DialBody(reading: held, onLogMeeting: onLogMeeting ?? (_) {}),
      ),
    ),
  );

  testWidgets('a tap on a Bead names that Friend', (tester) async {
    await show(
      tester,
      reading(
        orbits: [
          DialOrbit(
            orbit: Orbit.inner,
            beads: [aBead('Ola', 1), aBead('Zosia', 0.4)],
          ),
        ],
        emphasisedId: 'Ola',
      ),
    );
    expect(find.text('Zosia'), findsNothing);

    await tester.tap(find.byKey(const Key('bead-Zosia')));
    await tester.pumpAndSettle();

    expect(find.text('Zosia'), findsOneWidget);
    expect(find.text('Log a Meeting with Zosia'), findsOneWidget);
  });

  testWidgets('the sheet logs a Meeting for the Friend it named', (
    tester,
  ) async {
    final written = <String>[];
    await show(
      tester,
      reading(
        orbits: [
          DialOrbit(
            orbit: Orbit.inner,
            beads: [aBead('Ola', 1), aBead('Zosia', 0.4)],
          ),
        ],
        emphasisedId: 'Ola',
      ),
      onLogMeeting: written.add,
    );

    await tester.tap(find.byKey(const Key('bead-Zosia')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('dial-sheet-log-meeting')));
    await tester.pumpAndSettle();

    expect(written, ['Zosia']);
  });

  testWidgets('the button carries the emphasised Friend, and logs for '
      'them', (tester) async {
    final written = <String>[];
    await show(
      tester,
      reading(
        orbits: [
          DialOrbit(
            orbit: Orbit.inner,
            beads: [aBead('Ola', 1), aBead('Zosia', 0.4)],
          ),
        ],
        emphasisedId: 'Ola',
      ),
      onLogMeeting: written.add,
    );

    expect(find.text('Log a Meeting with Ola'), findsOneWidget);
    await tester.tap(find.byKey(const Key('dial-log-meeting')));

    expect(written, ['Ola']);
  });

  testWidgets('the locked Dial draws no name, no initial and no count', (
    tester,
  ) async {
    await show(tester, const DialState.locked());

    expect(find.byType(Text), findsNothing);
    expect(find.byType(DialView), findsOneWidget);
  });

  testWidgets('the empty Dial invites the User to add a Friend', (
    tester,
  ) async {
    await show(tester, reading(orbits: const []));

    expect(find.text('Add your first Friend'), findsOneWidget);
    expect(find.byKey(const Key('dial-log-meeting')), findsNothing);
  });

  testWidgets('the counts beside the Dial are the three that are not '
      'drawn', (tester) async {
    await show(
      tester,
      reading(
        orbits: [
          DialOrbit(orbit: Orbit.inner, beads: [aBead('Ola', 1)]),
        ],
        emphasisedId: 'Ola',
        counts: const DialCounts(
          freshlyReset: 2,
          inOrbit: 4,
          nearing: 1,
          overdue: 3,
        ),
      ),
    );

    expect(find.text('1 Nearing'), findsOneWidget);
    expect(find.text('4 In Orbit'), findsOneWidget);
    expect(find.text('2 Freshly Reset'), findsOneWidget);
    expect(find.textContaining('Overdue'), findsNothing);
  });

  testWidgets('a tap on the Overflow Badge asks for that Orbit', (
    tester,
  ) async {
    final asked = <Orbit>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: friendoTheme(),
        home: Scaffold(
          body: DialBody(
            reading: reading(
              orbits: [
                DialOrbit(
                  orbit: Orbit.inner,
                  beads: [aBead('Ola', 1)],
                  badge: const OverflowBadge(count: 4, phase: 0.8),
                ),
              ],
              emphasisedId: 'Ola',
            ),
            onLogMeeting: (_) {},
            onShowOrbit: asked.add,
          ),
        ),
      ),
    );

    expect(find.text('+4'), findsOneWidget);
    await tester.tap(find.byKey(const Key('overflow-inner')));

    expect(asked, [Orbit.inner]);
  });

  testWidgets('the whole instrument, at a fixed roster and a fixed now', (
    tester,
  ) async {
    final roster = [
      for (var index = 0; index < 13; index++)
        aFriend('inner-$index', cadenceDays: 7, daysAgo: 30 - index),
      for (var index = 0; index < 3; index++)
        aFriend('middle-$index', cadenceDays: 30, daysAgo: 26 - index * 8),
      for (var index = 0; index < 3; index++)
        aFriend('outer-$index', cadenceDays: 90, daysAgo: 70 - index * 25),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: friendoTheme(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 340,
              height: 340,
              child: RepaintBoundary(
                child: ColoredBox(
                  color: canvasBase,
                  child: DialView(
                    reading: readDial(
                      friends: roster,
                      now: today,
                      geometry: geometry,
                      cause: null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(RepaintBoundary).last,
      matchesGoldenFile('goldens/dial.png'),
    );
  });
}
