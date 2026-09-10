import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/db/app_database.dart';
import 'package:friendo/core/db/database_session.dart';

Uint8List _key(int fill) => Uint8List.fromList(List.filled(32, fill));

const _tables = [
  'friends',
  'meetings',
  'notes',
  'affinities',
  'friend_affinities',
  'facts',
  'milestones',
];

void main() {
  late Directory directory;
  late DatabaseSession session;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('friendo_schema');
    session = DatabaseSession(directory);
  });

  tearDown(() async {
    await session.close();
    directory.deleteSync(recursive: true);
  });

  Future<List<String>> tablesInTheFile() async {
    final rows = await session.database
        .customSelect(
          'select name from sqlite_master '
          "where type = 'table' order by name",
        )
        .get();

    return rows.map((row) => row.read<String>('name')).toList();
  }

  Future<String> pragma(String name) async {
    final row = await session.database.customSelect('pragma $name').getSingle();

    return row.data.values.single.toString();
  }

  /// Takes the file back to the schema First Run wrote, which held no table.
  Future<void> takeItBackToVersionOne() async {
    for (final table in _tables) {
      await session.database.customStatement('drop table $table');
    }
    await session.database.customStatement('pragma user_version = 1');
  }

  test('a schema step that will not run says which failure it was', () async {
    await session.open('9f2c', _key(1));
    await takeItBackToVersionOne();
    // An object of another kind, under the name a table needs.
    await session.database.customStatement('create table junk (a)');
    await session.database.customStatement('create index friends on junk (a)');
    await session.close();

    await expectLater(
      session.open('9f2c', _key(1)),
      throwsA(isA<MigrationFailed>()),
    );
  });

  test('a new file holds every table', () async {
    await session.open('9f2c', _key(1));

    expect(await tablesInTheFile(), containsAll(_tables));
  });

  test('a new file stands at the current schema version', () async {
    final database = await session.open('9f2c', _key(1));

    expect(int.parse(await pragma('user_version')), database.schemaVersion);
  });

  test('a child row cannot name a Friend that is not there', () async {
    final database = await session.open('a', _key(1));

    // The repository clears children itself, so this constraint is not the
    // mechanism. It is the guard for the day a second door is written.
    expect(
      database.customStatement(
        'insert into meetings (id, friend_id, happened_on, created_at) '
        "values ('m1', 'nobody', 1, 1)",
      ),
      throwsA(
        isA<Object>().having(
          (error) => error.toString(),
          'toString',
          contains('FOREIGN KEY'),
        ),
      ),
    );
  });

  test('the pragma that makes a foreign key bite is on', () async {
    final database = await session.open('a', _key(1));
    final row = await database.customSelect('pragma foreign_keys').getSingle();

    expect(row.data.values.single, 1);
  });

  test('the Folded Text sits beside the text it folds', () async {
    await session.open('9f2c', _key(1));

    final columns = await session.database
        .customSelect('pragma table_info(friends)')
        .get();

    expect(
      columns.map((row) => row.read<String>('name')),
      containsAll(['name', 'name_folded']),
    );
  });

  test('no column holds a lump of bytes', () async {
    await session.open('9f2c', _key(1));

    for (final table in _tables) {
      final columns = await session.database
          .customSelect('pragma table_info($table)')
          .get();

      expect(
        columns.map((row) => row.read<String>('type')),
        isNot(contains('BLOB')),
        reason: '$table holds a BLOB column',
      );
    }
  });

  group('a file made before the tables existed', () {
    setUp(() async {
      await session.open('9f2c', _key(1));
      await takeItBackToVersionOne();
      await session.close();
      await session.open('9f2c', _key(1));
    });

    test('holds every table after it opens again', () async {
      expect(await tablesInTheFile(), containsAll(_tables));
    });

    test('stands at the current schema version', () async {
      expect(
        int.parse(await pragma('user_version')),
        session.database.schemaVersion,
      );
    });

    test('is still encrypted the way it was', () async {
      expect(await pragma('cipher'), 'chacha20');
      expect(await pragma('temp_store'), isNot('1'));
      expect(await pragma('plaintext_header_size'), '0');
      expect(await pragma('mc_legacy_wal'), '0');
    });
  });
}
