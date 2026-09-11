import 'dart:io';

import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/db/database_session.dart'
    show DatabaseLockedError, DatabaseState;
import 'package:friendo/core/profiles/profile_session.dart' show Unlocked;
import 'package:friendo/core/settings/profile_settings.dart'
    show autoLockChoices;
import 'package:friendo/core/settings/settings_store.dart' show SettingsStore;
import 'package:friendo/features/settings/bloc/settings_cubit.dart'
    show SettingsCubit;

import '../../support/fake_gates.dart';
import '../../support/wiring.dart';

/// The Settings screen's state, over the real stores and the real lock, with
/// the three platform gates faked.
///
/// The screen owns no mechanism, so what is worth proving is what it writes
/// and which of the two stores it writes to.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Wiring wiring;
  late SettingsStore store;
  late FakeNotificationGate notifications;
  late FakeBiometricGate biometrics;
  late FakeScreenPrivacy screens;
  late String profileId;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_settings_screen');
    wiring = Wiring(directory);
    store = SettingsStore(wiring.databases);
    notifications = FakeNotificationGate();
    biometrics = FakeBiometricGate();
    screens = FakeScreenPrivacy();
    profileId = (await wiring.creator.createProfile('Michal', '123456')).id;
    await wiring.session.unlock(profileId, '123456');
  });

  tearDown(() async {
    await wiring.dispose();
    directory.deleteSync(recursive: true);
  });

  SettingsCubit theScreen() => SettingsCubit(
    profileId: profileId,
    settings: store,
    profiles: wiring.profiles,
    session: wiring.session,
    databases: wiring.databases,
    notifications: notifications,
    biometrics: biometrics,
    screens: screens,
  );

  Future<void> until(bool Function() answer) async {
    for (var tries = 0; tries < 200 && !answer(); tries++) {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await pumpEventQueue();
    }
  }

  Future<SettingsCubit> anOpenScreen() async {
    final screen = theScreen();
    addTearDown(screen.close);
    await until(() => !screen.state.isLocked);

    return screen;
  }

  group('reminders', () {
    test('are off in a new Profile, and ask for nothing', () async {
      final screen = await anOpenScreen();

      expect(screen.state.remindersOn, isFalse);
      expect(notifications.requests, 0);
    });

    test('ask for the permission at the moment the switch goes on', () async {
      final screen = await anOpenScreen();

      await screen.turnRemindersOn(on: true);

      expect(notifications.requests, 1);
      expect(screen.state.remindersOn, isTrue);
      expect(screen.state.permissionRefused, isFalse);
    });

    test('return the switch to off when the permission is refused', () async {
      notifications.grants = false;
      final screen = await anOpenScreen();

      await screen.turnRemindersOn(on: true);

      expect(screen.state.remindersOn, isFalse);
      expect(screen.state.permissionRefused, isTrue);
      expect((await store.read()).remindersOn, isFalse);
    });

    test('notice a permission revoked outside the app, on a resume', () async {
      final screen = await anOpenScreen();
      await screen.turnRemindersOn(on: true);
      expect(screen.state.remindersOn, isTrue);

      notifications.allowedNow = false;
      screen.didChangeAppLifecycleState(AppLifecycleState.resumed);
      await until(() => !screen.state.remindersOn);

      expect(screen.state.remindersOn, isFalse);
      expect(screen.state.permissionRefused, isTrue);
      expect(
        notifications.requests,
        1,
        reason: 'nothing is re-requested on its own',
      );
    });

    test('keep one hour for the whole Profile', () async {
      final screen = await anOpenScreen();

      await screen.chooseReminderHour(19);

      expect(screen.state.reminderHour, 19);
      expect((await store.read()).reminderHour, 19);
    });
  });

  group('privacy', () {
    test('offers a short list of waits, and starts on 60 seconds', () async {
      final screen = await anOpenScreen();
      expect(screen.state.autoLock, const Duration(seconds: 60));

      await screen.chooseAutoLock(const Duration(minutes: 5));

      expect(screen.state.autoLock, const Duration(minutes: 5));
      expect((await store.read()).autoLockSeconds, 300);
      expect(autoLockChoices, contains(const Duration(minutes: 5)));
    });

    test('locks now, and it is the lock the auto-lock calls', () async {
      final screen = await anOpenScreen();

      await screen.lockNow();

      expect(wiring.databases.stateNow, DatabaseState.locked);
      await until(() => screen.state.isLocked);
      expect(screen.state.isLocked, isTrue);
    });

    test('changes the screenshot allowance on the platform too', () async {
      final screen = await anOpenScreen();
      expect(screen.state.screenshotsAllowed, isFalse);

      await screen.allowScreenshots(allowed: true);

      expect(screen.state.screenshotsAllowed, isTrue);
      expect((await store.read()).screenshotsAllowed, isTrue);
      expect(screens.told, [true]);

      await screen.allowScreenshots(allowed: false);
      expect(screens.told, [true, false]);
    });

    test(
      'confirms with the operating system before it offers a finger',
      () async {
        final screen = await anOpenScreen();

        await screen.useBiometricUnlock(uses: true);

        expect(biometrics.confirmations, 1);
        expect(biometrics.named, ['Michal']);
        expect(screen.state.usesBiometricUnlock, isTrue);
        expect(
          (await wiring.profiles.read()).single.usesBiometricUnlock,
          isTrue,
        );
      },
    );

    test('writes no flag when the operating system does not confirm', () async {
      biometrics.confirms = false;
      final screen = await anOpenScreen();

      await screen.useBiometricUnlock(uses: true);

      expect(screen.state.usesBiometricUnlock, isFalse);
      expect(
        (await wiring.profiles.read()).single.usesBiometricUnlock,
        isFalse,
      );
    });

    test('withdraws the finger without asking the operating system', () async {
      final screen = await anOpenScreen();
      await screen.useBiometricUnlock(uses: true);

      await screen.useBiometricUnlock(uses: false);

      expect(screen.state.usesBiometricUnlock, isFalse);
      expect(biometrics.confirmations, 1);
    });
  });

  group('the Profile', () {
    test('names the Profile the User is in', () async {
      final screen = await anOpenScreen();

      expect(screen.state.profileName, 'Michal');
    });

    test('renames it and leaves the other fields intact', () async {
      final was = (await wiring.profiles.read()).single;
      final screen = await anOpenScreen();

      await screen.rename('  Michał  ');

      expect(screen.state.profileName, 'Michał');
      final now = (await wiring.profiles.read()).single;
      expect(now.pinHash, was.pinHash);
      expect(now.kdfParams, was.kdfParams);
    });

    test('closes the first connection before the second opens', () async {
      await wiring.session.lock();
      final second = await wiring.creator.createProfile('Kasia', '654321');
      await wiring.session.lock();
      await wiring.session.unlock(profileId, '123456');
      final screen = await anOpenScreen();
      expect(screen.state.otherProfiles.map((row) => row.id), [second.id]);

      final seen = <DatabaseState>[];
      final watching = wiring.databases.state.listen(seen.add);
      addTearDown(watching.cancel);
      await pumpEventQueue();

      final outcome = await screen.switchTo(second.id, '654321');

      expect(outcome, const Unlocked());
      expect(
        seen,
        containsAllInOrder([
          DatabaseState.open,
          DatabaseState.locked,
          DatabaseState.opening,
          DatabaseState.open,
        ]),
      );
    });
  });

  group('the lock', () {
    test('throws DatabaseLockedError on a write while locked', () async {
      final screen = await anOpenScreen();
      await wiring.session.lock();
      await until(() => screen.state.isLocked);

      await expectLater(
        screen.chooseReminderHour(8),
        throwsA(isA<DatabaseLockedError>()),
      );
    });

    test('goes quiet across a lock and reads fresh on unlock', () async {
      final screen = await anOpenScreen();
      await screen.chooseReminderHour(21);

      await wiring.session.lock();
      await until(() => screen.state.isLocked);
      expect(screen.state.profile, isNull);

      await wiring.session.unlock(profileId, '123456');
      await until(() => !screen.state.isLocked);

      expect(screen.state.reminderHour, 21);
      expect(screen.state.profileName, 'Michal');
    });
  });
}
