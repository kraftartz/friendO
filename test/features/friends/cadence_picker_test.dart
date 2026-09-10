import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/features/friends/cadence/cadence_choice.dart'
    show CadenceChoice;
import 'package:friendo/features/friends/view/cadence_picker.dart'
    show CadencePicker, cadenceDaysFieldKey, cadencePreviewKey;
import 'package:friendo/features/friends/view/words.dart' show presetLabel;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Orbit;
import 'package:friendo_ui/friendo_ui.dart' show Pill;

/// The picker as it is drawn: the presets, the number, and the one line that
/// says what the choice gives.
void main() {
  final now = DateTime(2026, 9, 10);
  final today = CivilDate.from(now);

  Future<void> draw(
    WidgetTester tester, {
    required CadenceChoice choice,
    required CivilDate lastMet,
    ValueChanged<CadenceChoice>? onChosen,
  }) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CadencePicker(
          choice: choice,
          lastMet: lastMet,
          now: now,
          onChosen: onChosen ?? (_) {},
          onTyped: (_) {},
        ),
      ),
    ),
  );

  testWidgets('says what the chosen Cadence gives', (tester) async {
    await draw(
      tester,
      choice: CadenceChoice(Cadence.ofDays(7)),
      lastMet: today.addDays(-3),
    );

    expect(
      tester.widget<Text>(find.byKey(cadencePreviewKey)).data,
      'Due in 4 days · In Orbit',
    );
  });

  testWidgets('reads Overdue without asking the User to confirm', (
    tester,
  ) async {
    await draw(
      tester,
      choice: CadenceChoice(Cadence.ofDays(2)),
      lastMet: today.addDays(-30),
    );

    expect(
      tester.widget<Text>(find.byKey(cadencePreviewKey)).data,
      'Due 28 days ago · Overdue',
    );
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('lights the preset the Cadence falls in', (tester) async {
    await draw(
      tester,
      choice: CadenceChoice(Cadence.ofDays(45)),
      lastMet: today,
    );

    Pill pillFor(Orbit orbit) =>
        tester.widget<Pill>(find.widgetWithText(Pill, presetLabel(orbit)));

    expect(pillFor(Orbit.middle).isChosen, isTrue);
    expect(pillFor(Orbit.inner).isChosen, isFalse);
    expect(pillFor(Orbit.outer).isChosen, isFalse);
  });

  testWidgets('hands back the preset a tap chooses', (tester) async {
    CadenceChoice? chosen;
    await draw(
      tester,
      choice: CadenceChoice(Cadence.ofDays(7)),
      lastMet: today,
      onChosen: (choice) => chosen = choice,
    );

    await tester.tap(find.widgetWithText(Pill, presetLabel(Orbit.outer)));

    expect(chosen, CadenceChoice.preset(Orbit.outer));
  });

  testWidgets('offers a field for a Cadence the presets do not hold', (
    tester,
  ) async {
    await draw(
      tester,
      choice: CadenceChoice(Cadence.ofDays(10)),
      lastMet: today,
    );

    expect(find.byKey(cadenceDaysFieldKey), findsOneWidget);
  });
}
