import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/time/civil_date_change.dart'
    show CivilDateChange, untilNextMidnight;

import '../../support/fixed_clock.dart';

/// How long to wait when the thing under test is an absence.
///
/// There is no answer to poll for, so a length of time is the only way to ask.
/// It is short because a late timer cannot make an absence look present, and
/// short enough that a second midnight cannot arrive inside it.
const settle = Duration(milliseconds: 500);

/// Wait for [answer].
///
/// A timer fires when it fires. A machine running the whole suite at once can
/// leave a timer set a tenth of a second ahead waiting for seconds, so a test
/// waits for the answer rather than for a length of time it can miss. The
/// budget is long because it costs nothing on a machine that is not loaded:
/// the wait ends on the answer and not on the clock.
Future<void> until(bool Function() answer) async {
  for (var tries = 0; tries < 1000 && !answer(); tries++) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await pumpEventQueue();
  }
}

/// A tenth of a second before the local Civil Date changes.
///
/// The wait the timer is set for is that tenth of a second, and the Civil Date
/// moves only when a test moves the Clock. A Clock that ran with the machine
/// would decide both, and a loaded machine would then answer a question the
/// test meant to answer itself.
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
    /// A change over a Clock the test moves, and the Clock beside it.
    (CivilDateChange, FixedClock) aChange() {
      final clock = FixedClock(justBeforeMidnight());

      return (CivilDateChange(clock: clock), clock);
    }

    test('announces once when the local Civil Date changes, and does not '
        'tick', () async {
      final (change, clock) = aChange();
      addTearDown(change.dispose);

      final announcements = <void>[];
      final listening = change.changes.listen(announcements.add);
      addTearDown(listening.cancel);
      clock.advance(const Duration(milliseconds: 200));

      await until(() => announcements.isNotEmpty);
      // Long enough after the first announcement for a second to have shown
      // up, had the timer been a tick rather than a wait for one midnight.
      await Future<void>.delayed(settle);

      expect(announcements, hasLength(1));
    });

    test('waits for the midnight after the one it announced', () async {
      final (change, clock) = aChange();
      addTearDown(change.dispose);

      final announcements = <void>[];
      final listening = change.changes.listen(announcements.add);
      addTearDown(listening.cancel);
      clock.advance(const Duration(milliseconds: 200));

      await until(() => announcements.isNotEmpty);

      expect(change.isWaiting, isTrue);
    });

    test('announces to every screen that is listening', () async {
      final (change, clock) = aChange();
      addTearDown(change.dispose);

      final dial = <void>[];
      final list = <void>[];
      final onDial = change.changes.listen(dial.add);
      final onList = change.changes.listen(list.add);
      addTearDown(onDial.cancel);
      addTearDown(onList.cancel);
      clock.advance(const Duration(milliseconds: 200));

      await until(() => dial.isNotEmpty && list.isNotEmpty);

      expect(dial, hasLength(1));
      expect(list, hasLength(1));
    });

    test('stops the timer when the last listener goes', () async {
      final (change, clock) = aChange();
      addTearDown(change.dispose);

      final announcements = <void>[];
      await change.changes.listen(announcements.add).cancel();
      clock.advance(const Duration(milliseconds: 200));

      await Future<void>.delayed(settle);

      expect(change.isWaiting, isFalse);
      expect(announcements, isEmpty);
    });

    test('keeps waiting while one of two screens goes', () async {
      final (change, clock) = aChange();
      addTearDown(change.dispose);

      final staying = <void>[];
      final onDial = change.changes.listen((_) {});
      final onList = change.changes.listen(staying.add);
      addTearDown(onList.cancel);
      await onDial.cancel();
      clock.advance(const Duration(milliseconds: 200));

      await until(() => staying.isNotEmpty);

      expect(staying, hasLength(1));
    });

    test('waits again when a screen listens once more', () async {
      final (change, clock) = aChange();
      addTearDown(change.dispose);

      await change.changes.listen((_) {}).cancel();
      expect(change.isWaiting, isFalse);

      final announcements = <void>[];
      final listening = change.changes.listen(announcements.add);
      addTearDown(listening.cancel);
      clock.advance(const Duration(milliseconds: 200));

      expect(change.isWaiting, isTrue);
      await until(() => announcements.isNotEmpty);
      expect(announcements, hasLength(1));
    });

    test('stops the timer when it is disposed', () async {
      final (change, clock) = aChange();

      final announcements = <void>[];
      change.changes.listen(announcements.add);
      await change.dispose();
      clock.advance(const Duration(milliseconds: 200));

      await Future<void>.delayed(settle);

      expect(change.isWaiting, isFalse);
      expect(announcements, isEmpty);
    });
  });
}
