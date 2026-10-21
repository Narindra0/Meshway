import 'dart:math';
import 'dart:typed_data';

import 'package:hafatra/core/utils/byte_utils.dart';

/// Génère des identifiants de paquets et de messages.
abstract interface class IdGenerator {
  Uint8List nextBytes();

  String nextString();
}

/// UUID v7 : ordonné dans le temps, 16 octets, adapté aux clés primaires.
final class SecureIdGenerator implements IdGenerator {
  SecureIdGenerator({DateTime Function()? now})
    : _now = now ?? DateTime.now,
      _random = Random.secure();

  final DateTime Function() _now;
  final Random _random;

  @override
  Uint8List nextBytes() {
    final bytes = Uint8List(16);
    var millis = _now().toUtc().millisecondsSinceEpoch & 0xFFFFFFFFFFFF;
    for (var i = 5; i >= 0; i--) {
      bytes[i] = millis & 0xff;
      millis >>= 8;
    }
    bytes[6] = 0x70 | (_random.nextInt(16));
    bytes[7] = _random.nextInt(256);
    bytes[8] = 0x80 | (_random.nextInt(64));
    for (var i = 9; i < 16; i++) {
      bytes[i] = _random.nextInt(256);
    }
    return bytes;
  }

  @override
  String nextString() => formatUuid(nextBytes());
}

/// Formate 16 octets en UUID canonique.
String formatUuid(List<int> bytes) {
  if (bytes.length != 16) {
    throw ArgumentError.value(bytes.length, 'bytes', '16 octets attendus');
  }
  final hex = ByteUtils.toHex(bytes);
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// Générateur déterministe réservé aux tests.
final class SequentialIdGenerator implements IdGenerator {
  SequentialIdGenerator([int start = 1]) : _value = start;

  int _value;

  @override
  Uint8List nextBytes() {
    final bytes = Uint8List(16);
    final value = _value++;
    for (var i = 0; i < 8; i++) {
      bytes[15 - i] = (value >> (i * 8)) & 0xff;
    }
    return bytes;
  }

  @override
  String nextString() => formatUuid(nextBytes());
}
