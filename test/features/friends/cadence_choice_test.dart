import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/features/friends/cadence/cadence_choice.dart'
    show CadenceChoice, CadencePreview, cadenceOfText, cadencePresets;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Orbit, Standing, dueDateOf;

/// The Cadence picker's own reading, with no database and no widget.
///
/// The picker shows what a Cadence would give before the User commits, so the
/// thing worth proving is the arithmetic and the single value it holds.
void main() {
  /// Local midnight, in a month no zone shifts its clock in.
  final now = DateTime(2026, 9, 10);
  final today = CivilDate.from(now);

  group('the preview', () {
    test('lands the Due Date one Cadence after the last Meeting', () {
      final lastMet = today.addDays(-3);

      for (final choice in cadencePresets) {
        final preview = choice.previewFrom(lastMet: lastMet, now: now);

        expect(preview.dueAt, lastMet.addDays(choice.cadence.days));
        expect(
          preview.dueAt,
          dueDateOf(lastMet: lastMet, cadence: choice.cadence),
        );
      }
    });

    test('reads the Standing the domain gives at the fixed now', () {
      final lastMet = today.addDays(-8);

      expect(
        CadenceChoice.preset(
          Orbit.inner,
        ).previewFrom(lastMet: lastMet, now: now).standing,
        Standing.overdue,
      );
      expect(
        CadenceChoice.preset(
          Orbit.middle,
        ).previewFrom(lastMet: lastMet, now: now).standing,
        Standing.inOrbit,
      );
      expect(
        CadenceChoice.preset(
          Orbit.outer,
        ).previewFrom(lastMet: lastMet, now: now).standing,
        Standing.freshlyReset,
      );
    });

    test('reads Overdue when the Cadence puts the Due Date in the past', () {
      final preview = CadenceChoice(
        Cadence.ofDays(2),
      ).previewFrom(lastMet: today.addDays(-30), now: now);

      expect(preview.isOverdue, isTrue);
      expect(preview.standing, Standing.overdue);
      expect(preview.daysUntilDue, lessThan(0));
    });

    test('is not Overdue on the Due Date itself', () {
      final preview = CadenceChoice(
        Cadence.ofDays(7),
      ).previewFrom(lastMet: today.addDays(-7), now: now);

      expect(preview.dueAt, today);
      expect(preview.isOverdue, isFalse);
      expect(preview.daysUntilDue, 0);
    });
  });

  group('the presets', () {
    test('fall one in each Orbit', () {
      expect(cadencePresets.map((choice) => choice.preset), Orbit.values);
    });

    test('take their day counts from the Orbit ranges', () {
      for (final choice in cadencePresets) {
        expect(choice.preset.cadenceDays.holds(choice.cadence.days), isTrue);
      }
    });
  });

  group('the one value the picker holds', () {
    test('a typed number lights the preset of its own Orbit', () {
      expect(CadenceChoice(Cadence.ofDays(10)).preset, Orbit.inner);
      expect(CadenceChoice(Cadence.ofDays(45)).preset, Orbit.middle);
      expect(CadenceChoice(Cadence.ofDays(120)).preset, Orbit.outer);
      expect(CadenceChoice(Cadence.ofDays(10)).holds(Orbit.inner), isTrue);
      expect(CadenceChoice(Cadence.ofDays(10)).holds(Orbit.middle), isFalse);
    });

    test('a preset and the same number typed are one state', () {
      final tapped = CadenceChoice.preset(Orbit.middle);
      final typed = CadenceChoice(cadenceOfText('30')!);

      expect(typed, tapped);
      expect(typed.preset, tapped.preset);
      expect(
        typed.previewFrom(lastMet: today, now: now),
        tapped.previewFrom(lastMet: today, now: now),
      );
    });

    test('a preview built twice on one now reads the same', () {
      final preview = CadencePreview.of(
        cadence: Cadence.ofDays(30),
        lastMet: today,
        now: now,
      );

      expect(
        preview,
        CadencePreview.of(
          cadence: Cadence.ofDays(30),
          lastMet: today,
          now: now,
        ),
      );
    });
  });

  group('a typed number', () {
    test('is refused at zero and below', () {
      expect(cadenceOfText('0'), isNull);
      expect(cadenceOfText('-4'), isNull);
    });

    test('is refused when it names no whole number of days', () {
      expect(cadenceOfText(''), isNull);
      expect(cadenceOfText('   '), isNull);
      expect(cadenceOfText('soon'), isNull);
      expect(cadenceOfText('7.5'), isNull);
    });

    test('is taken when it names one', () {
      expect(cadenceOfText(' 21 '), Cadence.ofDays(21));
    });
  });
}
