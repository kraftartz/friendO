import 'package:drift/drift.dart';

import 'friends.dart';

/// The writing about a Friend: a Topic, an Update, or a Note.
///
/// [label] tells the three apart and changes nothing else. The app never
/// clears one of these rows by itself. See ADR-0017.
@DataClassName('NoteRow')
class Notes extends Table {
  TextColumn get id => text()();

  TextColumn get friendId => text().references(Friends, #id)();

  TextColumn get label => text()();

  TextColumn get body => text()();

  /// The Folded Text of [body], which search matches.
  TextColumn get bodyFolded => text()();

  /// The Civil Date the row was written on.
  IntColumn get writtenOn => integer()();

  /// The Civil Date the User marked it done on. Null while it is open.
  IntColumn get resolvedOn => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
