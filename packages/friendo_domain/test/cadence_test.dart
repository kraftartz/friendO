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
}
