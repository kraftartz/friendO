import 'package:friendo_domain/friendo_domain.dart';
import 'package:test/test.dart';

void main() {
  final lastMet = CivilDate(2026, 1, 1);
  final cadence = Cadence.ofDays(30);

  // Every `now` below is local, because a Phase is measured from local midnight
  // of the last Meeting. January holds no daylight-saving change in the zones
  // this runs in, so the arithmetic stays exact.

  group('Phase', () {
    test('rejects a negative value', () {
      expect(() => Phase(-0.1), throwsArgumentError);
    });

    test('rejects a value that is not a number', () {
      expect(() => Phase(double.nan), throwsArgumentError);
    });

    test('has arrived at one and beyond, and not before', () {
      expect(Phase(0.999).hasArrived, isFalse);
      expect(Phase(1).hasArrived, isTrue);
      expect(Phase(2).hasArrived, isTrue);
    });
  });

  group('phaseOf', () {
    test('is zero at midnight of the last Meeting', () {
      expect(
        phaseOf(lastMet: lastMet, cadence: cadence, now: DateTime(2026, 1, 1)),
        Phase.fresh,
      );
    });

    test('is exactly one at the start of the Due Date', () {
      expect(
        phaseOf(
          lastMet: lastMet,
          cadence: cadence,
          now: DateTime(2026, 1, 31),
        ).value,
        1.0,
      );
    });

    test('is a half at the midpoint', () {
      expect(
        phaseOf(
          lastMet: lastMet,
          cadence: cadence,
          now: DateTime(2026, 1, 16),
        ).value,
        0.5,
      );
    });

    test('creeps through the day rather than jumping once a day', () {
      final morning = phaseOf(
        lastMet: lastMet,
        cadence: cadence,
        now: DateTime(2026, 1, 16, 6),
      );
      final evening = phaseOf(
        lastMet: lastMet,
        cadence: cadence,
        now: DateTime(2026, 1, 16, 18),
      );
      expect(evening.value, greaterThan(morning.value));
    });

    test('passes one once the Bead has arrived', () {
      expect(
        phaseOf(
          lastMet: lastMet,
          cadence: cadence,
          now: DateTime(2026, 2, 15),
        ).value,
        greaterThan(1.0),
      );
    });

    test('is zero before the last Meeting, never negative', () {
      // Reachable only when the phone changes zone or its clock moves. A
      // Meeting cannot be in the future, so zero is the truthful reading.
      expect(
        phaseOf(
          lastMet: lastMet,
          cadence: cadence,
          now: DateTime(2025, 12, 29),
        ),
        Phase.fresh,
      );
    });
  });

  group('dueDateOf', () {
    test('adds the Cadence in whole calendar days', () {
      expect(
        dueDateOf(lastMet: CivilDate(2026, 1, 1), cadence: cadence),
        CivilDate(2026, 1, 31),
      );
    });

    test('lands on the same day of the month across a clock change', () {
      expect(
        dueDateOf(lastMet: CivilDate(2026, 3, 20), cadence: cadence),
        CivilDate(2026, 4, 19),
      );
    });
  });

  group('isOverdue', () {
    final dueAt = CivilDate(2026, 1, 31);

    test('is false before the Due Date', () {
      expect(isOverdue(today: CivilDate(2026, 1, 30), dueAt: dueAt), isFalse);
    });

    test('is false on the Due Date itself', () {
      expect(isOverdue(today: dueAt, dueAt: dueAt), isFalse);
    });

    test('is true the day after the Due Date', () {
      expect(isOverdue(today: CivilDate(2026, 2, 1), dueAt: dueAt), isTrue);
    });
  });
}
