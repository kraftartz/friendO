import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart' as sqlite;

import '../crypto/hex.dart';
import 'app_database.dart';

/// Where the one connection stands.
///
/// `opening` covers the hash, the unwrap, the open and the migration together,
/// which is the only visible wait in the app.
enum DatabaseState { locked, opening, open }

/// Thrown by every read and every write that arrives while no Profile is open.
///
/// A write cannot wait for the next unlock and it must not be dropped in
/// silence, so it fails with this and the caller says so.
class DatabaseLockedError implements Exception {
  const DatabaseLockedError();

  @override
  String toString() => 'DatabaseLockedError: no Profile is open';
}

/// The one owner of the connection to a Profile's encrypted file.
///
/// It opens one file at a time, publishes where it stands, and hands out the
/// database while that file is open. It keeps the key no longer than the file.
class DatabaseSession {
  DatabaseSession(this.directory);

  final Directory directory;

  final StreamController<DatabaseState> _changes =
      StreamController<DatabaseState>.broadcast();

  DatabaseState _state = DatabaseState.locked;

  AppDatabase? _database;

  /// Where the connection stands, from now on.
  ///
  /// A listener that arrives late reads where it stands first, so that it
  /// learns the Profile is open without waiting for the next change.
  Stream<DatabaseState> get state => Stream<DatabaseState>.multi((listener) {
    listener.add(_state);
    listener.addStream(_changes.stream);
  });

  AppDatabase get database {
    final open = _database;
    if (open == null) {
      throw const DatabaseLockedError();
    }

    return open;
  }

  File fileOf(String profileId) =>
      File(p.join(directory.path, 'friendo_$profileId.db'));

  /// Opens the Profile's file with [dataKey] and migrates it.
  ///
  /// It throws a [StateError] when a Profile is already open. Switching
  /// Profile closes the first file, and an open over an open one is a defect.
  Future<AppDatabase> open(String profileId, Uint8List dataKey) async {
    if (_database != null) {
      throw StateError('A Profile is already open.');
    }

    _publish(DatabaseState.opening);

    final database = AppDatabase(
      NativeDatabase(fileOf(profileId), setup: (raw) => _unlock(raw, dataKey)),
    );

    try {
      // The migration and a wrong key both show themselves on the first
      // query, so open means open only after one has run.
      await database.customSelect('select 1').getSingle();
    } on Object {
      await database.close();
      _publish(DatabaseState.locked);
      rethrow;
    }
    _database = database;
    _publish(DatabaseState.open);

    return database;
  }

  /// Closes the file, if one is open, and reports the Profile locked.
  ///
  /// It is safe while already locked, because a timer and a deliberate lock
  /// can both arrive. The key goes with the closed handle that held it.
  Future<void> close() async {
    final open = _database;
    _database = null;
    await open?.close();
    _publish(DatabaseState.locked);
  }

  /// Follows [query] while the Profile is open, and goes quiet while it is not.
  ///
  /// The returned stream stays alive across a lock, so one subscription lasts
  /// the life of a screen. It runs [query] again on every unlock, which is
  /// what makes the rows after a lock fresh rather than stale.
  Stream<T> watch<T>(Stream<T> Function(AppDatabase database) query) {
    StreamSubscription<DatabaseState>? whileOpen;
    StreamSubscription<T>? rows;
    late StreamController<T> found;

    Future<void> follow(DatabaseState state) async {
      await rows?.cancel();
      rows = null;
      if (state != DatabaseState.open) return;

      rows = query(database).listen(found.add, onError: found.addError);
    }

    found = StreamController<T>(
      onListen: () => whileOpen = state.listen(follow),
      onCancel: () async {
        await whileOpen?.cancel();
        await rows?.cancel();
      },
    );

    return found.stream;
  }

  void _publish(DatabaseState state) {
    _state = state;
    _changes.add(state);
  }

  void _unlock(sqlite.Database raw, Uint8List dataKey) {
    raw.execute('pragma cipher = chacha20');

    raw.execute("pragma key = \"x'${hex(dataKey)}'\"");

    raw.execute('pragma temp_store = 2');

    raw.execute('pragma plaintext_header_size = 0');
    raw.execute('pragma mc_legacy_wal = 0');
  }
}
