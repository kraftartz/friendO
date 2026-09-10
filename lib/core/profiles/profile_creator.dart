import 'dart:math';
import 'dart:typed_data';

import 'package:hashlib/hashlib.dart';

import '../crypto/hex.dart';
import '../crypto/pin_hash.dart';
import '../db/database_session.dart';
import 'data_key_store.dart';
import 'profile.dart';
import 'profile_list.dart';

/// The length of a Profile id, in bytes. 128 bits never collide.
const _profileIdBytes = 16;

/// The length of a PIN salt, in bytes.
const _saltBytes = 16;

/// The length of a data key, in bytes. It is 256 bits, and it is random, so a
/// six-digit PIN never limits its strength.
const _dataKeyBytes = 32;

/// Makes one Profile, and everything one Profile needs to open.
///
/// This is the only object that mints a data key, and the only one that adds a
/// row to the Profile list.
class ProfileCreator {
  ProfileCreator({
    required this.profiles,
    required this.databases,
    required this.dataKeys,
    this.security = Argon2Security.owasp2,
    Random? random,
  }) : _random = random ?? Random.secure();

  final ProfileList profiles;

  final DatabaseSession databases;

  final DataKeyStore dataKeys;

  /// The cost of one PIN hash. A cheaper setting is a legitimate value,
  /// because every Profile stores the settings that made its own digest.
  final Argon2Security security;

  final Random _random;

  /// Creates the Profile named [displayName], which [pin] opens.
  ///
  /// The order of the writes decides what a crash leaves behind:
  ///
  /// 1. mint the id, the salt and the data key
  /// 2. hash the PIN
  /// 3. store the data key
  /// 4. create the encrypted file, and carry it to the current schema version
  /// 5. append the row to the Profile list
  ///
  /// **Step 5 is the commit.** A row that names a Profile with no key and no
  /// file is a Profile that can never open, and nothing can delete one. So the
  /// row arrives last, when everything it names already exists.
  ///
  /// A failure before step 5 leaves a key and a file that no row names. Both
  /// are unreachable, and a fresh id on the next try cannot collide with them.
  ///
  /// Throws [ArgumentError] when [displayName] holds nothing but spaces,
  /// because a blank row on the picker names no Profile.
  Future<Profile> createProfile(String displayName, String pin) async {
    final name = displayName.trim();
    if (name.isEmpty) {
      throw ArgumentError.value(displayName, 'displayName', 'is empty');
    }

    // The list is read before anything is minted. A list that cannot be read
    // stops the work here, rather than after a key and a file exist that no
    // row will ever name.
    final existing = await profiles.read();

    final id = hex(_bytes(_profileIdBytes));
    final kdfParams = KdfParams.forNewPin(
      salt: _bytes(_saltBytes),
      security: security,
    );
    final dataKey = _bytes(_dataKeyBytes);

    final profile = Profile(
      id: id,
      displayName: name,
      pinHash: await hashPinAsync(pin, kdfParams),
      kdfParams: kdfParams,
      failedAttempts: 0,
    );

    await dataKeys.write(id, dataKey);

    await databases.open(id, dataKey);
    await databases.close();

    await profiles.write([...existing, profile]);

    return profile;
  }

  Uint8List _bytes(int count) =>
      Uint8List.fromList(List.generate(count, (_) => _random.nextInt(256)));
}
