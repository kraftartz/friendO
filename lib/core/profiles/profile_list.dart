import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import '../crypto/pin_hash.dart';
import 'profile.dart';

/// The name of the file that holds the list.
const profileListFileName = 'profiles.json';

/// The only shape of that file this code understands.
const profileListVersion = 1;

/// A list that is present and cannot be trusted.
///
/// It is thrown instead of an empty list on purpose. An empty list means that
/// this phone holds no Profile, and it starts the creation of one. A damaged
/// list read as an empty one would write a new list over Profiles that are
/// still on the phone, and nothing can recover them after that.
class ProfileListDamaged implements Exception {
  const ProfileListDamaged(this.path, this.reason);

  /// The file that could not be read.
  final String path;

  /// What is wrong with it, in one phrase.
  final String reason;

  @override
  String toString() => 'ProfileListDamaged: $path $reason';
}

/// The list of the Profiles on this phone, as one file.
///
/// The file is plaintext by design. It is read before any Profile is unlocked,
/// so no key can cover it. It holds a name and a digest, and it names no
/// Friend.
class ProfileList {
  const ProfileList(this.directory);

  /// The directory that holds the file. It arrives as an argument, so this
  /// code asks the phone for no path of its own.
  final Directory directory;

  File get file => File(p.join(directory.path, profileListFileName));

  /// Reads the list.
  ///
  /// An absent file gives an empty list, because a phone with no file holds no
  /// Profile.
  ///
  /// Throws [ProfileListDamaged] when the file is present and this code cannot
  /// trust what it holds.
  Future<List<Profile>> read() async {
    if (!file.existsSync()) return const [];

    final text = await file.readAsString();
    try {
      return _parse(text);
    } on ProfileListDamaged {
      rethrow;
    } on Object catch (error) {
      throw ProfileListDamaged(file.path, 'is not a Profile list: $error');
    }
  }

  /// Replaces the list with [profiles].
  ///
  /// The write is atomic. It fills a temporary file in the same directory,
  /// flushes it, and renames it over the target. A rename inside one directory
  /// completes or does not happen, so a reader never meets half a list.
  Future<void> write(List<Profile> profiles) async {
    final json = const JsonEncoder.withIndent('  ').convert({
      'version': profileListVersion,
      'profiles': profiles.map(_rowOf).toList(),
    });

    final temporary = File('${file.path}.tmp');
    final handle = await temporary.open(mode: FileMode.writeOnly);
    try {
      await handle.writeString(json);
      await handle.flush();
    } finally {
      await handle.close();
    }
    await temporary.rename(file.path);
  }

  List<Profile> _parse(String text) {
    final json = jsonDecode(text);
    if (json is! Map<String, dynamic>) {
      throw ProfileListDamaged(file.path, 'does not hold a Profile list');
    }

    final version = json['version'];
    if (version != profileListVersion) {
      throw ProfileListDamaged(
        file.path,
        'holds version $version, and this app knows version '
        '$profileListVersion',
      );
    }

    final rows = json['profiles'];
    if (rows is! List) {
      throw ProfileListDamaged(file.path, 'holds no list of Profiles');
    }

    return rows.map((row) => _profileOf(row as Map<String, dynamic>)).toList();
  }

  Map<String, dynamic> _rowOf(Profile profile) => {
    'id': profile.id,
    'displayName': profile.displayName,
    'pinHash': base64Encode(profile.pinHash),
    'kdfParams': {
      'algorithm': profile.kdfParams.algorithm,
      'version': profile.kdfParams.version,
      'm': profile.kdfParams.m,
      't': profile.kdfParams.t,
      'p': profile.kdfParams.p,
      'salt': base64Encode(profile.kdfParams.salt),
    },
    'failedAttempts': profile.failedAttempts,
  };

  Profile _profileOf(Map<String, dynamic> row) {
    final kdf = row['kdfParams'] as Map<String, dynamic>;

    return Profile(
      id: row['id'] as String,
      displayName: row['displayName'] as String,
      pinHash: _bytesOf(row['pinHash'] as String),
      kdfParams: KdfParams(
        algorithm: kdf['algorithm'] as String,
        version: kdf['version'] as int,
        m: kdf['m'] as int,
        t: kdf['t'] as int,
        p: kdf['p'] as int,
        salt: _bytesOf(kdf['salt'] as String),
      ),
      failedAttempts: row['failedAttempts'] as int,
    );
  }

  Uint8List _bytesOf(String value) => base64Decode(value);
}
