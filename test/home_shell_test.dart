import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/app.dart';
import 'package:friendo/app/navigation/app_section.dart';

void main() {
  group('the app shell', () {
    testWidgets('opens on the Dial and shows a phase from the domain', (
      tester,
    ) async {
      await tester.pumpWidget(const FriendoApp());

      // 12 days into a 30 day Cadence.
      expect(find.text('0.40'), findsOneWidget);
    });

    testWidgets('shows one destination per section', (tester) async {
      await tester.pumpWidget(const FriendoApp());

      for (final section in AppSection.values) {
        expect(find.text(section.label), findsOneWidget);
      }
    });

    testWidgets('the bar switches the visible page', (tester) async {
      await tester.pumpWidget(const FriendoApp());
      expect(find.text('Friends page'), findsNothing);

      await tester.tap(find.text('Friends'));
      await tester.pumpAndSettle();

      expect(find.text('Friends page'), findsOneWidget);
      // The Dial is still built, but the IndexedStack now keeps it offstage.
      expect(find.text('Phase'), findsNothing);
    });

    testWidgets('returns to the Dial with its state intact', (tester) async {
      await tester.pumpWidget(const FriendoApp());

      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Settings page'), findsOneWidget);

      await tester.tap(find.text('Dial'));
      await tester.pumpAndSettle();
      expect(find.text('0.40'), findsOneWidget);
    });
  });
}
