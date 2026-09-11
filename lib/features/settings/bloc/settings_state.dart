import 'package:equatable/equatable.dart';
import 'package:friendo/core/profiles/profile.dart' show Profile;
import 'package:friendo/core/settings/profile_settings.dart'
    show ProfileSettings;

/// What the User is told when the permission is not there.
const permissionRefusedWords =
    'The phone is not allowing notifications, so reminders stay off. Turn '
    "them on in the phone's own settings, then come back.";

/// What turning the screenshot allowance on costs.
const screenshotCostWords =
    'The task switcher will show this screen, and screenshots and screen '
    'recording will work.';

/// The one fact about a Profile that has no way back.
const forgottenPinWords =
    'A forgotten PIN loses the Profile. There is no reset and no recovery.';

/// The promise this screen states where a User would look for it.
const nothingLeavesWords = 'Nothing here leaves this phone.';

/// The Settings screen, in three groups: reminders, privacy and the Profile.
///
/// Nothing here touches a Friend.
final class SettingsReading extends Equatable {
  /// Hold every value the screen draws.
  const SettingsReading({
    required this.settings,
    required this.profile,
    required this.otherProfiles,
    this.biometricAvailable = false,
    this.permissionRefused = false,
    this.isLocked = false,
  });

  /// A screen with nothing on it, because no Profile is open.
  const SettingsReading.locked()
    : settings = const ProfileSettings(),
      profile = null,
      otherProfiles = const [],
      biometricAvailable = false,
      permissionRefused = false,
      isLocked = true;

  /// The Profile's own options, out of the encrypted store.
  final ProfileSettings settings;

  /// The Profile the User is in. Null while locked.
  final Profile? profile;

  /// The Profiles this phone holds besides the open one.
  final List<Profile> otherProfiles;

  /// Whether this phone can ask for a fingerprint at all.
  final bool biometricAvailable;

  /// Whether the last attempt to turn reminders on was refused.
  final bool permissionRefused;

  /// Whether no Profile is open.
  final bool isLocked;

  /// Whether reminders are on.
  bool get remindersOn => settings.remindersOn;

  /// The hour of the Due Date a reminder fires at.
  int get reminderHour => settings.reminderHour;

  /// How long the app waits before it locks itself.
  Duration get autoLock => settings.autoLock;

  /// Whether the User has allowed their own screenshots.
  bool get screenshotsAllowed => settings.screenshotsAllowed;

  /// Whether this Profile offers a fingerprint beside its PIN.
  bool get usesBiometricUnlock => profile?.usesBiometricUnlock ?? false;

  /// The name of the Profile the User is in.
  String get profileName => profile?.displayName ?? '';

  /// Copy the reading, changing the values given.
  SettingsReading changing({
    ProfileSettings? settings,
    Profile? profile,
    List<Profile>? otherProfiles,
    bool? biometricAvailable,
    bool? permissionRefused,
  }) => SettingsReading(
    settings: settings ?? this.settings,
    profile: profile ?? this.profile,
    otherProfiles: otherProfiles ?? this.otherProfiles,
    biometricAvailable: biometricAvailable ?? this.biometricAvailable,
    permissionRefused: permissionRefused ?? this.permissionRefused,
  );

  @override
  List<Object?> get props => [
    settings,
    profile,
    otherProfiles,
    biometricAvailable,
    permissionRefused,
    isLocked,
  ];
}
