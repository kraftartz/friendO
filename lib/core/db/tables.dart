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

/// The Meetings a Friend and the User had.
///
/// [happenedOn] is a Civil Date, held as the count of days from 1970-01-01.
/// It is the only field the Dial reads. [happenedAtMinute] is the optional
/// time of day, in minutes from midnight, and it is shown and never drawn.
@DataClassName('MeetingRow')
class Meetings extends Table {
  TextColumn get id => text()();

  TextColumn get friendId => text()();

  IntColumn get happenedOn => integer()();

  IntColumn get happenedAtMinute => integer().nullable()();

  /// When the row was written, in milliseconds from the epoch.
  IntColumn get createdAt => integer()();

  TextColumn get place => text().nullable()();

  /// How long the Meeting was, in minutes.
  IntColumn get minutes => integer().nullable()();

  /// How the Meeting felt, in the User's own words.
  TextColumn get feeling => text().nullable()();

  TextColumn get recap => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The writing about a Friend: a Topic, an Update, or a Note.
///
/// [label] tells the three apart and changes nothing else. The app never
/// clears one of these rows by itself. See ADR-0017.
@DataClassName('NoteRow')
class Notes extends Table {
  TextColumn get id => text()();

  TextColumn get friendId => text()();

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

/// Which Affinities a Friend carries.
@DataClassName('FriendAffinityRow')
class FriendAffinities extends Table {
  TextColumn get friendId => text()();

  TextColumn get affinityId => text()();

  @override
  Set<Column> get primaryKey => {friendId, affinityId};
}

/// Something about a Friend that changes rarely, such as the city they live in.
///
/// The User writes both the label and the value, and there is no table of
/// labels: a label is text to show, and not a thing to filter by.
@DataClassName('FactRow')
class Facts extends Table {
  TextColumn get id => text()();

  TextColumn get friendId => text()();

  TextColumn get label => text()();

  TextColumn get value => text()();

  /// Where the Fact sits in the Friend's own order, from zero.
  IntColumn get position => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// A fixed Civil Date that belongs to a Friend, such as a birthday.
///
/// A Milestone moves no Bead. The Dial draws Cadence alone.
@DataClassName('MilestoneRow')
class Milestones extends Table {
  TextColumn get id => text()();

  TextColumn get friendId => text()();

  TextColumn get label => text()();

  IntColumn get onDate => integer()();

  BoolColumn get repeatsYearly => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}
