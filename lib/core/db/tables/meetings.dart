import 'package:drift/drift.dart';

import 'friends.dart';

/// The Meetings a Friend and the User had.
///
/// [happenedOn] is a Civil Date, held as the count of days from 1970-01-01.
/// It is the only field the Dial reads. [happenedAtMinute] is the optional
/// time of day, in minutes from midnight, and it is shown and never drawn.
@DataClassName('MeetingRow')
class Meetings extends Table {
  TextColumn get id => text()();

  TextColumn get friendId => text().references(Friends, #id)();

  IntColumn get happenedOn => integer()();

  IntColumn get happenedAtMinute => integer().nullable()();

  /// When the row was first written, in milliseconds from the epoch.
  ///
  /// It breaks a tie between two Meetings on one Civil Date, so a whole save
  /// carries the old instant forward rather than stamping a new one. See
  /// ADR-0021.
  IntColumn get createdAt => integer()();

  TextColumn get place => text().nullable()();

  /// How long the Meeting was, in minutes.
  IntColumn get lengthInMinutes => integer().nullable()();

  /// How the Meeting felt, in the User's own words.
  TextColumn get feeling => text().nullable()();

  TextColumn get recap => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
