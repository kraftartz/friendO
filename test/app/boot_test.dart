import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/app/boot.dart';
import 'package:friendo/core/db/database_session.dart';
import 'package:friendo/core/profiles/data_key_store.dart';
import 'package:friendo/core/profiles/profile_creator.dart';
import 'package:friendo/core/profiles/profile_list.dart';
import 'package:hashlib/hashlib.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late ProfileList profiles;
  late DatabaseSession databases;
  late ProfileCreator creator;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_boot');
    profiles = ProfileList(directory);
    databases = DatabaseSession(directory);
    creator = ProfileCreator(
      profiles: profiles,
      databases: databases,
      dataKeys: const DataKeyStore(),
      security: Argon2Security.test,
    );
  });

  tearDown(() async {
    await databases.close();
    directory.deleteSync(recursive: true);
  });

  test('a phone with no Profile list starts First Run', () async {
    expect(await readFirstScreen(profiles), isA<StartFirstRun>());
  });

  test('a Profile list with no Profile starts First Run', () async {
    await profiles.write(const []);

    expect(await readFirstScreen(profiles), isA<StartFirstRun>());
  });

  test('one Profile asks for that Profile PIN', () async {
    final profile = await creator.createProfile('Michal', '123456');

    final screen = await readFirstScreen(profiles);

    expect(screen, isA<AskForPin>());
    expect((screen as AskForPin).profile.id, profile.id);
  });

  test('two Profiles offer the picker', () async {
    await creator.createProfile('Michal', '123456');
    await creator.createProfile('Ola', '654321');

    final screen = await readFirstScreen(profiles);

    expect(screen, isA<PickProfile>());
    expect((screen as PickProfile).profiles, hasLength(2));
  });

  group('a damaged Profile list', () {
    test('stops, and never reports First Run', () async {
      profiles.file.writeAsStringSync('{');

      final screen = await readFirstScreen(profiles);

      expect(screen, isA<ListDamaged>());
      expect(screen, isNot(isA<StartFirstRun>()));
    });

    test('stops when it holds a version this app does not know', () async {
      profiles.file.writeAsStringSync('{"version": 99, "profiles": []}');

      expect(await readFirstScreen(profiles), isA<ListDamaged>());
    });

    test('names the file it could not read', () async {
      profiles.file.writeAsStringSync('{');

      final screen = await readFirstScreen(profiles) as ListDamaged;

      expect(screen.path, profiles.file.path);
      expect(screen.reason, isNotEmpty);
    });
  });

  group('the read itself', () {
    test('opens no encrypted file', () async {
      await creator.createProfile('Michal', '123456');
      databases.fileOf((await profiles.read()).single.id).deleteSync();

      expect(await readFirstScreen(profiles), isA<AskForPin>());
      expect(await databases.state.first, DatabaseState.locked);
    });

    test('asks the phone for no key', () async {
      final profile = await creator.createProfile('Michal', '123456');
      await const FlutterSecureStorage().delete(key: dataKeyNameOf(profile.id));

      expect(await readFirstScreen(profiles), isA<AskForPin>());
    });
  });
}
