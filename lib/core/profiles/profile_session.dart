import 'package:equatable/equatable.dart';

import '../crypto/pin_hash.dart';
import '../db/app_database.dart';
import '../db/database_session.dart';
import 'data_key_store.dart';
import 'profile.dart';
import 'profile_list.dart';
import 'pin.dart';

/// What came of an attempt to unlock a Profile.
sealed class UnlockOutcome extends Equatable {
  const UnlockOutcome();

  @override
  List<Object?> get props => const [];
}

/// The PIN was right and the Profile is open.
class Unlocked extends UnlockOutcome {
  const Unlocked();
}

/// The PIN was wrong. [failedAttempts] is the count as it now stands.
class WrongPin extends UnlockOutcome {
  const WrongPin(this.failedAttempts);

  final int failedAttempts;

  @override
  List<Object?> get props => [failedAttempts];
}

/// The keypad waits after wrong PINs. [remaining] is what is left of the delay.
class PinDelayed extends UnlockOutcome {
  const PinDelayed(this.remaining);

  final Duration remaining;

  @override
  List<Object?> get props => [remaining];
}

/// The Profile cannot be opened, and the User made no mistake.
class Failed extends UnlockOutcome {
  const Failed(this.reason);

  final UnlockFailureReason reason;

  @override
  List<Object?> get props => [reason];
}

/// Why a Profile with the right PIN did not open.
///
/// The three are told apart because they need different words. A broken
/// install that reads as "try again" cannot be put right by trying again.
enum UnlockFailureReason { dataKeyMissing, fileWillNotOpen, migrationFailed }

/// The walk from six digits to an open connection, and back again.
///
/// It coordinates and owns nothing: the hash comes from `core/crypto/`, the
/// data key from the phone, and the connection from `core/db/`. It publishes
/// no state of its own, because `core/db/` already publishes that one fact.
class ProfileSession {
  ProfileSession({
    required this.profiles,
    required this.databases,
    required this.dataKeys,
  });

  final ProfileList profiles;

  final DatabaseSession databases;

  final DataKeyStore dataKeys;

  final Stopwatch _sinceArrival = Stopwatch();

  /// Marks the moment the keypad appeared, which the delay is measured from.
  ///
  /// It measures with a timer that only counts forward while the app runs, so
  /// that moving the phone's clock buys nothing and closing the app costs the
  /// whole delay again.
  void arriveAtKeypad() => _sinceArrival
    ..reset()
    ..start();

  /// Marks the keypad gone, so the delay starts again on the next arrival.
  ///
  /// Without this the watch runs on across an open Profile. A later caller
  /// that reads the delay without announcing a keypad would then measure from
  /// an arrival the User left long ago, and find no delay left at all.
  void leaveKeypad() => _sinceArrival
    ..stop()
    ..reset();

  /// What is left of the delay for this Profile, as it now stands.
  Future<Duration> delayLeftFor(String profileId) async => pinDelayLeft(
    (await _rowOf(profileId)).failedAttempts,
    _sinceArrival.elapsed,
  );

  /// Checks the PIN, and opens the Profile when it is right.
  ///
  /// A wrong PIN is counted before the caller is told, so that killing the
  /// app between the two costs the attempt anyway.
  Future<UnlockOutcome> unlock(String profileId, String pin) async {
    final profile = await _rowOf(profileId);

    final waiting = pinDelayLeft(profile.failedAttempts, _sinceArrival.elapsed);
    if (waiting > Duration.zero) return PinDelayed(waiting);

    final digest = await hashPinAsync(pin, profile.kdfParams);
    if (!samePinHash(digest, profile.pinHash)) {
      final attempts = profile.failedAttempts + 1;
      await _writeAttempts(profileId, attempts);

      return WrongPin(attempts);
    }

    final failure = await openProfile(profileId);
    if (failure != null) return Failed(failure);

    await _writeAttempts(profileId, 0);
    leaveKeypad();

    return const Unlocked();
  }

  /// Closes the Profile, and drops the key with the connection that held it.
  ///
  /// The keypad is next, so the delay starts from the moment it appears rather
  /// than from an arrival the User has long left behind.
  Future<void> lock() {
    leaveKeypad();

    return databases.close();
  }

  /// Unwraps the data key and opens the file. It takes no PIN.
  ///
  /// A second gate, such as a fingerprint, reaches this step rather than
  /// copying the walk that follows a PIN. So does First Run, which has just
  /// watched the User choose the PIN twice.
  ///
  /// It answers null when the Profile is open, and why not when it is not.
  Future<UnlockFailureReason?> openProfile(String profileId) async {
    final dataKey = await dataKeys.read(profileId);
    if (dataKey == null) return UnlockFailureReason.dataKeyMissing;

    try {
      await databases.open(profileId, dataKey);
    } on MigrationFailed {
      return UnlockFailureReason.migrationFailed;
    } on StateError {
      // An open over an open Profile is a defect, not a Profile that will not
      // open. Telling the User to give up on their own data would hide it.
      rethrow;
    } on Object {
      return UnlockFailureReason.fileWillNotOpen;
    }

    return null;
  }

  Future<Profile> _rowOf(String profileId) async {
    final rows = await profiles.read();
    final row = rows.where((row) => row.id == profileId).firstOrNull;
    if (row == null) {
      throw ArgumentError.value(
        profileId,
        'profileId',
        'is in no Profile list',
      );
    }

    return row;
  }

  Future<void> _writeAttempts(String profileId, int count) async {
    final rows = await profiles.read();

    await profiles.write([
      for (final row in rows)
        if (row.id == profileId) row.withFailedAttempts(count) else row,
    ]);
  }
}
