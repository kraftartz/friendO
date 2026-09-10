import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/crypto/pin_hash.dart';
import 'package:hashlib/hashlib.dart';

/// The RFC 9106 section 5.3 Argon2id vector, byte for byte.
///
/// It is the only check that says the algorithm is Argon2id and not something
/// that merely calls itself that. A package that reproduces it computes the
/// same digest as every other tool.
void _rfc9106Vector() {
  final password = Uint8List.fromList(List.filled(32, 0x01));
  final salt = Uint8List.fromList(List.filled(16, 0x02));
  final secret = Uint8List.fromList(List.filled(8, 0x03));
  final associatedData = Uint8List.fromList(List.filled(12, 0x04));

  final digest = argon2id(
    password,
    salt,
    hashLength: 32,
    key: secret,
    personalization: associatedData,
    security: const Argon2Security('rfc9106', m: 32, t: 3, p: 4),
  );

  expect(
    digest.hex(),
    '0d640df58d78766c08c037a34a8b53c9d01ef0452d75b65eb52520e96b01e659',
  );
}

void main() {
  test('reproduces the RFC 9106 Argon2id vector', _rfc9106Vector);

  group('KdfParams.forNewPin', () {
    test('carries the OWASP cost numbers, not the name of the preset', () {
      final params = KdfParams.forNewPin(salt: Uint8List(16));

      expect(params.algorithm, 'argon2id');
      expect(params.version, 19);
      expect(params.m, 19456);
      expect(params.t, 2);
      expect(params.p, 1);
    });

    test('keeps the salt it was given', () {
      final salt = Uint8List.fromList(List.generate(16, (i) => i));

      expect(KdfParams.forNewPin(salt: salt).salt, salt);
    });
  });

  group('hashPin', () {
    final params = KdfParams.forNewPin(
      salt: Uint8List.fromList(List.filled(16, 7)),
      security: Argon2Security.test,
    );

    test('returns 32 bytes', () {
      expect(hashPin('123456', params).length, 32);
    });

    test('returns the same digest for the same PIN and settings', () {
      expect(hashPin('123456', params), hashPin('123456', params));
    });

    test('returns a different digest for a different PIN', () {
      expect(hashPin('123456', params), isNot(hashPin('123457', params)));
    });

    test('returns a different digest under a different salt', () {
      final other = KdfParams.forNewPin(
        salt: Uint8List.fromList(List.filled(16, 8)),
        security: Argon2Security.test,
      );

      expect(hashPin('123456', params), isNot(hashPin('123456', other)));
    });

    test('reads the cost numbers it was given, not a preset', () {
      final cheap = KdfParams(
        algorithm: 'argon2id',
        version: 19,
        m: 32,
        t: 3,
        p: 4,
        salt: Uint8List.fromList(List.filled(16, 0x02)),
      );

      expect(
        hashPin('123456', cheap),
        argon2id(
          [0x31, 0x32, 0x33, 0x34, 0x35, 0x36],
          List.filled(16, 0x02),
          hashLength: 32,
          security: const Argon2Security('cheap', m: 32, t: 3, p: 4),
        ).bytes,
      );
    });

    test('refuses an algorithm it does not know', () {
      final foreign = KdfParams(
        algorithm: 'scrypt',
        version: 19,
        m: 32,
        t: 3,
        p: 4,
        salt: Uint8List(16),
      );

      expect(() => hashPin('123456', foreign), throwsA(isA<ArgumentError>()));
    });

    test('refuses a version it does not know', () {
      final future = KdfParams(
        algorithm: 'argon2id',
        version: 20,
        m: 32,
        t: 3,
        p: 4,
        salt: Uint8List(16),
      );

      expect(() => hashPin('123456', future), throwsA(isA<ArgumentError>()));
    });
  });

  group('the digest it compares', () {
    test('is the same one when the work runs away from this isolate', () async {
      final params = KdfParams.forNewPin(
        salt: Uint8List.fromList(List.filled(16, 3)),
        security: Argon2Security.test,
      );

      expect(await hashPinAsync('123456', params), hashPin('123456', params));
    });

    test('matches itself', () {
      final digest = Uint8List.fromList([1, 2, 3, 4]);

      expect(samePinHash(digest, Uint8List.fromList([1, 2, 3, 4])), isTrue);
    });

    test('differs when one byte differs', () {
      expect(
        samePinHash(
          Uint8List.fromList([1, 2, 3, 4]),
          Uint8List.fromList([1, 2, 3, 5]),
        ),
        isFalse,
      );
    });

    test('differs when the lengths differ', () {
      expect(
        samePinHash(
          Uint8List.fromList([1, 2, 3]),
          Uint8List.fromList([1, 2, 3, 4]),
        ),
        isFalse,
      );
    });
  });
}
