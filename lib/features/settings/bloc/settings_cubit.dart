import 'dart:async';

import 'package:flutter/widgets.dart'
    show AppLifecycleState, WidgetsBinding, WidgetsBindingObserver;
import 'package:flutter_bloc/flutter_bloc.dart' show Cubit;
import 'package:friendo/core/db/database_session.dart'
    show DatabaseLockedError, DatabaseSession, DatabaseState;
import 'package:friendo/core/profiles/profile_list.dart' show ProfileList;
import 'package:friendo/core/profiles/profile_session.dart'
    show ProfileSession, UnlockOutcome;
import 'package:friendo/core/reminders/notification_gate.dart'
    show NotificationGate;
import 'package:friendo/core/security/biometric_gate.dart' show BiometricGate;
import 'package:friendo/core/security/screen_privacy.dart' show ScreenPrivacy;
import 'package:friendo/core/settings/settings_store.dart' show SettingsStore;
import 'package:friendo/features/settings/bloc/settings_state.dart'
    show SettingsReading;

/// The Settings screen's state.
///
/// It writes a switch, an hour, a number of seconds, an allowance and a name,
/// and it calls two methods that already exist. It owns no mechanism: the lock
/// belongs to `ProfileSession`, the schedule to `core/reminders/`, and the
/// store to `core/settings/`.
class SettingsCubit extends Cubit<SettingsReading> with WidgetsBindingObserver {
  /// Read and write through the stores and the gates given.
  SettingsCubit({
    required this.profileId,
    required this.settings,
    required this.profiles,
    required this.session,
    required this.databases,
    required this.notifications,
    required this.biometrics,
    required this.screens,
  }) : super(const SettingsReading.locked()) {
    WidgetsBinding.instance.addObserver(this);
    _whileOpen = databases.state.listen(_onDatabaseState);
  }

  /// The Profile this screen is about.
  final String profileId;

  /// The Profile's own options.
  final SettingsStore settings;

  /// The plaintext Profile list.
  final ProfileList profiles;

  /// The owner of the lock and the unlock.
  final ProfileSession session;

  /// The owner of the connection.
  final DatabaseSession databases;

  /// The permission a reminder needs.
  final NotificationGate notifications;

  /// The operating system's own confirmation.
  final BiometricGate biometrics;

  /// The platform's screen privacy.
  final ScreenPrivacy screens;

  StreamSubscription<DatabaseState>? _whileOpen;

  /// Read the settings and the Profile list again.
  Future<void> readAgain() async {
    if (databases.stateNow != DatabaseState.open) return;

    try {
      final held = await settings.read();
      final rows = await profiles.read();
      final canAskForAFinger = await biometrics.isAvailable();
      if (isClosed || databases.stateNow != DatabaseState.open) return;

      emit(
        SettingsReading(
          settings: held,
          profile: rows.where((row) => row.id == profileId).firstOrNull,
          otherProfiles: [
            for (final row in rows)
              if (row.id != profileId) row,
          ],
          biometricAvailable: canAskForAFinger,
          permissionRefused: state.permissionRefused,
        ),
      );
    } on DatabaseLockedError {
      return;
    }
  }

  /// Turn reminders on or off.
  ///
  /// The switch follows the permission and not the intention. Turning it on
  /// asks for the permission at that moment, and a refusal leaves the switch
  /// off with a line saying why.
  Future<void> turnRemindersOn({required bool on}) async {
    if (!on) {
      await _write(remindersOn: false);
      if (!isClosed) emit(state.changing(permissionRefused: false));

      return;
    }

    final allowed = await notifications.request();
    if (isClosed) return;

    await _write(remindersOn: allowed);
    if (!isClosed) emit(state.changing(permissionRefused: !allowed));
  }

  /// Choose the hour of the Due Date a reminder fires at.
  Future<void> chooseReminderHour(int hour) => _write(reminderHour: hour);

  /// Choose how long the app waits before it locks itself.
  Future<void> chooseAutoLock(Duration wait) =>
      _write(autoLockSeconds: wait.inSeconds);

  /// Allow or block the User's own screenshots, on both platforms at once.
  Future<void> allowScreenshots({required bool allowed}) async {
    await _write(screenshotsAllowed: allowed);
    await screens.allowScreenshots(allowed: allowed);
  }

  /// Offer or withdraw a fingerprint beside this Profile's PIN.
  ///
  /// Turning it on confirms with the operating system once, so a User with no
  /// enrolled fingerprint learns it here rather than at the lock screen. The
  /// PIN never goes away.
  Future<void> useBiometricUnlock({required bool uses}) async {
    if (uses && !await biometrics.confirm(profileName: state.profileName)) {
      if (!isClosed) await readAgain();

      return;
    }

    await profiles.changeOne(
      profileId,
      (profile) => profile.withBiometricUnlock(uses),
    );
    await readAgain();
  }

  /// Rename this Profile. The write is the atomic one `ProfileList` makes.
  Future<void> rename(String displayName) async {
    final wanted = displayName.trim();
    if (wanted.isEmpty) return;

    await profiles.changeOne(profileId, (profile) => profile.named(wanted));
    await readAgain();
  }

  /// Lock now. It is the same `lock()` the auto-lock calls.
  Future<void> lockNow() => session.lock();

  /// Switch to another Profile.
  ///
  /// It is `lock()` and then `unlock()`, which is not a second mechanism. The
  /// first file is closed and its key is gone before the second opens.
  Future<UnlockOutcome> switchTo(String otherId, String pin) async {
    await session.lock();

    return session.unlock(otherId, pin);
  }

  /// Read the permission again, and follow it.
  ///
  /// A User who turned notifications off in the phone's own settings comes
  /// back to a switch that says off. Nothing is re-requested on its own.
  Future<void> noticePermission() async {
    if (!state.remindersOn) return;
    if (await notifications.isAllowed() || isClosed) return;

    await _write(remindersOn: false);
    if (!isClosed) emit(state.changing(permissionRefused: true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    unawaited(readAgain().then((_) => noticePermission()));
  }

  @override
  Future<void> close() async {
    WidgetsBinding.instance.removeObserver(this);
    await _whileOpen?.cancel();

    return super.close();
  }

  Future<void> _write({
    bool? remindersOn,
    int? reminderHour,
    int? autoLockSeconds,
    bool? screenshotsAllowed,
  }) async {
    final written = await settings.change(
      remindersOn: remindersOn,
      reminderHour: reminderHour,
      autoLockSeconds: autoLockSeconds,
      screenshotsAllowed: screenshotsAllowed,
    );
    if (isClosed) return;

    emit(state.changing(settings: written));
  }

  void _onDatabaseState(DatabaseState open) {
    if (open == DatabaseState.open) {
      unawaited(readAgain());

      return;
    }

    emit(const SettingsReading.locked());
  }
}
