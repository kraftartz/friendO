import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/profiles/pin.dart';

void main() {
  group('the delay the keypad takes', () {
    test('is none for the first four mistakes', () {
      for (var attempts = 0; attempts <= 4; attempts++) {
        expect(
          pinDelayAfter(attempts),
          Duration.zero,
          reason: '$attempts wrong',
        );
      }
    });

    test('is 30 seconds at the fifth', () {
      expect(pinDelayAfter(5), const Duration(seconds: 30));
    });

    test('doubles from one minute with each further try', () {
      expect(pinDelayAfter(6), const Duration(minutes: 1));
      expect(pinDelayAfter(7), const Duration(minutes: 2));
      expect(pinDelayAfter(8), const Duration(minutes: 4));
      expect(pinDelayAfter(9), const Duration(minutes: 8));
    });

    test('stops at 15 minutes', () {
      expect(pinDelayAfter(10), const Duration(minutes: 15));
      expect(pinDelayAfter(40), const Duration(minutes: 15));
    });
  });

  group('what is left of the delay', () {
    test('is the whole delay at the moment the keypad appears', () {
      expect(pinDelayLeft(5, Duration.zero), const Duration(seconds: 30));
    });

    test('shrinks as the keypad waits', () {
      expect(
        pinDelayLeft(5, const Duration(seconds: 10)),
        const Duration(seconds: 20),
      );
    });

    test('is nothing once the delay has passed', () {
      expect(pinDelayLeft(5, const Duration(minutes: 1)), Duration.zero);
    });

    test('is nothing when no mistake was made', () {
      expect(pinDelayLeft(0, Duration.zero), Duration.zero);
    });
  });
}
