import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/crypto/pin_hash.dart';
import 'package:friendo/core/profiles/profile.dart';
import 'package:friendo/core/profiles/profile_list.dart';
import 'package:path/path.dart' as p;

Profile _profile({String id = 'a1', String displayName = 'Michal'}) => Profile(
  id: id,
  displayName: displayName,
  pinHash: Uint8List.fromList(List.filled(32, 3)),
  kdfParams: KdfParams.forNewPin(salt: Uint8List.fromList(List.filled(16, 4))),
  failedAttempts: 0,
);

void main() {
  late Directory directory;
  late ProfileList list;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('friendo_profile_list');
    list = ProfileList(directory);
  });

  tearDown(() => directory.deleteSync(recursive: true));

  void writeRaw(String content) =>
      File(p.join(directory.path, 'profiles.json')).writeAsStringSync(content);

  group('read', () {
    test('reports no Profile when the file is absent', () async {
      expect(await list.read(), isEmpty);
    });

    test('reports no Profile when the list is empty', () async {
      writeRaw('{"version": 1, "profiles": []}');

      expect(await list.read(), isEmpty);
    });

    test('fails loudly when the file does not parse', () async {
      writeRaw('{"version": 1, "profiles": [');

      await expectLater(list.read(), throwsA(isA<ProfileListDamaged>()));
    });

    test('fails loudly when the version is one it does not know', () async {
      writeRaw('{"version": 2, "profiles": []}');

      await expectLater(list.read(), throwsA(isA<ProfileListDamaged>()));
    });

    test('fails loudly when the version is absent', () async {
      writeRaw('{"profiles": []}');

      await expectLater(list.read(), throwsA(isA<ProfileListDamaged>()));
    });

    test('fails loudly when a row is missing a field', () async {
      writeRaw('{"version": 1, "profiles": [{"id": "a1"}]}');

      await expectLater(list.read(), throwsA(isA<ProfileListDamaged>()));
    });

    test('names the file it could not read', () async {
      writeRaw('not json');

      await expectLater(
        list.read(),
        throwsA(
          isA<ProfileListDamaged>().having(
            (e) => e.toString(),
            'toString',
            contains('profiles.json'),
          ),
        ),
      );
    });
  });

  group('write', () {
    test('gives back what it was given', () async {
      final profiles = [_profile(id: 'a1'), _profile(id: 'b2')];

      await list.write(profiles);

      expect(await list.read(), profiles);
    });

    test('writes version 1', () async {
      await list.write([_profile()]);

      final json =
          jsonDecode(
                File(
                  p.join(directory.path, 'profiles.json'),
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;

      expect(json['version'], 1);
    });

    test('leaves no temporary file behind', () async {
      await list.write([_profile()]);

      expect(directory.listSync().map((e) => p.basename(e.path)), [
        'profiles.json',
      ]);
    });

    test('replaces the whole list', () async {
      await list.write([_profile(id: 'a1')]);
      await list.write([_profile(id: 'b2')]);

      expect((await list.read()).single.id, 'b2');
    });
  });
}
