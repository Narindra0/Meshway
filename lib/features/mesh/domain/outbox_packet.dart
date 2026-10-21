import 'dart:typed_data';

final class OutboxPacket {
  const OutboxPacket({
    required this.packetId,
    required this.messageId,
    required this.bytes,
    required this.priority,
    required this.attempts,
    required this.createdAt,
    required this.expiresAt,
  });

  final String packetId;
  final String messageId;
  final Uint8List bytes;
  final int priority;
  final int attempts;
  final DateTime createdAt;
  final DateTime expiresAt;
}
