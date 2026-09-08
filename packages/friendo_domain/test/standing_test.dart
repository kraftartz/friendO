import 'package:friendo_domain/friendo_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Standing.of', () {
    test('is Freshly Reset below a quarter of the Cadence', () {
      expect(
        Standing.of(phase: Phase(0), isOverdue: false),
        Standing.freshlyReset,
      );
      expect(
        Standing.of(phase: Phase(0.249), isOverdue: false),
        Standing.freshlyReset,
      );
    });

    test('is In Orbit from a quarter up to three quarters', () {
      expect(
        Standing.of(phase: Phase(0.25), isOverdue: false),
        Standing.inOrbit,
      );
      expect(
        Standing.of(phase: Phase(0.749), isOverdue: false),
        Standing.inOrbit,
      );
    });

    test('is Nearing from three quarters up to the end of the Due Date', () {
      expect(
        Standing.of(phase: Phase(0.75), isOverdue: false),
        Standing.nearing,
      );
      expect(Standing.of(phase: Phase(1), isOverdue: false), Standing.nearing);
      expect(
        Standing.of(phase: Phase(1.03), isOverdue: false),
        Standing.nearing,
      );
    });

    test(
      'is Overdue whatever the Phase says, once the Due Date has passed',
      () {
        expect(
          Standing.of(phase: Phase(1.5), isOverdue: true),
          Standing.overdue,
        );
      },
    );
  });

  group('DialCounts', () {
    test('counts each Standing', () {
      final counts = DialCounts.from([
        Standing.freshlyReset,
        Standing.freshlyReset,
        Standing.inOrbit,
        Standing.nearing,
        Standing.overdue,
        Standing.overdue,
        Standing.overdue,
      ]);
      expect(counts.freshlyReset, 2);
      expect(counts.inOrbit, 1);
      expect(counts.nearing, 1);
      expect(counts.overdue, 3);
    });

    test('leaves nobody out', () {
      final standings = List.generate(
        20,
        (i) => Standing.values[i % Standing.values.length],
      );
      expect(DialCounts.from(standings).total, 20);
    });

    test('counts nothing for no Friends', () {
      expect(
        DialCounts.from(const []),
        const DialCounts(freshlyReset: 0, inOrbit: 0, nearing: 0, overdue: 0),
      );
    });
  });
}
