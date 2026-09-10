import 'package:drift/drift.dart';

/// The Friends this Profile keeps.
///
/// [nameFolded] is the Folded Text that search matches. It sits beside the
/// name it folds, and nothing shows it. See ADR-0033.
@DataClassName('FriendRow')
class Friends extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get nameFolded => text()();

  /// The wanted Cadence, in whole days.
  IntColumn get cadenceDays => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
