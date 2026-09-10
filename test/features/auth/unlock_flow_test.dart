import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/app.dart';
import 'package:friendo/app/boot.dart';
import 'package:friendo/core/profiles/profile.dart';
import 'package:friendo/features/auth/bloc/unlock_cubit.dart';
import 'package:friendo/features/auth/bloc/unlock_state.dart';
import 'package:friendo/features/auth/view/profile_picker_page.dart';
import 'package:friendo/features/auth/view/unlock_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../support/wiring.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Wiring wiring;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_unlock_flow');
    wiring = Wiring(directory);
  });

  tearDown(() async {
    await wiring.dispose();
    directory.deleteSync(recursive: true);
  });

  Future<Profile> aProfile(WidgetTester tester, String name, String pin) async {
    late Profile profile;
    await tester.runAsync(() async {
      profile = await wiring.creator.createProfile(name, pin);
      await wiring.databases.close();
    });

    return profile;
  }

  Future<void> start(WidgetTester tester, FirstScreen screen) =>
      tester.pumpWidget(
        FriendoApp(
          creator: wiring.creator,
          session: wiring.session,
          firstScreen: screen,
        ),
      );

  /// Pumps until [finder] finds something, letting real work run between.
  ///
  /// The app reads the Profile list from a real file when the Profile closes,
  /// and a file read makes no progress inside the fake clock of a test.
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var pumps = 0; pumps < 50 && finder.evaluate().isEmpty; pumps++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
  }

  Future<void> typeThePin(WidgetTester tester, String pin) async {
    final cubit = BlocProvider.of<UnlockCubit>(
      tester.element(find.byType(UnlockPage)),
    );

    await tester.runAsync(() async {
      for (final digit in pin.split('')) {
        await tester.tap(find.widgetWithText(TextButton, digit));
      }
      await cubit.stream
          .firstWhere((state) => state.step == UnlockStep.open)
          .timeout(const Duration(seconds: 30));
    });
    await tester.pump();
    await tester.pump();
  }

  testWidgets('a phone with one Profile starts on the keypad', (tester) async {
    final profile = await aProfile(tester, 'Michal', '123456');

    await start(tester, AskForPin(profile));

    expect(find.byType(UnlockPage), findsOneWidget);
    expect(find.text('Michal'), findsOneWidget);
  });

  testWidgets('the right PIN opens the app', (tester) async {
    final profile = await aProfile(tester, 'Michal', '123456');
    await start(tester, AskForPin(profile));

    await typeThePin(tester, '123456');

    expect(find.byType(UnlockPage), findsNothing);
    expect(find.text('Dial'), findsOneWidget);
  });

  testWidgets('a lock takes the app off the screen', (tester) async {
    final profile = await aProfile(tester, 'Michal', '123456');
    await start(tester, AskForPin(profile));
    await typeThePin(tester, '123456');

    await tester.runAsync(wiring.session.lock);
    await waitFor(tester, find.byType(UnlockPage));

    expect(find.text('Dial'), findsNothing);
    expect(find.byType(UnlockPage), findsOneWidget);
  });

  testWidgets('two Profiles start on the picker', (tester) async {
    final mine = await aProfile(tester, 'Michal', '123456');
    final theirs = await aProfile(tester, 'Ola', '654321');

    await start(tester, PickProfile([mine, theirs]));

    expect(find.byType(ProfilePickerPage), findsOneWidget);
    expect(find.text('Michal'), findsOneWidget);
    expect(find.text('Ola'), findsOneWidget);
  });

  testWidgets('the Profile that is picked gets the keypad', (tester) async {
    final mine = await aProfile(tester, 'Michal', '123456');
    final theirs = await aProfile(tester, 'Ola', '654321');
    await start(tester, PickProfile([mine, theirs]));

    await tester.tap(find.text('Ola'));
    await tester.pumpAndSettle();

    expect(find.byType(UnlockPage), findsOneWidget);
    expect(find.text('Ola'), findsOneWidget);
  });
}
