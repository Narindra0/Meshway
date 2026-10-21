import 'dart:typed_data';

/// Types de paquets du protocole Hafatra V1.
enum MeshPacketType {
  chat(1),
  alert(2),
  deliveryAck(3),
  relayReceipt(4),
  safety(5),
  profile(6);

  MeshPacketType(this.value);

  final int value;

  static MeshPacketType? fromValue(int value) {
    for (final type in values) {
      if (type.value == value) {
        return type;
      }
    }
    return null;
  }
}

/// Constantes binaires et politiques du maillage.
abstract final class MeshConstants {
  static const String magic = 'HFT1';
  static const int protocolVersion = 2;

  static const int headerLength = 146;
  static const int maxPacketLength = 4096;
  static const int signatureLength = 64;
  static const int publicKeyLength = 32;
  static const int messageIdLength = 16;
  static const int channelIdLength = 8;
  static const int senderIdLength = 8;

  static const int defaultTtl = 7;
  static const int maxTtl = 7;
  static const int minTtl = 1;
  static const int maxHopCount = 15;

  static const Duration dedupRetention = Duration(days: 7);
  static const Duration alertFutureTolerance = Duration(minutes: 10);
  static const Duration alertPastTolerance = Duration(days: 7);
  static const Duration rateLimitWindow = Duration(minutes: 1);
  static const int rateLimitPerSenderPerMinute = 20;
  static const Duration rateLimitMinInterval = Duration(seconds: 2);

  static const int priorityAlert = 100;
  static const int priorityAck = 60;
  static const int priorityReceipt = 40;
  static const int priorityChat = 20;

  static const Duration relayJitterMax = Duration(milliseconds: 500);
  static const Duration outboxPumpInterval = Duration(seconds: 3);

  // Service GATT Hafatra. Chaque téléphone expose le même service.
  static final UuidBytes serviceUuid = UuidBytes.parse(
    '51f8a9c2-3d7e-4a91-9b52-6c1e2f7a0001',
  );
  static final UuidBytes inboxUuid = UuidBytes.parse(
    '51f8a9c2-3d7e-4a91-9b52-6c1e2f7a0002',
  );
  static final UuidBytes outboxUuid = UuidBytes.parse(
    '51f8a9c2-3d7e-4a91-9b52-6c1e2f7a0003',
  );

  /// Le nom n'est pas diffusé : il ne tiendrait pas dans 31 octets.
  static const bool advertiseName = false;

  /// Taille utile maximale d'un chunk BLE (marge sous l'ATT MTU courant).
  static const int bleChunkPayloadLength = 176;
  static const int bleChunkHeaderLength = 7;
  static const int bleChunkVersion = 1;
  static const int bleMaxChunks = 255;
  static const Duration bleConnectionTimeout = Duration(seconds: 12);
  static const Duration bleReconnectCooldown = Duration(seconds: 8);
  static const Duration bleKeepAlive = Duration(seconds: 20);

  static Uint8List get serviceUuidBytes => serviceUuid.bytes;
  static Uint8List get inboxUuidBytes => inboxUuid.bytes;
  static Uint8List get outboxUuidBytes => outboxUuid.bytes;
}

/// Représentation minimale d'un UUID 128 bits pour rester dans le domaine.
final class UuidBytes {
  const UuidBytes(this.bytes);

  factory UuidBytes.parse(String value) {
    final normalized = value.replaceAll('-', '');
    if (normalized.length != 32) {
      throw FormatException('UUID invalide : $value');
    }
    final bytes = Uint8List(16);
    for (var i = 0; i < 16; i++) {
      bytes[i] = int.parse(normalized.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return UuidBytes(bytes);
  }

  final Uint8List bytes;

  String get value {
    final hex = bytes
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  @override
  String toString() => value;
}
