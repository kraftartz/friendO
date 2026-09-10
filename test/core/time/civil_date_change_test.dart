import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/time/civil_date_change.dart'
    show CivilDateChange, untilNextMidnight;

import '../../support/running_clock.dart';

/// Long enough for a timer set a tenth of a second ahead to have fired even on
/// a machine running the whole suite at once, and short enough that a second
/// midnight cannot arrive inside it.
const settle = Duration(milliseconds: 500);

/// A tenth of a second before the local Civil Date changes.
DateTime justBeforeMidnight() => DateTime(2026, 9, 10, 23, 59, 59, 900);

void main() {
  group('untilNextMidnight', () {
    test('measures the rest of the day', () {
      expect(
        untilNextMidnight(DateTime(2026, 9, 10, 21, 30)),
        const Duration(hours: 2, minutes: 30),
      );
    });

    test('gives a whole day at midnight, and never nothing', () {
      expect(untilNextMidnight(DateTime(2026, 9, 10)), const Duration(days: 1));
    });

    test('crosses the end of a month and the end of a year', () {
      expect(
        untilNextMidnight(DateTime(2026, 9, 30, 23, 59)),
        const Duration(minutes: 1),
      );
      expect(
        untilNextMidnight(DateTime(2026, 12, 31, 23, 0)),
        const Duration(hours: 1),
      );
    });

    test('lands on the next local midnight, whatever the zone did', () {
      // The next local midnight, and not twenty-four hours on. On a day that
      // shifts the clock the two differ by an hour.
      for (final day in [
        DateTime(2026, 3, 29, 12),
        DateTime(2026, 10, 25, 12),
        DateTime(2026, 4, 5, 12),
      ]) {
        final landed = day.add(untilNextMidnight(day));

        expect(landed.hour, 0);
        expect(landed.minute, 0);
        expect(landed.day, day.add(const Duration(days: 1)).day);
      }
    });
  });

  group('CivilDateChange', () {
    test('announces once when the local Civil Date changes, and does not '
        'tick', () async {
      final change = CivilDateChange(clock: RunningClock(justBeforeMidnight()));
      addTearDown(change.dispose);

      final announcements = <void>[];
      final listening = change.changes.listen(announcements.add);
      addTearDown(listening.cancel);

      await Future<void>.delayed(settle);

      expect(announcements, hasLength(1));
    });

    test('waits for the midnight after the one it announced', () async {
      final change = CivilDateChange(clock: RunningClock(justBeforeMidnight()));
      addTearDown(change.dispose);

      final listening = change.changes.listen((_) {});
      addTearDown(listening.cancel);

      await Future<void>.delayed(settle);

      expect(change.isWaiting, isTrue);
    });

    test('announces to every screen that is listening', () async {
      final change = CivilDateChange(clock: RunningClock(justBeforeMidnight()));
      addTearDown(change.dispose);

      final dial = <void>[];
      final list = <void>[];
      final onDial = change.changes.listen(dial.add);
      final onList = change.changes.listen(list.add);
      addTearDown(onDial.cancel);
      addTearDown(onList.cancel);

      await Future<void>.delayed(settle);

      expect(dial, hasLength(1));
      expect(list, hasLength(1));
    });

    test('stops the timer when the last listener goes', () async {
      final change = CivilDateChange(clock: RunningClock(justBeforeMidnight()));
      addTearDown(change.dispose);

      final announcements = <void>[];
      await change.changes.listen(announcements.add).cancel();

      await Future<void>.delayed(settle);

      expect(change.isWaiting, isFalse);
      expect(announcements, isEmpty);
    });

    test('keeps waiting while one of two screens goes', () async {
      final change = CivilDateChange(clock: RunningClock(justBeforeMidnight()));
      addTearDown(change.dispose);

      final staying = <void>[];
      final onDial = change.changes.listen((_) {});
      final onList = change.changes.listen(staying.add);
      addTearDown(onList.cancel);
      await onDial.cancel();

      await Future<void>.delayed(settle);

      expect(staying, hasLength(1));
    });

    test('waits again when a screen listens once more', () async {
      final change = CivilDateChange(clock: RunningClock(justBeforeMidnight()));
      addTearDown(change.dispose);

      await change.changes.listen((_) {}).cancel();
      expect(change.isWaiting, isFalse);

      final announcements = <void>[];
      final listening = change.changes.listen(announcements.add);
      addTearDown(listening.cancel);

      expect(change.isWaiting, isTrue);
      await Future<void>.delayed(settle);
      expect(announcements, hasLength(1));
    });

    test('stops the timer when it is disposed', () async {
      final change = CivilDateChange(clock: RunningClock(justBeforeMidnight()));

      final announcements = <void>[];
      change.changes.listen(announcements.add);
      await change.dispose();

      await Future<void>.delayed(settle);

      expect(change.isWaiting, isFalse);
      expect(announcements, isEmpty);
    });
  });
}
