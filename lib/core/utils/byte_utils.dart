import 'dart:math';
import 'dart:typed_data';

/// Utilitaires binaires partagés par le protocole et la cryptographie.
abstract final class ByteUtils {
  static final Random _random = Random.secure();

  static Uint8List concat(Iterable<List<int>> parts) {
    final total = parts.fold<int>(0, (sum, part) => sum + part.length);
    final result = Uint8List(total);
    var offset = 0;
    for (final part in parts) {
      result.setRange(offset, offset + part.length, part);
      offset += part.length;
    }
    return result;
  }

  static Uint8List randomBytes(int length) {
    final bytes = Uint8List(length);
    for (var i = 0; i < length; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  static String toHex(Iterable<int> bytes) {
    final buffer = StringBuffer();
    for (final byte in bytes) {
      buffer.write(byte.toRadixString(16).padLeft(2, '0'));
    }
    return buffer.toString();
  }

  static Uint8List fromHex(String hex) {
    final normalized = hex.trim();
    if (normalized.length.isOdd) {
      throw const FormatException('Longueur hexadécimale impaire.');
    }
    final result = Uint8List(normalized.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(normalized.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  static bool constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) {
      return false;
    }
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  static int readUint16(List<int> bytes, int offset) {
    return (bytes[offset] << 8) | bytes[offset + 1];
  }

  static int readUint32(List<int> bytes, int offset) {
    return (bytes[offset] << 24) |
        (bytes[offset + 1] << 16) |
        (bytes[offset + 2] << 8) |
        bytes[offset + 3];
  }

  static int readUint64(List<int> bytes, int offset) {
    var value = 0;
    for (var i = 0; i < 8; i++) {
      value = (value << 8) | bytes[offset + i];
    }
    return value;
  }

  static void writeUint16(List<int> bytes, int offset, int value) {
    bytes[offset] = (value >> 8) & 0xff;
    bytes[offset + 1] = value & 0xff;
  }

  static void writeUint32(List<int> bytes, int offset, int value) {
    bytes[offset] = (value >> 24) & 0xff;
    bytes[offset + 1] = (value >> 16) & 0xff;
    bytes[offset + 2] = (value >> 8) & 0xff;
    bytes[offset + 3] = value & 0xff;
  }

  static void writeUint64(List<int> bytes, int offset, int value) {
    for (var i = 0; i < 8; i++) {
      bytes[offset + 7 - i] = (value >> (i * 8)) & 0xff;
    }
  }

  static String shortFingerprint(List<int> bytes, {int length = 8}) {
    final hex = toHex(bytes);
    return hex.substring(0, min(length, hex.length)).toUpperCase();
  }

  static String canonicalUuid(List<int> bytes) {
    if (bytes.length != 16) {
      throw ArgumentError.value(bytes.length, 'bytes', '16 octets attendus');
    }
    final hex = toHex(bytes);
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  static String normalizeUuid(String value) {
    final stripped = value.replaceAll('-', '').toLowerCase();
    if (stripped.length != 32 ||
        !RegExp(r'^[0-9a-f]{32}$').hasMatch(stripped)) {
      throw FormatException('UUID invalide : $value');
    }
    return '${stripped.substring(0, 8)}-${stripped.substring(8, 12)}-'
        '${stripped.substring(12, 16)}-${stripped.substring(16, 20)}-'
        '${stripped.substring(20)}';
  }

  static String compactUuid(String value) {
    return normalizeUuid(value).replaceAll('-', '');
  }
}
