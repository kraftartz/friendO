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
    late DatabaseSession open;

    setUp(() async {
      await session.open('9f2c', _key(1));
      open = session;
    });

    Future<String> pragma(String name) async {
      final row = await open.database.customSelect('pragma $name').getSingle();

      return row.data.values.single.toString();
    }

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
  });
}
