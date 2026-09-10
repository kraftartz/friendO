import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/features/auth/view/damaged_list_page.dart';

void main() {
  Future<void> show(WidgetTester tester) => tester.pumpWidget(
    const MaterialApp(
      home: DamagedListPage(
        path: '/data/friendo/profiles.json',
        reason: 'is not a Profile list',
      ),
    ),
  );

  testWidgets('names the file it could not read', (tester) async {
    await show(tester);

    expect(find.text('/data/friendo/profiles.json'), findsOneWidget);
  });

  testWidgets('says the reason', (tester) async {
    await show(tester);

    expect(find.text('is not a Profile list'), findsOneWidget);
  });

  testWidgets('offers no way forward', (tester) async {
    await show(tester);

    expect(find.byType(ButtonStyleButton), findsNothing);
    expect(find.byType(TextField), findsNothing);
  });
}
