import 'package:drift/drift.dart';

import 'friends.dart';

/// A fixed Civil Date that belongs to a Friend, such as a birthday.
///
/// A Milestone moves no Bead. The Dial draws Cadence alone.
@DataClassName('MilestoneRow')
class Milestones extends Table {
  TextColumn get id => text()();

  TextColumn get friendId => text().references(Friends, #id)();

  TextColumn get label => text()();

  IntColumn get onDate => integer()();

  BoolColumn get repeatsYearly => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
