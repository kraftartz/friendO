import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/app.dart';
import 'package:friendo/app/navigation/app_section.dart';
import 'package:friendo/features/dial/view/dial_view.dart' show DialView;
import 'package:friendo/features/friends/view/friends_body.dart'
    show FriendsBody;

import 'support/wiring.dart';

FriendoApp aFriendoApp() {
  final wiring = Wiring(Directory.systemTemp);

  return FriendoApp(creator: wiring.creator, session: wiring.session);
}

void main() {
  group('the app shell', () {
    testWidgets('opens on the Dial', (tester) async {
      await tester.pumpWidget(aFriendoApp());

      expect(find.byType(DialView), findsOneWidget);
    });

    testWidgets('draws the Dial quiet while no Profile is open', (
      tester,
    ) async {
      await tester.pumpWidget(aFriendoApp());

      // No Friend, no name and no count belongs on screen until a Profile is
      // open. An empty roster is a different reading, and it says so.
      expect(find.textContaining('Add your first Friend'), findsNothing);
      expect(find.textContaining('Log a Meeting'), findsNothing);
    });

    testWidgets('shows one destination per section', (tester) async {
      await tester.pumpWidget(aFriendoApp());

      for (final section in AppSection.values) {
        expect(find.text(section.label), findsOneWidget);
      }
    });

    testWidgets('the bar switches the visible page', (tester) async {
      await tester.pumpWidget(aFriendoApp());
      expect(find.byType(FriendsBody), findsNothing);

      await tester.tap(find.text('Friends'));
      await tester.pumpAndSettle();

      expect(find.byType(FriendsBody), findsOneWidget);
      // The Dial is still built, but the IndexedStack now keeps it offstage.
      expect(find.byType(DialView), findsNothing);
    });

    testWidgets('returns to the Dial with its state intact', (tester) async {
      await tester.pumpWidget(aFriendoApp());

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings page'), findsOneWidget);

      await tester.tap(find.text('Dial'));
      await tester.pumpAndSettle();
      expect(find.byType(DialView), findsOneWidget);
    });
  });
}
