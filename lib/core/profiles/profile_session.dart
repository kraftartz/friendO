import 'package:equatable/equatable.dart';

import '../crypto/pin_hash.dart';
import '../db/app_database.dart';
import '../db/database_session.dart';
import 'data_key_store.dart';
import 'profile.dart';
import 'profile_list.dart';
import 'rest.dart';

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

/// The keypad is resting after wrong PINs. [remaining] is what is left of it.
class Resting extends UnlockOutcome {
  const Resting(this.remaining);

  final Duration remaining;

  @override
  List<Object?> get props => [remaining];
}

/// The Profile cannot be opened, and the User made no mistake.
class Failed extends UnlockOutcome {
  const Failed(this.reason);

  final UnlockFailure reason;

  @override
  List<Object?> get props => [reason];
}

/// Why a Profile with the right PIN did not open.
///
/// The three are told apart because they need different words. A broken
/// install that reads as "try again" cannot be put right by trying again.
enum UnlockFailure { dataKeyMissing, fileWillNotOpen, migrationFailed }

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

  /// Marks the moment the keypad appeared, which the rest is measured from.
  ///
  /// It measures with a timer that only counts forward while the app runs, so
  /// that moving the phone's clock buys nothing and closing the app costs the
  /// whole rest again.
  void arriveAtKeypad() => _sinceArrival
    ..reset()
    ..start();

  /// What is left of the rest for this Profile, as it now stands.
  Future<Duration> restLeftFor(String profileId) async =>
      restLeft((await _rowOf(profileId)).failedAttempts, _sinceArrival.elapsed);

  /// Checks the PIN, and opens the Profile when it is right.
  ///
  /// A wrong PIN is counted before the caller is told, so that killing the
  /// app between the two costs the attempt anyway.
  Future<UnlockOutcome> unlock(String profileId, String pin) async {
    final profile = await _rowOf(profileId);

    final resting = restLeft(profile.failedAttempts, _sinceArrival.elapsed);
    if (resting > Duration.zero) return Resting(resting);

    final digest = await hashPinApart(pin, profile.kdfParams);
    if (!samePinHash(digest, profile.pinHash)) {
      final attempts = profile.failedAttempts + 1;
      await _writeAttempts(profileId, attempts);

      return WrongPin(attempts);
    }

    final failure = await openProfile(profileId);
    if (failure != null) return Failed(failure);

    await _writeAttempts(profileId, 0);

    return const Unlocked();
  }

  /// Closes the Profile, and drops the key with the connection that held it.
  Future<void> lock() => databases.close();

  /// Unwraps the data key and opens the file. It takes no PIN.
  ///
  /// A second gate, such as a fingerprint, reaches this step rather than
  /// copying the walk that follows a PIN. So does First Run, which has just
  /// watched the User choose the PIN twice.
  ///
  /// It answers null when the Profile is open, and why not when it is not.
  Future<UnlockFailure?> openProfile(String profileId) async {
    final dataKey = await dataKeys.read(profileId);
    if (dataKey == null) return UnlockFailure.dataKeyMissing;

    try {
      await databases.open(profileId, dataKey);
    } on MigrationFailed {
      return UnlockFailure.migrationFailed;
    } on Object {
      return UnlockFailure.fileWillNotOpen;
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
