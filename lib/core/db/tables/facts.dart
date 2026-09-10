import 'package:drift/drift.dart';

import 'friends.dart';

/// Something about a Friend that changes rarely, such as the city they live in.
///
/// The User writes both the label and the value, and there is no table of
/// labels: a label is text to show, and not a thing to filter by.
@DataClassName('FactRow')
class Facts extends Table {
  TextColumn get id => text()();

  TextColumn get friendId => text().references(Friends, #id)();

  TextColumn get label => text()();

  TextColumn get value => text()();

  /// Where the Fact sits in the Friend's own order, from zero.
  ///
  /// The Friend holds the Facts in order and the aggregate carries no such
  /// number, so this column exists to give that order back on the next read.
  IntColumn get ordinal => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
