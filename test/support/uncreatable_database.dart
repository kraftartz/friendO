import 'dart:io';
import 'dart:typed_data';

import 'package:friendo/core/db/database_session.dart';

/// A session that cannot make a file.
///
/// It stops the creation of a Profile at the step that creates the encrypted
/// file, which is the last step before the row is written.
class UncreatableDatabase extends DatabaseSession {
  UncreatableDatabase(super.directory);

  @override
  Future<Never> open(String profileId, Uint8List dataKey) =>
      Future.error(const FileSystemException('no room on the disk'));
}
