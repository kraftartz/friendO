import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// Everything one Profile holds, as one encrypted SQLite file.
///
/// The schema starts empty. A version with no table is a valid starting point:
/// it is a file that exists, that is encrypted, and that a migration can carry
/// forward.
@DriftDatabase(tables: [])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
