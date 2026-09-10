import 'dart:math' show Random;
import 'dart:typed_data' show Uint8List;

import 'package:friendo/core/crypto/hex.dart' show hex;

const _idBytes = 16;

final Random _random = Random.secure();

/// A fresh id for a row this app writes.
///
/// Sixteen random bytes as hexadecimal. Two of them colliding is not something
/// a person could reach: a Profile that held a million rows would still stand
/// at odds of about one in ten thousand billion billion.
String newId() => hex(
  Uint8List.fromList(List.generate(_idBytes, (_) => _random.nextInt(256))),
);
