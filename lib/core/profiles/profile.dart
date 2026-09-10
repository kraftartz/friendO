import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../crypto/pin_hash.dart';

/// One private space on this phone, and the way to check its PIN.
///
/// A Profile holds no Friend. It holds the name a User picked, the digest of
/// the PIN that opens the space, and the settings that made that digest.
class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.displayName,
    required this.pinHash,
    required this.kdfParams,
    required this.failedAttempts,
    this.usesBiometricUnlock = false,
  });

  /// 128 random bits, as 32 lowercase hexadecimal characters.
  ///
  /// It is safe in a file name and it carries no meaning, so a rename of the
  /// Profile changes nothing that points at it.
  final String id;

  /// The name a User picked for this space.
  final String displayName;

  /// The digest of the PIN, which is the only form of the PIN this app keeps.
  final Uint8List pinHash;

  /// The settings that made [pinHash], and that a check must repeat.
  final KdfParams kdfParams;

  /// The count of wrong PINs since the last correct one.
  final int failedAttempts;

  /// Whether this Profile offers a fingerprint beside its PIN.
  ///
  /// It is the one setting in the plaintext file. The PIN screen has to know
  /// whether to offer a fingerprint for the Profile the User just picked, and
  /// at that moment no database is open. It is not a credential and it opens
  /// nothing. See ADR-0036 and ADR-0011.
  final bool usesBiometricUnlock;

  /// Copy the Profile with a different display name.
  Profile named(String displayName) => Profile(
    id: id,
    displayName: displayName,
    pinHash: pinHash,
    kdfParams: kdfParams,
    failedAttempts: failedAttempts,
    usesBiometricUnlock: usesBiometricUnlock,
  );

  /// Copy the Profile with the fingerprint offered or withdrawn.
  Profile withBiometricUnlock(bool uses) => Profile(
    id: id,
    displayName: displayName,
    pinHash: pinHash,
    kdfParams: kdfParams,
    failedAttempts: failedAttempts,
    usesBiometricUnlock: uses,
  );

  Profile withFailedAttempts(int count) => Profile(
    id: id,
    displayName: displayName,
    pinHash: pinHash,
    kdfParams: kdfParams,
    failedAttempts: count,
    usesBiometricUnlock: usesBiometricUnlock,
  );

  @override
  List<Object?> get props => [
    id,
    displayName,
    pinHash,
    kdfParams,
    failedAttempts,
    usesBiometricUnlock,
  ];
}
