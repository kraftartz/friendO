import 'package:drift/drift.dart';

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

@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (migrator) => _report(migrator.createAll()));

  Future<void> _report(Future<void> work) async {
    try {
      await work;
    } on Object catch (error) {
      throw MigrationFailed(error);
    }
  }
}
