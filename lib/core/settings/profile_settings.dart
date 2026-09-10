import 'package:equatable/equatable.dart';

/// The auto-lock timers the app offers.
///
/// A short list rather than a free number, because the choice is a habit and
/// not a measurement. ADR-0011 set the default and asked for the setting.
const autoLockChoices = <Duration>[
  Duration(seconds: 15),
  Duration(seconds: 60),
  Duration(minutes: 5),
  Duration(minutes: 15),
];

/// The Profile's own options, as they are read out of the database.
///
/// Every value here is read only while the Profile is open, which is what puts
/// it in the encrypted store rather than in `profiles.json`. See ADR-0036.
///
/// The defaults are the safe ones: reminders off, screenshots blocked, and the
/// 60 seconds ADR-0011 set.
final class ProfileSettings extends Equatable {
  /// Hold the four values.
  const ProfileSettings({
    this.remindersOn = false,
    this.reminderHour = 9,
    this.autoLockSeconds = 60,
    this.screenshotsAllowed = false,
  });

  /// Whether reminders are on.
  final bool remindersOn;

  /// The hour of the Due Date a reminder fires at, from 0 to 23.
  final int reminderHour;

  /// How long the app waits before it locks itself, in seconds.
  final int autoLockSeconds;

  /// Whether the User has allowed their own screenshots.
  final bool screenshotsAllowed;

  /// The auto-lock wait as a length of time.
  Duration get autoLock => Duration(seconds: autoLockSeconds);

  /// Copy the settings, changing the values given.
  ProfileSettings changing({
    bool? remindersOn,
    int? reminderHour,
    int? autoLockSeconds,
    bool? screenshotsAllowed,
  }) => ProfileSettings(
    remindersOn: remindersOn ?? this.remindersOn,
    reminderHour: reminderHour ?? this.reminderHour,
    autoLockSeconds: autoLockSeconds ?? this.autoLockSeconds,
    screenshotsAllowed: screenshotsAllowed ?? this.screenshotsAllowed,
  );

  @override
  List<Object?> get props => [
    remindersOn,
    reminderHour,
    autoLockSeconds,
    screenshotsAllowed,
  ];
}
