import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo_ui/friendo_ui.dart' show AvatarHalo;

void main() {
  const colour = Color(0xFF8B5CF6);

  Widget wrapped(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  BoxDecoration decorationOf(WidgetTester tester) =>
      tester.widget<DecoratedBox>(find.byType(DecoratedBox)).decoration
          as BoxDecoration;

  testWidgets('shows the label it is given', (tester) async {
    await tester.pumpWidget(
      wrapped(const AvatarHalo(label: 'M', colour: colour)),
    );

    expect(find.text('M'), findsOneWidget);
  });

  testWidgets('draws a circle, haloed in the colour it is given', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapped(const AvatarHalo(label: 'M', colour: colour)),
    );

    final decoration = decorationOf(tester);

    expect(decoration.shape, BoxShape.circle);
    expect(decoration.border!.top.color, colour);
  });

  testWidgets('takes the width and the height it is given', (tester) async {
    await tester.pumpWidget(
      wrapped(const AvatarHalo(label: 'M', colour: colour, size: 28)),
    );

    expect(tester.getSize(find.byType(AvatarHalo)), const Size(28, 28));
  });

  testWidgets('adds a glow when it is lit, and none when it is not', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapped(const AvatarHalo(label: 'M', colour: colour)),
    );
    expect(decorationOf(tester).boxShadow, isEmpty);

    await tester.pumpWidget(
      wrapped(const AvatarHalo(label: 'M', colour: colour, isLit: true)),
    );
    expect(decorationOf(tester).boxShadow!.single.color.a, greaterThan(0));
  });
}
