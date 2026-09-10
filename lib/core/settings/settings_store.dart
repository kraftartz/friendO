import 'package:drift/drift.dart' show Value;

import '../db/app_database.dart';
import '../db/database_session.dart';
import '../db/tables/settings.dart' show settingsRowId;
import 'profile_settings.dart';

/// Reads and writes the Profile's own options.
///
/// It lives below the feature layer because two things below it read these
/// values: `core/security/` reads the auto-lock wait, and `core/reminders/`
/// reads the switch and the hour. Neither may import a feature.
///
/// It goes through the same connection owner as everything else (ADR-0025), so
/// a write while locked throws `DatabaseLockedError` and a watch goes quiet.
/// There is no second rule for preferences.
class SettingsStore {
  /// Read and write through [databases].
  const SettingsStore(this.databases);

  /// The owner of the open connection.
  final DatabaseSession databases;

  /// The Profile's options now.
  ///
  /// A Profile that has never written one reads the defaults, which are the
  /// safe values.
  Future<ProfileSettings> read() async =>
      _readingOf(await _rowOf(databases.database));

  /// The Profile's options, and every change to them.
  ///
  /// It goes quiet on lock and runs again on unlock, because that is what
  /// [DatabaseSession.watch] does for every other query.
  Stream<ProfileSettings> watch() => databases.watch(
    (database) =>
        (database.select(database.settings)
              ..where((row) => row.id.equals(settingsRowId)))
            .watchSingleOrNull()
            .map(_readingOf),
  );

  /// Write [settings], replacing whatever the row held.
  Future<void> write(ProfileSettings settings) => databases.database
      .into(databases.database.settings)
      .insertOnConflictUpdate(
        SettingsCompanion(
          id: const Value(settingsRowId),
          remindersOn: Value(settings.remindersOn),
          reminderHour: Value(settings.reminderHour),
          autoLockSeconds: Value(settings.autoLockSeconds),
          screenshotsAllowed: Value(settings.screenshotsAllowed),
        ),
      );

  /// Read the options, change the values given, and write them back.
  Future<ProfileSettings> change({
    bool? remindersOn,
    int? reminderHour,
    int? autoLockSeconds,
    bool? screenshotsAllowed,
  }) async {
    final wanted = (await read()).changing(
      remindersOn: remindersOn,
      reminderHour: reminderHour,
      autoLockSeconds: autoLockSeconds,
      screenshotsAllowed: screenshotsAllowed,
    );
    await write(wanted);

    return wanted;
  }

  Future<SettingsRow?> _rowOf(AppDatabase database) => (database.select(
    database.settings,
  )..where((row) => row.id.equals(settingsRowId))).getSingleOrNull();

  ProfileSettings _readingOf(SettingsRow? row) => row == null
      ? const ProfileSettings()
      : ProfileSettings(
          remindersOn: row.remindersOn,
          reminderHour: row.reminderHour,
          autoLockSeconds: row.autoLockSeconds,
          screenshotsAllowed: row.screenshotsAllowed,
        );
}
