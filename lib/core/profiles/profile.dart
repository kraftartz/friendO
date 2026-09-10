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

  @override
  List<Object?> get props => [
    id,
    displayName,
    pinHash,
    kdfParams,
    failedAttempts,
  ];
}
