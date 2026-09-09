import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/crypto/pin_hash.dart';
import 'package:friendo/core/db/database_session.dart';
import 'package:friendo/core/profiles/data_key_store.dart';
import 'package:friendo/core/profiles/profile.dart';
import 'package:friendo/core/profiles/profile_creator.dart';
import 'package:friendo/core/profiles/profile_list.dart';
import 'package:friendo/core/profiles/profile_session.dart';
import 'package:hashlib/hashlib.dart';

import '../../support/unmigratable_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late ProfileList profiles;
  late DatabaseSession databases;
  late DataKeyStore dataKeys;
  late ProfileCreator creator;
  late ProfileSession session;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_session');
    profiles = ProfileList(directory);
    databases = DatabaseSession(directory);
    dataKeys = const DataKeyStore();
    creator = ProfileCreator(
      profiles: profiles,
      databases: databases,
      dataKeys: dataKeys,
      security: Argon2Security.test,
    );
    session = ProfileSession(
      profiles: profiles,
      databases: databases,
      dataKeys: dataKeys,
    );
  });

  tearDown(() async {
    await databases.close();
    directory.deleteSync(recursive: true);
  });

  Future<Profile> aProfile([String name = 'Michal', String pin = '123456']) =>
      creator.createProfile(name, pin);

  Future<int> attemptsOf(String profileId) async => (await profiles.read())
      .firstWhere((row) => row.id == profileId)
      .failedAttempts;

  group('the right PIN', () {
    test('opens the Profile', () async {
      final profile = await aProfile();

      expect(await session.unlock(profile.id, '123456'), const Unlocked());
      expect(await databases.state.first, DatabaseState.open);
    });

    test('passes through opening on the way to open', () async {
      final profile = await aProfile();
      final seen = expectLater(
        databases.state,
        emitsInOrder([
          DatabaseState.locked,
          DatabaseState.opening,
          DatabaseState.open,
        ]),
      );

      await session.unlock(profile.id, '123456');

      await seen;
    });

    test('leaves a file that answers a query', () async {
      final profile = await aProfile();

      await session.unlock(profile.id, '123456');
      final row = await databases.database
          .customSelect('select 42 as answer')
          .getSingle();

      expect(row.data['answer'], 42);
    });

    test('clears the count of failed attempts', () async {
      final profile = await aProfile();
      await session.unlock(profile.id, '000000');
      await session.unlock(profile.id, '000000');

      await session.unlock(profile.id, '123456');

      expect(await attemptsOf(profile.id), 0);
    });
  });

  group('the wrong PIN', () {
    test('says the PIN is wrong', () async {
      final profile = await aProfile();

      expect(await session.unlock(profile.id, '000000'), const WrongPin(1));
    });

    test('opens no file', () async {
      final profile = await aProfile();

      await session.unlock(profile.id, '000000');

      expect(await databases.state.first, DatabaseState.locked);
      expect(() => databases.database, throwsA(isA<DatabaseLockedError>()));
    });

    test('counts the attempt in the Profile list', () async {
      final profile = await aProfile();

      await session.unlock(profile.id, '000000');
      await session.unlock(profile.id, '000000');

      expect(await attemptsOf(profile.id), 2);
    });

    test('against one Profile leaves the other count alone', () async {
      final mine = await aProfile('Michal', '123456');
      final theirs = await aProfile('Ola', '654321');

      await session.unlock(mine.id, '000000');

      expect(await attemptsOf(theirs.id), 0);
    });
  });

  group('a Profile that cannot be opened', () {
    test('reports a missing data key, and not a wrong PIN', () async {
      final profile = await aProfile();
      await const FlutterSecureStorage().delete(key: dataKeyNameOf(profile.id));

      expect(
        await session.unlock(profile.id, '123456'),
        const Failed(UnlockFailure.dataKeyMissing),
      );
    });

    test('counts no attempt when the data key is missing', () async {
      final profile = await aProfile();
      await const FlutterSecureStorage().delete(key: dataKeyNameOf(profile.id));

      await session.unlock(profile.id, '123456');

      expect(await attemptsOf(profile.id), 0);
    });

    test('reports a file that will not open with the stored key', () async {
      final profile = await aProfile();
      await dataKeys.write(profile.id, Uint8List.fromList(List.filled(32, 7)));

      expect(
        await session.unlock(profile.id, '123456'),
        const Failed(UnlockFailure.fileWillNotOpen),
      );
      expect(await attemptsOf(profile.id), 0);
    });

    test('reports a schema that will not move forward', () async {
      final profile = await aProfile();
      final stuck = ProfileSession(
        profiles: profiles,
        databases: UnmigratableDatabase(directory),
        dataKeys: dataKeys,
      );

      expect(
        await stuck.unlock(profile.id, '123456'),
        const Failed(UnlockFailure.migrationFailed),
      );
      expect(await attemptsOf(profile.id), 0);
    });

    test('is a defect when the Profile is in no list', () async {
      await expectLater(
        session.unlock('9f2c', '123456'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('two Profiles', () {
    test('read only the Profile that is open', () async {
      final mine = await aProfile('Michal', '123456');
      final theirs = await aProfile('Ola', '654321');

      await session.unlock(mine.id, '123456');
      await databases.database.customStatement(
        'create table friends (name text)',
      );
      await session.lock();

      await session.unlock(theirs.id, '654321');
      final tables = await databases.database
          .customSelect(
            'select count(*) as found from sqlite_master '
            "where name = 'friends'",
          )
          .getSingle();

      expect(tables.data['found'], 0);
      expect(databases.fileOf(mine.id).existsSync(), isTrue);
    });

    test('switch through lock and unlock alone', () async {
      final mine = await aProfile('Michal', '123456');
      final theirs = await aProfile('Ola', '654321');

      await session.unlock(mine.id, '123456');
      await session.lock();
      await session.unlock(theirs.id, '654321');

      expect(await databases.state.first, DatabaseState.open);
    });
  });

  group('the rest after wrong PINs', () {
    Matcher restingFor(Duration rest) => isA<Resting>().having(
      (outcome) => outcome.remaining,
      'remaining',
      allOf(
        greaterThan(rest - const Duration(seconds: 1)),
        lessThanOrEqualTo(rest),
      ),
    );

    Future<void> missTimes(String profileId, int times) async {
      for (var i = 0; i < times; i++) {
        session.arriveAtKeypad();
        await session.unlock(profileId, '000000');
      }
    }

    test('costs nothing for the first four mistakes', () async {
      final profile = await aProfile();

      await missTimes(profile.id, 4);
      session.arriveAtKeypad();

      expect(await session.unlock(profile.id, '123456'), const Unlocked());
      expect(await attemptsOf(profile.id), 0);
    });

    test('refuses the next arrival for 30 seconds after the fifth', () async {
      final profile = await aProfile();

      await missTimes(profile.id, 5);
      session.arriveAtKeypad();

      expect(
        await session.unlock(profile.id, '123456'),
        restingFor(const Duration(seconds: 30)),
      );
      expect(await databases.state.first, DatabaseState.locked);
    });

    test('counts no further attempt while it refuses', () async {
      final profile = await aProfile();
      await missTimes(profile.id, 5);

      session.arriveAtKeypad();
      await session.unlock(profile.id, '000000');

      expect(await attemptsOf(profile.id), 5);
    });

    test('hashes no PIN while it refuses', () async {
      final profile = await aProfile();
      await missTimes(profile.id, 5);
      await profiles.write([
        Profile(
          id: profile.id,
          displayName: profile.displayName,
          pinHash: profile.pinHash,
          kdfParams: KdfParams(
            algorithm: profile.kdfParams.algorithm,
            version: 999,
            m: profile.kdfParams.m,
            t: profile.kdfParams.t,
            p: profile.kdfParams.p,
            salt: profile.kdfParams.salt,
          ),
          failedAttempts: 5,
        ),
      ]);

      session.arriveAtKeypad();

      expect(
        await session.unlock(profile.id, '123456'),
        restingFor(const Duration(seconds: 30)),
      );
    });

    test('rests one Profile and not the other', () async {
      final mine = await aProfile('Michal', '123456');
      final theirs = await aProfile('Ola', '654321');

      await missTimes(mine.id, 5);
      session.arriveAtKeypad();

      expect(await session.unlock(theirs.id, '654321'), const Unlocked());
      expect(await attemptsOf(theirs.id), 0);
    });

    test('survives a restart of the app', () async {
      final profile = await aProfile();
      await missTimes(profile.id, 5);

      final started = ProfileSession(
        profiles: profiles,
        databases: databases,
        dataKeys: dataKeys,
      );
      started.arriveAtKeypad();

      expect(
        await started.unlock(profile.id, '123456'),
        restingFor(const Duration(seconds: 30)),
      );
    });

    test('tells the keypad what is left of it', () async {
      final profile = await aProfile();
      await missTimes(profile.id, 5);

      session.arriveAtKeypad();

      expect(
        await session.restLeftFor(profile.id),
        lessThanOrEqualTo(const Duration(seconds: 30)),
      );
      expect(
        await session.restLeftFor(profile.id),
        greaterThan(const Duration(seconds: 29)),
      );
    });

    test('leaves nothing of it when no mistake was made', () async {
      final profile = await aProfile();

      session.arriveAtKeypad();

      expect(await session.restLeftFor(profile.id), Duration.zero);
    });
  });

  group('locking', () {
    test('closes the file', () async {
      final profile = await aProfile();
      await session.unlock(profile.id, '123456');

      await session.lock();

      expect(await databases.state.first, DatabaseState.locked);
    });

    test('is safe while already locked', () async {
      await session.lock();

      expect(await databases.state.first, DatabaseState.locked);
    });
  });
}
