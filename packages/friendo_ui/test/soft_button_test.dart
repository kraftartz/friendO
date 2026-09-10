import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo_ui/friendo_ui.dart' show Soft, SoftButton;

void main() {
  Widget wrapped(Widget child) => MaterialApp(
    theme: ThemeData(extensions: const [Soft.dark()]),
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('shows its child', (tester) async {
    await tester.pumpWidget(
      wrapped(const SoftButton(child: Text('Log a Meeting'))),
    );

    expect(find.text('Log a Meeting'), findsOneWidget);
  });

  testWidgets('reports a tap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      wrapped(
        SoftButton(onPressed: () => taps++, child: const Text('Log a Meeting')),
      ),
    );

    await tester.tap(find.byType(SoftButton));

    expect(taps, 1);
  });

  testWidgets('refuses a tap while it has no handler', (tester) async {
    await tester.pumpWidget(
      wrapped(const SoftButton(child: Text('Log a Meeting'))),
    );

    await tester.tap(find.byType(SoftButton));

    expect(tester.takeException(), isNull);
  });
}
