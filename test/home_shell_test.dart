import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/app.dart';
import 'package:friendo/app/navigation/app_section.dart';

import 'support/wiring.dart';

FriendoApp aFriendoApp() {
  final wiring = Wiring(Directory.systemTemp);

  return FriendoApp(creator: wiring.creator, session: wiring.session);
}

void main() {
  group('the app shell', () {
    testWidgets('opens on the Dial and shows a phase from the domain', (
      tester,
    ) async {
      await tester.pumpWidget(aFriendoApp());

      // 12 days into a 30 day Cadence.
      expect(find.text('0.40'), findsOneWidget);
    });

    testWidgets('shows one destination per section', (tester) async {
      await tester.pumpWidget(aFriendoApp());

      for (final section in AppSection.values) {
        expect(find.text(section.label), findsOneWidget);
      }
    });

    testWidgets('the bar switches the visible page', (tester) async {
      await tester.pumpWidget(aFriendoApp());
      expect(find.text('Friends page'), findsNothing);

      await tester.tap(find.text('Friends'));
      await tester.pumpAndSettle();

      expect(find.text('Friends page'), findsOneWidget);
      // The Dial is still built, but the IndexedStack now keeps it offstage.
      expect(find.text('Phase'), findsNothing);
    });

    testWidgets('returns to the Dial with its state intact', (tester) async {
      await tester.pumpWidget(aFriendoApp());

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings page'), findsOneWidget);

      await tester.tap(find.text('Dial'));
      await tester.pumpAndSettle();
      expect(find.text('0.40'), findsOneWidget);
    });
  });
}
