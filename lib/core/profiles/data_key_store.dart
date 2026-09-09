import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The name that one Profile's data key is stored under.
///
/// One name per Profile, so a key can be found and removed without touching
/// another Profile's key.
String dataKeyNameOf(String profileId) => 'dataKey.$profileId';

/// The data keys, one per Profile.
///
/// This app writes no wrapping code. The platform creates a non-exportable key
/// of its own and wraps what it is given here, so the only secret this app
/// mints is the 32 bytes it hands over.
class DataKeyStore {
  const DataKeyStore([
    this.storage = const FlutterSecureStorage(
      // The name ends in ThisDeviceOnly, so the item never enters a backup and
      // never travels to another phone. ADR-0020 turns every copy off, and a
      // key that outlives its phone opens nothing anyway.
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
      mOptions: MacOsOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    ),
  ]);

  final FlutterSecureStorage storage;

  /// Stores [dataKey] for the Profile with this id, and replaces any key held
  /// under the same name.
  Future<void> write(String profileId, Uint8List dataKey) => storage.write(
    key: dataKeyNameOf(profileId),
    value: base64Encode(dataKey),
  );

  /// Reads the key of the Profile with this id, or null when none is held.
  Future<Uint8List?> read(String profileId) async {
    final stored = await storage.read(key: dataKeyNameOf(profileId));

    return stored == null ? null : base64Decode(stored);
  }
}
