import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/features/dial/packing/bead_packer.dart'
    show BeadPacking, PlacedBead, packBeads;
import 'package:friendo/features/dial/packing/dial_geometry.dart'
    show DialGeometry;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Orbit, Placing, PriorityOrder;

/// Local midnight, in a month no zone shifts its clock in, so a whole number
/// of days back is a whole number of laps.
final now = DateTime(2026, 9, 10);

const geometry = DialGeometry();

Placing placingOf(
  String id, {
  required int cadenceDays,
  required int daysAgo,
}) => Placing(
  friendId: id,
  lastMet: CivilDate.from(now).addDays(-daysAgo),
  cadence: Cadence.ofDays(cadenceDays),
  now: now,
);

BeadPacking packing(List<Placing> placings) =>
    packBeads(PriorityOrder(placings), geometry: geometry);

List<String> idsOn(BeadPacking packed, Orbit orbit) => [
  for (final bead in packed.on(orbit).beads) bead.placing.friendId,
];

void main() {
  group('the packer', () {
    test('puts a Friend on the Orbit their Cadence names', () {
      final packed = packing([
        placingOf('weekly', cadenceDays: 7, daysAgo: 1),
        placingOf('monthly', cadenceDays: 30, daysAgo: 1),
        placingOf('seasonal', cadenceDays: 90, daysAgo: 1),
      ]);

      expect(idsOn(packed, Orbit.inner), ['weekly']);
      expect(idsOn(packed, Orbit.middle), ['monthly']);
      expect(idsOn(packed, Orbit.outer), ['seasonal']);
    });

    test('rests one Overdue Friend at Phase 1', () {
      final packed = packing([placingOf('late', cadenceDays: 7, daysAgo: 30)]);

      expect(packed.on(Orbit.inner).beads.single.phase, 1.0);
    });

    test('rests one on-track Friend at their own Phase', () {
      final packed = packing([
        placingOf('halfway', cadenceDays: 10, daysAgo: 5),
      ]);

      expect(packed.on(Orbit.inner).beads.single.phase, closeTo(0.5, 1e-9));
    });

    test('rests two Overdue Friends one minGap apart, in Priority Order', () {
      final packed = packing([
        placingOf('later', cadenceDays: 7, daysAgo: 20),
        placingOf('latest', cadenceDays: 7, daysAgo: 40),
      ]);

      final beads = packed.on(Orbit.inner).beads;
      expect(beads.map((bead) => bead.placing.friendId), ['latest', 'later']);
      expect(beads.first.phase, 1.0);
      expect(
        beads.first.phase - beads.last.phase,
        closeTo(geometry.minGapOf(Orbit.inner), 1e-9),
      );
    });

    test('pushes an on-track Friend to the back of the Beads Queue', () {
      final packed = packing([
        placingOf('late', cadenceDays: 20, daysAgo: 40),
        placingOf('later', cadenceDays: 20, daysAgo: 30),
        placingOf('nearly', cadenceDays: 20, daysAgo: 19),
      ]);

      final gap = geometry.minGapOf(Orbit.middle);
      final beads = packed.on(Orbit.middle).beads;
      expect(beads.map((bead) => bead.placing.friendId), [
        'late',
        'later',
        'nearly',
      ]);
      expect(beads.last.phase, closeTo(1 - 2 * gap, 1e-9));
      expect(beads.last.phase, lessThan(beads.last.placing.phase.value));
    });

    test('rests a Friend due today at Phase 1, and does not call them '
        'Overdue', () {
      final packed = packing([
        placingOf('due-today', cadenceDays: 7, daysAgo: 7),
      ]);

      final bead = packed.on(Orbit.inner).beads.single;
      expect(bead.phase, 1.0);
      expect(bead.placing.overdue, isFalse);
    });

    test('places 12 on the inner Orbit and overflows the thirteenth', () {
      final packed = packing([
        for (var index = 0; index < 13; index++)
          placingOf('friend-$index', cadenceDays: 7, daysAgo: 30 - index),
      ]);

      expect(packed.on(Orbit.inner).beads, hasLength(12));
      expect(packed.on(Orbit.inner).overflow, hasLength(1));
    });

    test('places 20 on the middle Orbit and 27 on the outer, and overflows '
        'one of each', () {
      final middle = packing([
        for (var index = 0; index < 21; index++)
          placingOf('friend-$index', cadenceDays: 30, daysAgo: 60 - index),
      ]);
      expect(middle.on(Orbit.middle).beads, hasLength(20));
      expect(middle.on(Orbit.middle).overflow, hasLength(1));

      final outer = packing([
        for (var index = 0; index < 28; index++)
          placingOf('friend-$index', cadenceDays: 90, daysAgo: 99 - index),
      ]);
      expect(outer.on(Orbit.outer).beads, hasLength(27));
      expect(outer.on(Orbit.outer).overflow, hasLength(1));
    });

    test('keeps a full minGap between the last of twelve and the first', () {
      final packed = packing([
        for (var index = 0; index < 12; index++)
          placingOf('friend-$index', cadenceDays: 7, daysAgo: 30 - index),
      ]);

      final beads = packed.on(Orbit.inner).beads;
      final gap = geometry.minGapOf(Orbit.inner);
      expect(beads, hasLength(12));
      expect(beads.first.phase, 1.0);
      expect(
        beads.last.phase - beads.first.phase + 1,
        greaterThanOrEqualTo(gap - 1e-9),
      );
    });

    test('refuses the thirteenth because the lap has closed, while the '
        'cursor is still above zero', () {
      final packed = packing([
        for (var index = 0; index < 13; index++)
          placingOf('friend-$index', cadenceDays: 7, daysAgo: 30 - index),
      ]);

      final beads = packed.on(Orbit.inner).beads;
      final gap = geometry.minGapOf(Orbit.inner);
      final cursor = beads.last.phase - gap;

      expect(cursor, greaterThan(0));
      expect(cursor, lessThan(gap));
      expect(packed.on(Orbit.inner).overflow.single.friendId, 'friend-12');
    });

    test('lets the Beads Queue wrap past 12:00, and takes the angle modulo '
        'one lap', () {
      final packed = packing([
        placingOf('lead', cadenceDays: 100, daysAgo: 2),
        placingOf('behind', cadenceDays: 100, daysAgo: 1),
      ]);

      final beads = packed.on(Orbit.outer).beads;
      final gap = geometry.minGapOf(Orbit.outer);
      expect(beads.first.phase, closeTo(0.02, 1e-9));
      expect(beads.last.phase, closeTo(0.02 - gap, 1e-9));
      expect(beads.last.phase, lessThan(0));
      expect(beads.last.lapFraction, closeTo(1.02 - gap, 1e-9));
      expect(beads.first.lapFraction, closeTo(0.02, 1e-9));
    });

    test('draws a Bead resting at Phase 1 at the top of the lap', () {
      final packed = packing([placingOf('late', cadenceDays: 7, daysAgo: 30)]);

      expect(packed.on(Orbit.inner).beads.single.lapFraction, 0.0);
    });

    test('gives an Orbit with no members no Beads and no Overflow', () {
      final packed = packing([placingOf('weekly', cadenceDays: 7, daysAgo: 1)]);

      expect(packed.on(Orbit.middle).beads, isEmpty);
      expect(packed.on(Orbit.middle).overflow, isEmpty);
      expect(packed.on(Orbit.outer).beads, isEmpty);
      expect(packed.on(Orbit.outer).overflow, isEmpty);
    });

    test('rests a lone Friend at the top of the outer Orbit while the inner '
        'Orbit is full', () {
      final packed = packing([
        for (var index = 0; index < 13; index++)
          placingOf('friend-$index', cadenceDays: 7, daysAgo: 30 - index),
        placingOf('alone', cadenceDays: 90, daysAgo: 5),
      ]);

      expect(packed.on(Orbit.inner).overflow, hasLength(1));
      final alone = packed.on(Orbit.outer).beads.single;
      expect(alone.placing.friendId, 'alone');
      expect(alone.phase, closeTo(5 / 90, 1e-9));
    });

    test('keeps the Priority Order inside every Orbit', () {
      final placings = [
        for (var index = 0; index < 13; index++)
          placingOf('inner-$index', cadenceDays: 7, daysAgo: 30 - index),
        for (var index = 0; index < 4; index++)
          placingOf('middle-$index', cadenceDays: 30, daysAgo: 20 - index),
        for (var index = 0; index < 4; index++)
          placingOf('outer-$index', cadenceDays: 90, daysAgo: 40 - index),
      ];
      final order = PriorityOrder(placings);
      final packed = packBeads(order, geometry: geometry);

      for (final orbit in Orbit.values) {
        final ranked = [
          for (final placing in order.all)
            if (placing.cadence.orbit == orbit) placing.friendId,
        ];
        final drawn = [
          ...idsOn(packed, orbit),
          for (final placing in packed.on(orbit).overflow) placing.friendId,
        ];
        expect(drawn, ranked);
      }
    });
  });

  group('the geometry', () {
    test('spaces the Beads by their own width over the circumference', () {
      for (final orbit in Orbit.values) {
        expect(
          geometry.minGapOf(orbit),
          closeTo(32 / geometry.circumferenceOf(orbit), 1e-12),
        );
      }
    });

    test('measures the three Orbits in dial-minutes as the record does', () {
      expect((geometry.minGapOf(Orbit.inner) * 720).round(), 59);
      expect((geometry.minGapOf(Orbit.middle) * 720).round(), 36);
      expect((geometry.minGapOf(Orbit.outer) * 720).round(), 26);
    });
  });

  group('a placed Bead', () {
    test('two Beads placed the same way are equal', () {
      final placing = placingOf('one', cadenceDays: 7, daysAgo: 1);

      expect(
        PlacedBead(placing: placing, phase: 0.5),
        PlacedBead(placing: placing, phase: 0.5),
      );
    });
  });
}
