import 'package:friendo_domain/friendo_domain.dart';
import 'package:test/test.dart';

void main() {
  final lastMet = DateTime.utc(2026, 1, 1);
  const cadence = Duration(days: 30);

  group('phaseOf', () {
    test('is zero at the last Meeting', () {
      expect(phaseOf(lastMet: lastMet, cadence: cadence, now: lastMet), 0.0);
    });

    test('is exactly one at the Due Date', () {
      expect(
        phaseOf(lastMet: lastMet, cadence: cadence, now: lastMet.add(cadence)),
        1.0,
      );
    });

    test('is a half at the midpoint', () {
      expect(
        phaseOf(
          lastMet: lastMet,
          cadence: cadence,
          now: lastMet.add(const Duration(days: 15)),
        ),
        0.5,
      );
    });

    test('passes one once the Friend is Overdue', () {
      expect(
        phaseOf(
          lastMet: lastMet,
          cadence: cadence,
          now: lastMet.add(const Duration(days: 45)),
        ),
        greaterThan(1.0),
      );
    });

    test('is negative before the last Meeting', () {
      expect(
        phaseOf(
          lastMet: lastMet,
          cadence: cadence,
          now: lastMet.subtract(const Duration(days: 3)),
        ),
        lessThan(0.0),
      );
    });

    test('rejects a cadence of zero', () {
      expect(
        () => phaseOf(lastMet: lastMet, cadence: Duration.zero, now: lastMet),
        throwsArgumentError,
      );
    });

    test('rejects a negative cadence', () {
      expect(
        () => phaseOf(
          lastMet: lastMet,
          cadence: const Duration(days: -30),
          now: lastMet,
        ),
        throwsArgumentError,
      );
    });
  });
}
