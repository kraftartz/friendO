import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo_ui/friendo_ui.dart' show Soft, SoftWell;

void main() {
  Widget wrapped(Widget child, {Soft tokens = const Soft.dark()}) =>
      MaterialApp(
        theme: ThemeData(extensions: [tokens]),
        home: Scaffold(body: Center(child: child)),
      );

  BoxDecoration decorationOf(WidgetTester tester) =>
      tester
              .widget<DecoratedBox>(
                find.descendant(
                  of: find.byType(SoftWell),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .decoration
          as BoxDecoration;

  testWidgets('sinks into the field, in the well colour', (tester) async {
    await tester.pumpWidget(wrapped(const SoftWell(child: Text('typed'))));

    expect(decorationOf(tester).color, const Soft.dark().well);
  });

  testWidgets('follows the tokens rather than a fixed value', (tester) async {
    const tokens = Soft(
      surface: Color(0xFF102030),
      glow: Color(0xFF405060),
      radius: 8,
      well: Color(0xFF010203),
    );

    await tester.pumpWidget(
      wrapped(const SoftWell(child: Text('typed')), tokens: tokens),
    );

    expect(decorationOf(tester).color, tokens.well);
  });

  testWidgets('shows its child', (tester) async {
    await tester.pumpWidget(wrapped(const SoftWell(child: Text('typed'))));

    expect(find.text('typed'), findsOneWidget);
  });
}
