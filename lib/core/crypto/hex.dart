import 'dart:typed_data';

/// Writes [bytes] as lowercase hexadecimal, two characters per byte.
///
/// The result is safe in a file name and in a SQL string, which is what makes
/// it the form a key and an id travel in.
String hex(Uint8List bytes) =>
    bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
