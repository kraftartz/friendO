import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/app.dart' show FriendoApp;
import 'package:friendo/core/friends/friend_repository.dart'
    show FriendRepository;
import 'package:friendo/features/friends/view/add_friend_page.dart'
    show AddFriendPage;
import 'package:friendo/features/friends/view/friends_body.dart'
    show FriendsBody;
import 'package:friendo/features/friends/view/notepad_page.dart'
    show NotepadPage;
import 'package:friendo_domain/friendo_domain.dart'
    show Cadence, CivilDate, Friend, Meeting;

import '../../support/fake_gates.dart';
import '../../support/wiring.dart';

/// The two requests the Friends List produces, carried to the two screens
/// that answer them.
///
/// The Friends List raises "open this Friend" and "add a Friend" and routes
/// neither itself. This reads what the app layer does with them.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Wiring wiring;
  late String profileId;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_routing');
    wiring = Wiring(directory);
  });

  tearDown(() => directory.deleteSync(recursive: true));

  /// Pumps until [finder] finds something, letting real work run between.
  ///
  /// The screens read a real file and a real database, and neither makes
  /// progress inside the fake clock of a test.
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var pumps = 0; pumps < 60 && finder.evaluate().isEmpty; pumps++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
  }

  /// Starts the app on an open Profile, with [friends] already in the roster.
  Future<void> start(
    WidgetTester tester, {
    List<String> friends = const [],
  }) async {
    // The connection is closed through the tester, because closing a real
    // file makes no progress inside the fake clock a widget test runs in.
    addTearDown(() => tester.runAsync(wiring.dispose));

    await tester.runAsync(() async {
      profileId = (await wiring.creator.createProfile('Michal', '123456')).id;
      // Creating a Profile opens its file and closes it again, so the app
      // starts on a locked one unless the test opens it first. The open step
      // takes no PIN, which is what First Run and a later biometric route
      // both reach.
      await wiring.session.openProfile(profileId);
      final roster = FriendRepository(wiring.databases);
      for (final name in friends) {
        await roster.save(
          Friend.started(
            id: name,
            name: name,
            cadence: Cadence.ofDays(30),
            firstMeeting: Meeting(
              id: 'm-$name',
              happenedOn: CivilDate.from(DateTime.now()),
            ),
            now: DateTime.now(),
          ),
        );
      }
    });

    await tester.pumpWidget(
      FriendoApp(
        edges: fakeEdges(),
        creator: wiring.creator,
        session: wiring.session,
      ),
    );
    await waitFor(tester, find.text('Friends'));
  }

  /// Moves to the Friends section.
  ///
  /// The sections sit in an IndexedStack, which keeps the ones it is not
  /// showing offstage, and a finder skips offstage widgets. So the list has to
  /// be the section on screen before anything on it can be found.
  Future<void> goToTheList(WidgetTester tester) async {
    await tester.tap(find.text('Friends'));
    await tester.pump();
    await waitFor(tester, find.byType(FriendsBody));
  }

  testWidgets('the empty roster offers a control that is not dead', (
    tester,
  ) async {
    await start(tester);
    await goToTheList(tester);

    final button = find.widgetWithText(FilledButton, 'Add your first Friend');
    await waitFor(tester, button);

    expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
  });

  testWidgets('adding the first Friend reaches the form', (tester) async {
    await start(tester);
    await goToTheList(tester);
    await waitFor(
      tester,
      find.widgetWithText(FilledButton, 'Add your first Friend'),
    );

    await tester.tap(
      find.widgetWithText(FilledButton, 'Add your first Friend'),
    );
    await waitFor(tester, find.byType(AddFriendPage));

    expect(find.byType(AddFriendPage), findsOneWidget);
    expect(find.text('Add a Friend'), findsOneWidget);
  });

  testWidgets('a card reaches that Friend, top to bottom', (tester) async {
    await start(tester, friends: ['Anna']);
    await goToTheList(tester);
    await waitFor(tester, find.text('Anna'));

    await tester.tap(find.text('Anna'));
    await waitFor(tester, find.byType(NotepadPage));

    expect(find.byType(NotepadPage), findsOneWidget);
  });

  testWidgets('a lock takes the pushed screen off the stack', (tester) async {
    await start(tester, friends: ['Anna']);
    await goToTheList(tester);
    await waitFor(tester, find.text('Anna'));
    await tester.tap(find.text('Anna'));
    await waitFor(tester, find.byType(NotepadPage));

    await tester.runAsync(wiring.session.lock);
    await tester.pump();
    await tester.pump();

    expect(
      find.byType(NotepadPage),
      findsNothing,
      reason: 'a locked Notepad must not rest over the keypad',
    );
  });
}
