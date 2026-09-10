import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/db/database_session.dart';
import 'package:friendo/core/profiles/data_key_store.dart';
import 'package:friendo/core/profiles/profile_creator.dart';
import 'package:friendo/core/profiles/profile_list.dart';
import 'package:friendo/core/profiles/profile_session.dart';
import 'package:hashlib/hashlib.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory directory;
  late DatabaseSession databases;
  late ProfileSession session;
  late String profileId;

  /// The table stands in for the schema friendO-fff.8 brings. The contract
  /// under test is the lock, and the lock needs a table and not the schema.
  Stream<List<String>> namesInOrder() => databases.watch(
    (database) => database
        .customSelect('select name from friends order by name')
        .watch()
        .map((rows) => rows.map((row) => row.read<String>('name')).toList()),
  );

  Future<void> add(String name) => databases.database.customStatement(
    'insert into friends (name) values (?)',
    [name],
  );

  setUp(() async {
    FlutterSecureStorage.setMockInitialValues({});
    directory = Directory.systemTemp.createTempSync('friendo_watch');
    databases = DatabaseSession(directory);
    final profiles = ProfileList(directory);
    session = ProfileSession(
      profiles: profiles,
      databases: databases,
      dataKeys: const DataKeyStore(),
    );
    profileId = (await ProfileCreator(
      profiles: profiles,
      databases: databases,
      dataKeys: const DataKeyStore(),
      security: Argon2Security.test,
    ).createProfile('Michal', '123456')).id;
    await session.unlock(profileId, '123456');
    await databases.database.customStatement(
      'create table friends (name text)',
    );
  });

  tearDown(() async {
    await databases.close();
    directory.deleteSync(recursive: true);
  });

  test('a read while locked throws one named failure', () async {
    await session.lock();

    expect(() => databases.database, throwsA(isA<DatabaseLockedError>()));
  });

  test('a write while locked throws one named failure', () async {
    await session.lock();

    expect(() => add('Ola'), throwsA(isA<DatabaseLockedError>()));
  });

  test('a watch reads the rows that are there when it starts', () async {
    await add('Ola');

    final seen = <List<String>>[];
    final watching = namesInOrder().listen(seen.add);
    await pumpEventQueue();

    expect(seen, [
      ['Ola'],
    ]);
    await watching.cancel();
  });

  test('a watch goes quiet on lock and stays alive', () async {
    final seen = <List<String>>[];
    final watching = namesInOrder().listen(seen.add);
    await pumpEventQueue();

    await session.lock();
    await pumpEventQueue();

    expect(seen, [<String>[]]);
    expect(watching.isPaused, isFalse);
    await watching.cancel();
  });

  test('a row written while locked appears after the unlock', () async {
    final seen = <List<String>>[];
    final watching = namesInOrder().listen(seen.add);
    await pumpEventQueue();
    await session.lock();

    final other = DatabaseSession(directory);
    await other.open(profileId, (await const DataKeyStore().read(profileId))!);
    await other.database.customStatement(
      "insert into friends (name) values ('Ola')",
    );
    await other.close();

    await session.unlock(profileId, '123456');
    await pumpEventQueue();

    expect(seen.last, ['Ola']);
    await watching.cancel();
  });
}
