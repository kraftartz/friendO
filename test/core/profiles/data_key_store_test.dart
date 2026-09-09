import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendo/core/profiles/data_key_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DataKeyStore keys;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    keys = const DataKeyStore();
  });

  test('names one key after one Profile', () {
    expect(dataKeyNameOf('9f2c'), 'dataKey.9f2c');
  });

  test('gives back the key it was given', () async {
    final key = Uint8List.fromList(List.generate(32, (i) => i));

    await keys.write('9f2c', key);

    expect(await keys.read('9f2c'), key);
  });

  test('keeps one Profile key apart from another', () async {
    await keys.write('9f2c', Uint8List.fromList(List.filled(32, 1)));
    await keys.write('b3d4', Uint8List.fromList(List.filled(32, 2)));

    expect(await keys.read('9f2c'), Uint8List.fromList(List.filled(32, 1)));
    expect(await keys.read('b3d4'), Uint8List.fromList(List.filled(32, 2)));
  });

  test('gives nothing for a Profile it never held', () async {
    expect(await keys.read('9f2c'), isNull);
  });

  test('holds the key where a backup cannot reach it', () {
    expect(
      const DataKeyStore().storage.iOptions.accessibility,
      KeychainAccessibility.first_unlock_this_device,
    );
  });

  test(
    'stores the key as base64, so the bytes survive the round trip',
    () async {
      final key = Uint8List.fromList(List.filled(32, 0xFF));

      await keys.write('9f2c', key);

      final stored = await const FlutterSecureStorage().read(
        key: dataKeyNameOf('9f2c'),
      );
      expect(base64Decode(stored!), key);
    },
  );
}
