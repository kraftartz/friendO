import 'dart:typed_data';

import 'package:friendo/core/db/app_database.dart';
import 'package:friendo/core/db/database_session.dart';

/// A connection owner whose file opens and whose schema never moves.
class UnmigratableDatabase extends DatabaseSession {
  UnmigratableDatabase(super.directory);

  @override
  Future<Never> open(String profileId, Uint8List dataKey) =>
      Future.error(const MigrationFailed('the step would not run'));
}
