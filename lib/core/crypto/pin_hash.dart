import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:hashlib/hashlib.dart';

/// The name of the only key derivation function this file computes.
const argon2idAlgorithm = 'argon2id';

/// The only Argon2 version this file computes. It is 0x13 in the RFC.
const argon2Version = 19;

/// The length of a PIN digest, in bytes.
const pinHashLength = 32;

/// The settings that turn one PIN into one digest.
///
/// The settings travel with the digest, so a stronger setting later still
/// opens a PIN hashed under an older one. Every number is stored, and the name
/// of a preset is not, because a preset may move between releases.
class KdfParams extends Equatable {
  const KdfParams({
    required this.algorithm,
    required this.version,
    required this.m,
    required this.t,
    required this.p,
    required this.salt,
  });

  /// The settings for a PIN that is hashed for the first time.
  ///
  /// [security] defaults to the strongest setting this app asks for. A cheaper
  /// one is a legitimate value: it costs less time and it produces a digest
  /// that verifies in the same way.
  KdfParams.forNewPin({
    required this.salt,
    Argon2Security security = Argon2Security.owasp2,
  }) : algorithm = argon2idAlgorithm,
       version = argon2Version,
       m = security.m,
       t = security.t,
       p = security.p;

  /// The key derivation function, by name.
  final String algorithm;

  /// The version of that function.
  final int version;

  /// The memory cost, in kibibytes.
  final int m;

  /// The number of passes.
  final int t;

  /// The number of lanes.
  final int p;

  /// The random bytes that make this PIN's digest unlike every other one.
  final Uint8List salt;

  @override
  List<Object?> get props => [algorithm, version, m, t, p, salt];
}

/// Computes the digest of [pin] under [params].
///
/// The digest is [pinHashLength] bytes. The same PIN and the same settings
/// always give the same bytes, which is what makes a later comparison a check
/// of the PIN.
///
/// Throws [ArgumentError] when [params] names an algorithm or a version this
/// file cannot compute. A digest under a guessed setting would be wrong in a
/// way that reads as a wrong PIN.
Uint8List hashPin(String pin, KdfParams params) {
  if (params.algorithm != argon2idAlgorithm) {
    throw ArgumentError.value(
      params.algorithm,
      'params.algorithm',
      'expected $argon2idAlgorithm',
    );
  }
  if (params.version != argon2Version) {
    throw ArgumentError.value(
      params.version,
      'params.version',
      'expected $argon2Version',
    );
  }

  return argon2id(
    utf8.encode(pin),
    params.salt,
    hashLength: pinHashLength,
    security: Argon2Security('stored', m: params.m, t: params.t, p: params.p),
  ).bytes;
}

/// Hashes the PIN away from the isolate that draws the screen.
///
/// The work is hundreds of milliseconds on a mid-range phone, which is a
/// dropped frame for every one of them if it runs beside the keypad.
Future<Uint8List> hashPinApart(String pin, KdfParams params) =>
    Isolate.run(() => hashPin(pin, params));

/// Answers whether two PIN digests are the same, in constant time.
///
/// It reads every byte of both, so that the time it takes says nothing about
/// how many bytes matched.
bool samePinHash(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;

  var difference = 0;
  for (var i = 0; i < a.length; i++) {
    difference |= a[i] ^ b[i];
  }

  return difference == 0;
}
