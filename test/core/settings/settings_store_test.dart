import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/db/database_session.dart' show DatabaseLockedError;
import 'package:friendo/core/settings/profile_settings.dart'
    show ProfileSettings, autoLockChoices;
import 'package:friendo/core/settings/settings_store.dart' show SettingsStore;

import '../../support/wiring.dart';

/// The two stores a setting can live in, and the rule that decides which.
///
/// A setting the lock screen must read before anything is unlocked goes in
/// profiles.json. Everything else goes in the encrypted database. See
/// ADR-0036.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late Wiring wiring;
  late SettingsStore settings;
  late String profileId;

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_settings');
    wiring = Wiring(directory);
    settings = SettingsStore(wiring.databases);
    profileId = (await wiring.creator.createProfile('Michal', '123456')).id;
    await wiring.session.unlock(profileId, '123456');
  });

  tearDown(() async {
    await wiring.dispose();
    directory.deleteSync(recursive: true);
  });

  Future<Map<String, dynamic>> profileRowOf(String id) async {
    final file = jsonDecode(await wiring.profiles.file.readAsString());
    final rows = (file as Map<String, dynamic>)['profiles'] as List;

    return rows.cast<Map<String, dynamic>>().firstWhere(
      (row) => row['id'] == id,
    );
  }

  group('the encrypted store', () {
    test('gives a new Profile reminders off and a secure screen', () async {
      final held = await settings.read();

      expect(held.remindersOn, isFalse);
      expect(held.screenshotsAllowed, isFalse);
      expect(held, const ProfileSettings());
    });

    test('writes the auto-lock wait and reads it back', () async {
      expect((await settings.read()).autoLock, const Duration(seconds: 60));

      await settings.change(autoLockSeconds: 15);

      expect((await settings.read()).autoLockSeconds, 15);
      expect(autoLockChoices, contains(const Duration(seconds: 15)));
    });

    test('keeps the screenshot allowance out of profiles.json', () async {
      await settings.change(screenshotsAllowed: true);

      expect((await settings.read()).screenshotsAllowed, isTrue);
      expect(
        await profileRowOf(profileId),
        isNot(contains('screenshotsAllowed')),
      );
    });

    test('changes one value and leaves the others alone', () async {
      await settings.change(remindersOn: true, reminderHour: 19);
      await settings.change(autoLockSeconds: 300);

      final held = await settings.read();
      expect(held.remindersOn, isTrue);
      expect(held.reminderHour, 19);
      expect(held.autoLockSeconds, 300);
    });

    test('throws on a write while the Profile is locked', () async {
      await wiring.session.lock();

      await expectLater(
        settings.change(remindersOn: true),
        throwsA(isA<DatabaseLockedError>()),
      );
    });

    test('goes quiet on a lock and reads again on unlock', () async {
      final seen = <ProfileSettings>[];
      final watching = settings.watch().listen(seen.add);
      addTearDown(watching.cancel);

      await settings.change(reminderHour: 21);
      await pumpEventQueue();
      final beforeLock = seen.length;

      await wiring.session.lock();
      await pumpEventQueue();
      expect(seen, hasLength(beforeLock), reason: 'a locked watch is quiet');

      await wiring.session.unlock(profileId, '123456');
      await pumpEventQueue();

      expect(seen.last.reminderHour, 21);
    });
  });

  group('the plaintext file', () {
    test('writes the biometric flag to profiles.json only', () async {
      await wiring.profiles.changeOne(
        profileId,
        (profile) => profile.withBiometricUnlock(true),
      );

      expect((await profileRowOf(profileId))['usesBiometricUnlock'], isTrue);
      final held = await wiring.profiles.read();
      expect(held.single.usesBiometricUnlock, isTrue);
      expect(await settings.read(), const ProfileSettings());
    });

    test('survives a rename with its other fields intact', () async {
      final was = (await wiring.profiles.read()).single;

      await wiring.profiles.changeOne(
        profileId,
        (profile) => profile.named('Michał'),
      );

      final now = (await wiring.profiles.read()).single;
      expect(now.displayName, 'Michał');
      expect(now.pinHash, was.pinHash);
      expect(now.kdfParams, was.kdfParams);
      expect(now.failedAttempts, was.failedAttempts);
      expect(now.id, was.id);
    });

    test(
      'writes through a temporary file and renames over the target',
      () async {
        await wiring.profiles.changeOne(
          profileId,
          (profile) => profile.named('Michał'),
        );

        expect(
          File('${wiring.profiles.file.path}.tmp').existsSync(),
          isFalse,
          reason: 'the temporary file is renamed, not left behind',
        );
        expect(wiring.profiles.file.existsSync(), isTrue);
      },
    );

    test('leaves one Profile flag alone when the other changes', () async {
      // Creating a Profile opens its database, and one Profile is open at a
      // time (ADR-0007).
      await wiring.session.lock();
      final second = await wiring.creator.createProfile('Kasia', '654321');
      await wiring.session.lock();

      await wiring.profiles.changeOne(
        profileId,
        (profile) => profile.withBiometricUnlock(true),
      );

      final held = {
        for (final profile in await wiring.profiles.read())
          profile.id: profile.usesBiometricUnlock,
      };
      expect(held[profileId], isTrue);
      expect(held[second.id], isFalse);
    });

    test('reads a file written before the flag existed as off', () async {
      final file =
          jsonDecode(await wiring.profiles.file.readAsString())
              as Map<String, dynamic>;
      for (final row
          in (file['profiles'] as List).cast<Map<String, dynamic>>()) {
        row.remove('usesBiometricUnlock');
      }
      await wiring.profiles.file.writeAsString(jsonEncode(file));

      expect(
        (await wiring.profiles.read()).single.usesBiometricUnlock,
        isFalse,
      );
    });
  });
}
