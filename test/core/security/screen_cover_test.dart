import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/security/screen_cover.dart';

void main() {
  Future<void> show(WidgetTester tester) => tester.pumpWidget(
    const MaterialApp(home: ScreenCover(child: Text('a Friend'))),
  );

  Future<void> becomes(WidgetTester tester, AppLifecycleState state) async {
    tester.binding.handleAppLifecycleStateChanged(state);
    await tester.pump();
  }

  testWidgets('shows the app while it is in front', (tester) async {
    await show(tester);

    expect(find.byKey(screenCoverKey), findsNothing);
  });

  testWidgets('covers the app as soon as it becomes inactive', (tester) async {
    await show(tester);

    await becomes(tester, AppLifecycleState.inactive);

    expect(find.byKey(screenCoverKey), findsOneWidget);
  });

  testWidgets('stays covered while the app is away', (tester) async {
    await show(tester);

    await becomes(tester, AppLifecycleState.inactive);
    await becomes(tester, AppLifecycleState.paused);

    expect(find.byKey(screenCoverKey), findsOneWidget);
  });

  testWidgets('uncovers the app when it comes back', (tester) async {
    await show(tester);
    await becomes(tester, AppLifecycleState.inactive);

    await becomes(tester, AppLifecycleState.resumed);

    expect(find.byKey(screenCoverKey), findsNothing);
  });
}
