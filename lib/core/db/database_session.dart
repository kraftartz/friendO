import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import 'app_database.dart';

/// The one owner of the open connection.
///
/// Nothing else opens or closes a database file. A second owner would keep a
/// dead handle after a close, and the key would stay in it.
class DatabaseSession {
  DatabaseSession(this.directory);

  /// The directory that holds the files. It arrives as an argument, so this
  /// code asks the phone for no path of its own.
  final Directory directory;

  AppDatabase? _database;

  /// The open database.
  ///
  /// Throws [StateError] while no Profile is open, because a query with no key
  /// behind it has no answer.
  AppDatabase get database {
    final open = _database;
    if (open == null) {
      throw StateError('No Profile is open.');
    }

    return open;
  }

  /// The file that holds the Profile with this id.
  File fileOf(String profileId) =>
      File(p.join(directory.path, 'friendo_$profileId.db'));

  /// Opens the file of [profileId] with [dataKey], and creates it when it is
  /// absent.
  ///
  /// It returns a database that stands at the current schema version, because
  /// it runs the migration before it returns.
  ///
  /// Throws when [dataKey] does not open the file. An encrypted file read with
  /// the wrong key is not a database.
  Future<AppDatabase> open(String profileId, Uint8List dataKey) async {
    await close();

    final database = AppDatabase(
      NativeDatabase(fileOf(profileId), setup: (raw) => _unlock(raw, dataKey)),
    );

    try {
      await database.customSelect('select 1').getSingle();
    } on Object {
      await database.close();
      rethrow;
    }
    _database = database;

    return database;
  }

  /// Closes the open database, and does nothing when none is open.
  ///
  /// The key leaves the connection here. That is what makes a lock a lock.
  Future<void> close() async {
    final open = _database;
    _database = null;
    await open?.close();
  }

  /// Hands the key to the engine, and holds the file to the settings that keep
  /// all of it private.
  ///
  /// The key comes first. A statement before it reads a file the engine cannot
  /// decrypt yet.
  void _unlock(sqlite.Database raw, Uint8List dataKey) {
    raw.execute("pragma key = \"x'${_hex(dataKey)}'\"");

    // A sort that spills to a file writes private text in the clear, because
    // sqlite3mc encrypts the database, the journal and the write-ahead log,
    // and not the temporary files.
    raw.execute('pragma temp_store = 2');

    // No part of the file is readable, and the write-ahead log is encrypted
    // too. Both are the defaults, and both are cheap to state.
    raw.execute('pragma plaintext_header_size = 0');
    raw.execute('pragma mc_legacy_wal = 0');
  }

  String _hex(Uint8List bytes) =>
      bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
