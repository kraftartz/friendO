import 'package:friendo_domain/friendo_domain.dart';
import 'package:test/test.dart';

void main() {
  group('Cadence', () {
    test('rejects zero days', () {
      expect(() => Cadence.ofDays(0), throwsArgumentError);
    });

    test('rejects negative days', () {
      expect(() => Cadence.ofDays(-30), throwsArgumentError);
    });

    test('carries the same length as a Duration', () {
      expect(Cadence.ofDays(30).duration, const Duration(days: 30));
    });

    test('two Cadences of the same length are equal', () {
      expect(Cadence.ofDays(7), Cadence.ofDays(7));
      expect(Cadence.ofDays(7).hashCode, Cadence.ofDays(7).hashCode);
    });

    test('buckets into the three Orbits at the ADR-0008 boundaries', () {
      expect(Cadence.ofDays(1).orbit, Orbit.inner);
      expect(Cadence.ofDays(14).orbit, Orbit.inner);
      expect(Cadence.ofDays(15).orbit, Orbit.middle);
      expect(Cadence.ofDays(60).orbit, Orbit.middle);
      expect(Cadence.ofDays(61).orbit, Orbit.outer);
      expect(Cadence.ofDays(365).orbit, Orbit.outer);
    });
  });

  group('Orbit', () {
    test('holds the range of Cadence days that belongs to it', () {
      expect(Orbit.inner.cadenceDays.holds(1), isTrue);
      expect(Orbit.inner.cadenceDays.holds(14), isTrue);
      expect(Orbit.inner.cadenceDays.holds(15), isFalse);

      expect(Orbit.middle.cadenceDays.holds(15), isTrue);
      expect(Orbit.middle.cadenceDays.holds(60), isTrue);
      expect(Orbit.middle.cadenceDays.holds(61), isFalse);

      expect(Orbit.outer.cadenceDays.holds(61), isTrue);
      expect(Orbit.outer.cadenceDays.holds(3650), isTrue);
    });

    test('the outer range runs on with no end', () {
      expect(Orbit.outer.cadenceDays.last, isNull);
      expect(Orbit.inner.cadenceDays.last, 14);
      expect(Orbit.middle.cadenceDays.last, 60);
    });

    test('the three ranges meet with no gap and no overlap', () {
      expect(Orbit.middle.cadenceDays.first, Orbit.inner.cadenceDays.last! + 1);
      expect(Orbit.outer.cadenceDays.first, Orbit.middle.cadenceDays.last! + 1);
    });

    test('names the Orbit that holds a number of days', () {
      expect(Orbit.of(14), Orbit.inner);
      expect(Orbit.of(15), Orbit.middle);
      expect(Orbit.of(60), Orbit.middle);
      expect(Orbit.of(61), Orbit.outer);
    });
  });
}
