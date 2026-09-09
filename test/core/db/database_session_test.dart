import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/db/database_session.dart';
import 'package:path/path.dart' as p;

Uint8List _key(int fill) => Uint8List.fromList(List.filled(32, fill));

void main() {
  late Directory directory;
  late DatabaseSession session;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('friendo_db');
    session = DatabaseSession(directory);
  });

  tearDown(() async {
    await session.close();
    directory.deleteSync(recursive: true);
  });

  test('names the file after the Profile', () {
    expect(p.basename(session.fileOf('9f2c').path), 'friendo_9f2c.db');
  });

  test('creates the file', () async {
    await session.open('9f2c', _key(1));

    expect(session.fileOf('9f2c').existsSync(), isTrue);
  });

  test('encrypts the file it creates', () async {
    await session.open('9f2c', _key(1));
    await session.close();

    final header = session.fileOf('9f2c').readAsBytesSync().take(15).toList();

    expect(String.fromCharCodes(header), isNot('SQLite format 3'));
  });

  test('opens again with the same key', () async {
    await session.open('9f2c', _key(1));
    await session.close();

    await session.open('9f2c', _key(1));

    expect(session.database, isNotNull);
  });

  test('refuses to open with another key', () async {
    await session.open('9f2c', _key(1));
    await session.close();

    await expectLater(session.open('9f2c', _key(2)), throwsA(isA<Object>()));
  });

  test('stands at the current schema version', () async {
    final database = await session.open('9f2c', _key(1));

    expect(database.schemaVersion, greaterThanOrEqualTo(1));
  });

  group('the pragmas that keep the whole file private', () {
    Future<String> pragma(String name) async {
      final row = await session.database
          .customSelect('pragma $name')
          .getSingle();

      return row.data.values.single.toString();
    }

    void theyHold() {
      test('encrypts with chacha20', () async {
        expect(await pragma('cipher'), 'chacha20');
      });

      test('never spills a sort to a file', () async {
        expect(await pragma('temp_store'), isNot('1'));
      });

      test('leaves no readable header', () async {
        expect(await pragma('plaintext_header_size'), '0');
      });

      test('encrypts the write-ahead log', () async {
        expect(await pragma('mc_legacy_wal'), '0');
      });
    }

    group('on a file it has just created', () {
      setUp(() => session.open('9f2c', _key(1)));

      theyHold();
    });

    group('on a file it opens again', () {
      setUp(() async {
        await session.open('9f2c', _key(1));
        await session.close();
        await session.open('9f2c', _key(1));
      });

      theyHold();
    });
  });

  group('the state it publishes', () {
    test('starts locked', () async {
      expect(await session.state.first, DatabaseState.locked);
    });

    test('passes through opening on the way to open', () async {
      final seen = expectLater(
        session.state,
        emitsInOrder([
          DatabaseState.locked,
          DatabaseState.opening,
          DatabaseState.open,
        ]),
      );

      await session.open('9f2c', _key(1));

      await seen;
    });

    test('replays where it stands to a listener that arrives later', () async {
      await session.open('9f2c', _key(1));

      expect(await session.state.first, DatabaseState.open);
    });

    test('becomes locked again when the Profile closes', () async {
      await session.open('9f2c', _key(1));
      await session.close();

      expect(await session.state.first, DatabaseState.locked);
    });

    test('stays locked when the file will not open', () async {
      await session.open('9f2c', _key(1));
      await session.close();

      await expectLater(session.open('9f2c', _key(2)), throwsA(isA<Object>()));

      expect(await session.state.first, DatabaseState.locked);
    });
  });

  group('what it refuses', () {
    test('gives no database while the Profile is locked', () {
      expect(() => session.database, throwsA(isA<DatabaseLockedError>()));
    });

    test('gives no database after the Profile closes', () async {
      await session.open('9f2c', _key(1));
      await session.close();

      expect(() => session.database, throwsA(isA<DatabaseLockedError>()));
    });

    test('refuses to open a second Profile over an open one', () async {
      await session.open('9f2c', _key(1));

      await expectLater(
        session.open('4b71', _key(2)),
        throwsA(isA<StateError>()),
      );
    });

    test('closes twice without complaint', () async {
      await session.open('9f2c', _key(1));

      await session.close();
      await session.close();

      expect(await session.state.first, DatabaseState.locked);
    });

    test('closes while locked without complaint', () async {
      await session.close();

      expect(await session.state.first, DatabaseState.locked);
    });
  });
}
