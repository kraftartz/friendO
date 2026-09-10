import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/security/auto_lock.dart';
import 'package:friendo/core/time/clock.dart';

void main() {
  final wentAway = DateTime.utc(2026, 9, 10, 12);

  group('the decision to lock', () {
    test('leaves a short absence alone', () {
      expect(
        shouldLock(
          wentAway: wentAway,
          cameBack: wentAway.add(const Duration(seconds: 59)),
        ),
        isFalse,
      );
    });

    test('locks a long absence', () {
      expect(
        shouldLock(
          wentAway: wentAway,
          cameBack: wentAway.add(const Duration(seconds: 61)),
        ),
        isTrue,
      );
    });

    test('leaves an absence of exactly the timeout alone', () {
      expect(
        shouldLock(
          wentAway: wentAway,
          cameBack: wentAway.add(defaultLockTimeout),
        ),
        isFalse,
      );
    });

    test('locks a phone that came back before it went away', () {
      expect(
        shouldLock(
          wentAway: wentAway,
          cameBack: wentAway.subtract(const Duration(days: 1)),
        ),
        isTrue,
      );
    });

    test('locks a week of sleep', () {
      expect(
        shouldLock(
          wentAway: wentAway,
          cameBack: wentAway.add(const Duration(days: 7)),
        ),
        isTrue,
      );
    });

    test('takes the timeout as an argument', () {
      expect(
        shouldLock(
          wentAway: wentAway,
          cameBack: wentAway.add(const Duration(minutes: 4)),
          timeout: const Duration(minutes: 5),
        ),
        isFalse,
      );
    });

    test('defaults to the 60 seconds ADR-0011 sets', () {
      expect(defaultLockTimeout, const Duration(seconds: 60));
    });
  });

  group('the lifecycle it watches', () {
    late List<int> locks;
    late FixedClock clock;
    late AutoLock autoLock;

    setUp(() {
      locks = [];
      clock = FixedClock(wentAway);
      autoLock = AutoLock(lock: () async => locks.add(1), clock: clock);
    });

    void goAway(Duration away) {
      autoLock.didChangeAppLifecycleState(AppLifecycleState.paused);
      clock.advance(away);
      autoLock.didChangeAppLifecycleState(AppLifecycleState.resumed);
    }

    test('locks nothing while the app stays in front', () {
      autoLock.didChangeAppLifecycleState(AppLifecycleState.inactive);
      autoLock.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(locks, isEmpty);
    });

    test('leaves a quick answer to a message alone', () {
      goAway(const Duration(seconds: 5));

      expect(locks, isEmpty);
    });

    test('locks after a long time away', () {
      goAway(const Duration(minutes: 5));

      expect(locks, hasLength(1));
    });

    test('locks when the process is torn down', () {
      autoLock.didChangeAppLifecycleState(AppLifecycleState.detached);

      expect(locks, hasLength(1));
    });

    test('locks a return it never saw leave', () {
      autoLock.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(locks, isEmpty);
    });
  });
}

/// A Clock that moves only when a test moves it.
class FixedClock extends Clock {
  FixedClock(this._now);

  DateTime _now;

  void advance(Duration step) => _now = _now.add(step);

  @override
  DateTime now() => _now;
}
