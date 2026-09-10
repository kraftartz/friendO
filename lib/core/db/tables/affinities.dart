import 'package:drift/drift.dart';

/// A label that groups Friends, such as Family.
///
/// It has its own table because the Directory filters by it, and two
/// spellings of one label would be a defect. [isSeed] marks the labels the
/// app ships.
@DataClassName('AffinityRow')
class Affinities extends Table {
  TextColumn get id => text()();

  TextColumn get label => text()();

  /// The Folded Text of [label], which search matches.
  TextColumn get labelFolded => text()();

  BoolColumn get isSeed => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
