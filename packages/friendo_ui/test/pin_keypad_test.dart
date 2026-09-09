import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo_ui/friendo_ui.dart';

void main() {
  group('PinKeypad', () {
    testWidgets('reports the digit that was pressed', (tester) async {
      final pressed = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: PinKeypad(onDigit: pressed.add, onDelete: () {}),
        ),
      );

      await tester.tap(find.text('7'));
      await tester.tap(find.text('0'));

      expect(pressed, [7, 0]);
    });

    testWidgets('offers every digit once', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PinKeypad(onDigit: (_) {}, onDelete: () {}),
        ),
      );

      for (var digit = 0; digit <= 9; digit++) {
        expect(find.text('$digit'), findsOneWidget);
      }
    });

    testWidgets('reports a press on delete', (tester) async {
      var deleted = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: PinKeypad(onDigit: (_) {}, onDelete: () => deleted++),
        ),
      );

      await tester.tap(find.byIcon(Icons.backspace_outlined));

      expect(deleted, 1);
    });
  });

  group('PinDots', () {
    testWidgets('draws one dot for every digit the entry takes', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: PinDots(length: 6, filled: 2)),
      );

      expect(find.byType(PinDot), findsNWidgets(6));
    });

    testWidgets('fills a dot for every digit typed, and shows no digit', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: PinDots(length: 6, filled: 2)),
      );

      final dots = tester.widgetList<PinDot>(find.byType(PinDot)).toList();

      expect(dots.where((dot) => dot.filled), hasLength(2));
      expect(find.textContaining(RegExp('[0-9]')), findsNothing);
    });
  });
}
