import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/profiles/rest.dart';

void main() {
  group('the rest the keypad takes', () {
    test('is none for the first four mistakes', () {
      for (var attempts = 0; attempts <= 4; attempts++) {
        expect(restAfter(attempts), Duration.zero, reason: '$attempts wrong');
      }
    });

    test('is 30 seconds at the fifth', () {
      expect(restAfter(5), const Duration(seconds: 30));
    });

    test('doubles from one minute with each further try', () {
      expect(restAfter(6), const Duration(minutes: 1));
      expect(restAfter(7), const Duration(minutes: 2));
      expect(restAfter(8), const Duration(minutes: 4));
      expect(restAfter(9), const Duration(minutes: 8));
    });

    test('stops at 15 minutes', () {
      expect(restAfter(10), const Duration(minutes: 15));
      expect(restAfter(40), const Duration(minutes: 15));
    });
  });

  group('what is left of the rest', () {
    test('is the whole rest at the moment the keypad appears', () {
      expect(restLeft(5, Duration.zero), const Duration(seconds: 30));
    });

    test('shrinks as the keypad waits', () {
      expect(
        restLeft(5, const Duration(seconds: 10)),
        const Duration(seconds: 20),
      );
    });

    test('is nothing once the rest has passed', () {
      expect(restLeft(5, const Duration(minutes: 1)), Duration.zero);
    });

    test('is nothing when no mistake was made', () {
      expect(restLeft(0, Duration.zero), Duration.zero);
    });
  });
}
