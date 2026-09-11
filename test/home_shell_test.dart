import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/app.dart' show FriendoApp;
import 'package:friendo/app/navigation/app_router.dart'
    show dialPath, settingsPath;
import 'package:friendo/app/navigation/app_section.dart' show AppSection;
import 'package:friendo/features/dial/view/dial_view.dart' show DialView;
import 'package:friendo/features/first_run/view/first_run_page.dart'
    show FirstRunPage;
import 'package:friendo/features/friends/view/friends_body.dart'
    show FriendsBody;

import 'support/fake_gates.dart';
import 'support/wiring.dart';

/// The frame around the three sections: a page above, a bar below.
///
/// The bar reports a tap and routes nothing itself. What it reaches is the
/// router's to decide, so these read what the app draws rather than what the
/// bar holds.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Wiring wiring;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_shell');
    wiring = Wiring(directory);
  });

  tearDown(() => directory.deleteSync(recursive: true));

  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var pumps = 0; pumps < 60 && finder.evaluate().isEmpty; pumps++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      // With a duration, because a route transition is an animation and a
      // pump of no length advances no time.
      await tester.pump(const Duration(milliseconds: 32));
    }
  }

  /// Pumps until [answer] is true, letting real work run between.
  Future<void> waitUntil(WidgetTester tester, bool Function() answer) async {
    for (var pumps = 0; pumps < 60 && !answer(); pumps++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 32));
    }
  }

  /// Starts the app, with a Profile open when [open] says so.
  Future<void> start(WidgetTester tester, {bool open = true}) async {
    addTearDown(() => tester.runAsync(wiring.dispose));

    if (open) {
      await tester.runAsync(() async {
        final profile = await wiring.creator.createProfile('Michal', '123456');
        await wiring.session.openProfile(profile.id);
      });
    }

    await tester.pumpWidget(
      FriendoApp(
        edges: fakeEdges(),
        creator: wiring.creator,
        session: wiring.session,
      ),
    );
  }

  group('the app shell', () {
    testWidgets('opens on the Dial', (tester) async {
      await start(tester);
      await waitFor(tester, find.byType(DialView));

      expect(find.byType(DialView), findsOneWidget);
    });

    testWidgets('draws no section at all while no Profile is open', (
      tester,
    ) async {
      await start(tester, open: false);
      await waitFor(tester, find.byType(FirstRunPage));

      // Not a quiet Dial behind the lock, but no Dial and no bar. ADR-0011
      // hides the Friends, and a section drawn empty is still a section.
      expect(find.byType(DialView), findsNothing);
      for (final section in AppSection.values) {
        expect(find.text(section.label), findsNothing);
      }
    });

    testWidgets('shows one destination per section', (tester) async {
      await start(tester);
      await waitFor(tester, find.byType(DialView));

      for (final section in AppSection.values) {
        expect(find.text(section.label), findsOneWidget);
      }
    });

    testWidgets('the bar switches the visible page', (tester) async {
      await start(tester);
      await waitFor(tester, find.byType(DialView));
      expect(find.byType(FriendsBody), findsNothing);

      await tester.tap(find.text('Friends'));
      await waitFor(tester, find.byType(FriendsBody));

      expect(find.byType(FriendsBody), findsOneWidget);
      // The Dial is still built, and the shell now keeps it offstage.
      expect(find.byType(DialView), findsNothing);
    });

    testWidgets('returns to the Dial with its state intact', (tester) async {
      await start(tester);
      await waitFor(tester, find.byType(DialView));

      String whereWeAre() => GoRouter.of(
        tester.element(find.byType(NavigationBar)),
      ).state.matchedLocation;

      await tester.tap(find.text('Settings'));
      await waitUntil(tester, () => whereWeAre() == settingsPath);

      await tester.tap(find.text('Dial'));
      await waitUntil(tester, () => whereWeAre() == dialPath);

      // The Dial is the branch again, and it is the one that was built
      // before: a shell keeps each branch rather than making it twice.
      expect(find.byType(DialView), findsOneWidget);
    });
  });
}
