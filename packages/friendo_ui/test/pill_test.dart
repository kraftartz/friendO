import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo_ui/friendo_ui.dart' show Pill, Soft;

void main() {
  Widget wrapped(Widget child) => MaterialApp(
    theme: ThemeData(extensions: const [Soft.dark()]),
    home: Scaffold(body: Center(child: child)),
  );

  BoxDecoration decorationOf(WidgetTester tester) =>
      tester
              .widget<DecoratedBox>(
                find.descendant(
                  of: find.byType(Pill),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .decoration
          as BoxDecoration;

  testWidgets('shows the label it is given', (tester) async {
    await tester.pumpWidget(wrapped(const Pill(label: 'Inner')));

    expect(find.text('Inner'), findsOneWidget);
  });

  testWidgets('draws a chosen Pill apart from an unchosen one', (tester) async {
    await tester.pumpWidget(wrapped(const Pill(label: 'Inner')));
    final unchosen = decorationOf(tester).color;

    await tester.pumpWidget(
      wrapped(const Pill(label: 'Inner', isChosen: true)),
    );

    expect(decorationOf(tester).color, isNot(unchosen));
  });

  testWidgets('reports a tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(wrapped(Pill(label: 'Inner', onTap: () => taps++)));

    await tester.tap(find.byType(Pill));

    expect(taps, 1);
  });

  testWidgets('reports no tap when it is given no handler', (tester) async {
    await tester.pumpWidget(wrapped(const Pill(label: 'Inner')));

    await tester.tap(find.byType(Pill));

    expect(tester.takeException(), isNull);
  });
}
