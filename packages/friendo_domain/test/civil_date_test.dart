import 'package:friendo_domain/friendo_domain.dart';
import 'package:test/test.dart';

void main() {
  group('CivilDate', () {
    test('rejects a day that does not exist', () {
      expect(() => CivilDate(2026, 2, 30), throwsArgumentError);
      expect(() => CivilDate(2026, 13, 1), throwsArgumentError);
    });

    test('accepts a leap day in a leap year', () {
      expect(CivilDate(2028, 2, 29).toString(), '2028-02-29');
    });

    test('rejects a leap day in a common year', () {
      expect(() => CivilDate(2026, 2, 29), throwsArgumentError);
    });

    test('round-trips through its stored form', () {
      final date = CivilDate(2026, 10, 14);
      expect(CivilDate.fromEpochDay(date.epochDay), date);
    });

    test('counts 1970-01-01 as day zero', () {
      expect(CivilDate(1970, 1, 1).epochDay, 0);
    });

    test('adds whole days across a month end', () {
      expect(CivilDate(2026, 1, 30).addDays(3), CivilDate(2026, 2, 2));
    });

    test('subtracts to whole days', () {
      expect(CivilDate(2026, 3, 1).daysFrom(CivilDate(2026, 2, 1)), 28);
    });

    test('adding a Cadence in days survives a daylight-saving change', () {
      // Most of the northern hemisphere moves its clocks in late March. Adding
      // whole days must land on the same day of the month either way.
      final before = CivilDate(2026, 3, 20);
      expect(before.addDays(30), CivilDate(2026, 4, 19));
    });

    test('compares by the day it names', () {
      expect(CivilDate(2026, 1, 1) < CivilDate(2026, 1, 2), isTrue);
      expect(CivilDate(2026, 1, 2) > CivilDate(2026, 1, 1), isTrue);
      expect(CivilDate(2026, 1, 1) <= CivilDate(2026, 1, 1), isTrue);
      expect(CivilDate(2026, 1, 1) >= CivilDate(2026, 1, 1), isTrue);
    });

    test('two Civil Dates for one day are equal', () {
      expect(CivilDate(2026, 5, 4), CivilDate.fromEpochDay(20577));
      expect(CivilDate(2026, 5, 4).hashCode, CivilDate(2026, 5, 4).hashCode);
    });

    test('takes the day that a moment falls on', () {
      expect(
        CivilDate.from(DateTime.utc(2026, 10, 14, 23, 59)),
        CivilDate(2026, 10, 14),
      );
    });
  });
}
