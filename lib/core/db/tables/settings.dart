import 'package:drift/drift.dart';

/// The Profile's own options, in the encrypted database.
///
/// One row. The database file belongs to one Profile (ADR-0007), so a second
/// row would name a Profile this file has no other reason to know about.
///
/// A setting the lock screen must read before anything is unlocked does not
/// belong here, because at that moment no database is open. See ADR-0036.
@DataClassName('SettingsRow')
class Settings extends Table {
  /// The one row's key. It holds [settingsRowId] and nothing else.
  TextColumn get id => text()();

  /// Whether the User has turned reminders on. Off in a new Profile, per
  /// ADR-0012.
  BoolColumn get remindersOn => boolean().withDefault(const Constant(false))();

  /// The hour of the Due Date a reminder fires at, from 0 to 23.
  IntColumn get reminderHour => integer().withDefault(const Constant(9))();

  /// How long the app waits before it locks itself, in seconds. ADR-0011 set
  /// the default.
  IntColumn get autoLockSeconds => integer().withDefault(const Constant(60))();

  /// Whether the User has allowed their own screenshots. It defaults to
  /// secure.
  BoolColumn get screenshotsAllowed =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// The key on the one settings row.
const settingsRowId = 'profile';
