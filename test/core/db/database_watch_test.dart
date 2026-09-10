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

  /// A table of its own, made inside the open file.
  ///
  /// The contract under test is the lock, which needs a table and not the
  /// schema. A table the app never declares keeps the two apart.
  Stream<List<String>> namesInOrder() => databases.watch(
    (database) => database
        .customSelect('select name from scratch order by name')
        .watch()
        .map((rows) => rows.map((row) => row.read<String>('name')).toList()),
  );

  Future<void> add(String name) => databases.database.customStatement(
    'insert into scratch (name) values (?)',
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
      'create table scratch (name text)',
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

  test('a lock that lands while a watch starts is not an error', () async {
    await add('Ola');

    final seen = <List<String>>[];
    final errors = <Object>[];
    final watching = namesInOrder().listen(seen.add, onError: errors.add);

    // No pumpEventQueue between the two. The lock lands while follow() is
    // still suspended on its first await, which is the window every other
    // test in this file closes before it locks.
    await session.lock();
    await pumpEventQueue();

    // The escape this guards against does not arrive on the stream. It goes
    // to the zone, where the test harness catches it and fails the test.
    expect(errors, isEmpty);

    // The stream is still worth having: the next unlock runs the query again.
    await session.unlock(profileId, '123456');
    await pumpEventQueue();

    expect(seen.last, ['Ola']);
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
      "insert into scratch (name) values ('Ola')",
    );
    await other.close();

    await session.unlock(profileId, '123456');
    await pumpEventQueue();

    expect(seen.last, ['Ola']);
    await watching.cancel();
  });
}
