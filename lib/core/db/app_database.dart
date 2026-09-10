import 'package:drift/drift.dart';

import 'tables.dart';

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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => _report(migrator.createAll()),
    onUpgrade: (migrator, from, to) => _report(_forward(migrator, from)),
  );

  /// Brings a file at version [from] to the current schema.
  ///
  /// Version 1 held no table at all, because it was written before the Friend
  /// had one. Every table is new to such a file.
  Future<void> _forward(Migrator migrator, int from) async {
    if (from < 2) await migrator.createAll();
  }

  Future<void> _report(Future<void> work) async {
    try {
      await work;
    } on Object catch (error) {
      throw MigrationFailed(error);
    }
  }
}
