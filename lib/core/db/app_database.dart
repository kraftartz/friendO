import 'package:drift/drift.dart';

import 'tables/affinities.dart';
import 'tables/facts.dart';
import 'tables/friend_affinities.dart';
import 'tables/friends.dart';
import 'tables/meetings.dart';
import 'tables/milestones.dart';
import 'tables/notes.dart';
import 'tables/settings.dart';

part 'app_database.g.dart';

/// Thrown when the stored data cannot be brought to the current schema.
///
/// It tells a failed schema step apart from a file that will not open at all,
/// which the User is told about in different words.
class MigrationFailed implements Exception {
  const MigrationFailed(this.cause);

  final Object cause;

  @override
  String toString() => 'MigrationFailed: $cause';
}

@DriftDatabase(
  tables: [
    Friends,
    Meetings,
    Notes,
    Affinities,
    FriendAffinities,
    Facts,
    Milestones,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => _report(migrator.createAll()),
    onUpgrade: (migrator, from, to) => _report(_forward(migrator, from)),
    // Not beside the sqlite3mc pragmas in DatabaseSession. Those run in the
    // setup callback, which fires before a migration, and a migration that
    // moves rows about is the one place the constraints get in the way.
    // SQLite defaults this off on every connection, so it is set on each open.
    beforeOpen: (details) => customStatement('pragma foreign_keys = on'),
  );

  /// Brings a file at version [from] to the current schema.
  ///
  /// Version 1 held no table at all, because it was written before the Friend
  /// had one. Every table is new to such a file.
  ///
  /// Version 2 carries the foreign keys, and a file already at version 2 does
  /// not. SQLite cannot add a constraint to a table that exists, and version 2
  /// has never left a development machine, so no step is written for it. Such
  /// a file is deleted with the app rather than migrated.
  Future<void> _forward(Migrator migrator, int from) async {
    if (from < 2) await migrator.createAll();
    if (from == 2) await migrator.createTable(settings);
  }

  Future<void> _report(Future<void> work) async {
    try {
      await work;
    } on Object catch (error) {
      throw MigrationFailed(error);
    }
  }
}
