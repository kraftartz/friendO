import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/crypto/pin_hash.dart';
import 'package:friendo/core/db/database_session.dart';
import 'package:friendo/core/profiles/data_key_store.dart';
import 'package:friendo/core/profiles/profile_creator.dart';
import 'package:friendo/core/profiles/profile_list.dart';
import 'package:hashlib/hashlib.dart';
import 'package:path/path.dart' as p;

/// A session that cannot make a file, so the sequence stops at step 4.
class _UncreatableDatabase extends DatabaseSession {
  _UncreatableDatabase(super.directory);

  @override
  Future<Never> open(String profileId, Uint8List dataKey) =>
      Future.error(const FileSystemException('no room on the disk'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late ProfileList profiles;
  late DatabaseSession databases;
  late DataKeyStore dataKeys;
  late ProfileCreator creator;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_creator');
    profiles = ProfileList(directory);
    databases = DatabaseSession(directory);
    dataKeys = const DataKeyStore();
    creator = ProfileCreator(
      profiles: profiles,
      databases: databases,
      dataKeys: dataKeys,
      security: Argon2Security.test,
    );
  });

  tearDown(() async {
    await databases.close();
    directory.deleteSync(recursive: true);
  });

  group('the Profile it writes', () {
    test('is the only row in a list at version 1', () async {
      await creator.createProfile('Michal', '123456');

      final json =
          jsonDecode(
                File(
                  p.join(directory.path, 'profiles.json'),
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;

      expect(json['version'], 1);
      expect(json['profiles'], hasLength(1));
    });

    test('carries the trimmed name', () async {
      await creator.createProfile('  Michal  ', '123456');

      expect((await profiles.read()).single.displayName, 'Michal');
    });

    test('starts with no failed attempt', () async {
      await creator.createProfile('Michal', '123456');

      expect((await profiles.read()).single.failedAttempts, 0);
    });

    test('carries an id of 32 hexadecimal characters', () async {
      final profile = await creator.createProfile('Michal', '123456');

      expect(profile.id, matches(RegExp(r'^[0-9a-f]{32}$')));
    });

    test('refuses a name that is empty after trimming', () async {
      await expectLater(
        creator.createProfile('   ', '123456'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('the PIN it hashes', () {
    test('accepts the PIN that made the digest', () async {
      await creator.createProfile('Michal', '123456');
      final profile = (await profiles.read()).single;

      expect(hashPin('123456', profile.kdfParams), profile.pinHash);
    });

    test('rejects another PIN', () async {
      await creator.createProfile('Michal', '123456');
      final profile = (await profiles.read()).single;

      expect(hashPin('654321', profile.kdfParams), isNot(profile.pinHash));
    });

    test('carries the algorithm, the cost numbers and a salt', () async {
      await creator.createProfile('Michal', '123456');
      final params = (await profiles.read()).single.kdfParams;

      expect(params.algorithm, 'argon2id');
      expect(params.version, 19);
      expect(params.m, Argon2Security.test.m);
      expect(params.t, Argon2Security.test.t);
      expect(params.p, Argon2Security.test.p);
      expect(params.salt, hasLength(16));
    });
  });

  group('a second Profile in the same directory', () {
    test('holds its own id, salt and digest, under the same PIN', () async {
      await creator.createProfile('Michal', '123456');
      await creator.createProfile('Ada', '123456');

      final rows = await profiles.read();
      expect(rows, hasLength(2));
      expect(rows.first.id, isNot(rows.last.id));
      expect(rows.first.kdfParams.salt, isNot(rows.last.kdfParams.salt));
      expect(rows.first.pinHash, isNot(rows.last.pinHash));
    });

    test('holds its own data key', () async {
      final one = await creator.createProfile('Michal', '123456');
      final two = await creator.createProfile('Ada', '123456');

      expect(await dataKeys.read(one.id), isNot(await dataKeys.read(two.id)));
    });

    test('leaves the first Profile in the list', () async {
      final one = await creator.createProfile('Michal', '123456');
      await creator.createProfile('Ada', '654321');

      expect((await profiles.read()).first.id, one.id);
    });
  });

  group('the data key it mints', () {
    test('is 32 bytes, under the name of its Profile', () async {
      final profile = await creator.createProfile('Michal', '123456');

      expect(await dataKeys.read(profile.id), hasLength(32));
    });
  });

  group('the file it creates', () {
    test('exists and is not a readable SQLite file', () async {
      final profile = await creator.createProfile('Michal', '123456');
      final file = databases.fileOf(profile.id);

      expect(file.existsSync(), isTrue);
      expect(
        String.fromCharCodes(file.readAsBytesSync().take(15)),
        isNot('SQLite format 3'),
      );
    });

    test('opens with the key that was stored for it', () async {
      final profile = await creator.createProfile('Michal', '123456');

      final key = await dataKeys.read(profile.id);

      await databases.open(profile.id, key!);
      expect(databases.database, isNotNull);
    });

    test('refuses any other key', () async {
      final profile = await creator.createProfile('Michal', '123456');

      await expectLater(
        databases.open(profile.id, Uint8List(32)),
        throwsA(isA<Object>()),
      );
    });

    test('is closed when the Profile is made', () async {
      await creator.createProfile('Michal', '123456');

      expect(() => databases.database, throwsA(isA<StateError>()));
    });
  });

  group('a failure before the commit', () {
    test('leaves no row in the list', () async {
      final failing = ProfileCreator(
        profiles: profiles,
        databases: _UncreatableDatabase(directory),
        dataKeys: dataKeys,
        security: Argon2Security.test,
      );

      await expectLater(
        failing.createProfile('Michal', '123456'),
        throwsA(isA<FileSystemException>()),
      );
      expect(await profiles.read(), isEmpty);
    });

    test('leaves the Profiles that were already there', () async {
      final made = await creator.createProfile('Michal', '123456');
      final failing = ProfileCreator(
        profiles: profiles,
        databases: _UncreatableDatabase(directory),
        dataKeys: dataKeys,
        security: Argon2Security.test,
      );

      await expectLater(
        failing.createProfile('Ada', '654321'),
        throwsA(isA<FileSystemException>()),
      );
      expect((await profiles.read()).single.id, made.id);
    });
  });
}
