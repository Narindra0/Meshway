import 'dart:typed_data';

import 'package:hafatra/core/constants/mesh_constants.dart';
import 'package:hafatra/core/utils/byte_utils.dart';

/// Enveloppe binaire signée qui circule sur tous les transports.
final class MeshPacket {
  const MeshPacket({
    required this.type,
    required this.ttl,
    required this.hopCount,
    required this.messageId,
    required this.channelId,
    required this.createdAt,
    required this.senderId,
    required this.senderPublicKey,
    required this.signature,
    required this.payload,
  });

  final MeshPacketType type;
  final int ttl;
  final int hopCount;
  final Uint8List messageId;
  final Uint8List channelId;
  final DateTime createdAt;
  final Uint8List senderId;
  final Uint8List senderPublicKey;
  final Uint8List signature;
  final Uint8List payload;

  String get messageIdHex => ByteUtils.toHex(messageId);

  String get senderIdHex => ByteUtils.toHex(senderId);

  String get channelIdHex => ByteUtils.toHex(channelId);

  MeshPacket copyWith({int? ttl, int? hopCount, Uint8List? signature}) {
    return MeshPacket(
      type: type,
      ttl: ttl ?? this.ttl,
      hopCount: hopCount ?? this.hopCount,
      messageId: messageId,
      channelId: channelId,
      createdAt: createdAt,
      senderId: senderId,
      senderPublicKey: senderPublicKey,
      signature: signature ?? this.signature,
      payload: payload,
    );
  }

  bool hasValidFieldLengths() {
    return messageId.length == MeshConstants.messageIdLength &&
        channelId.length == MeshConstants.channelIdLength &&
        senderId.length == MeshConstants.senderIdLength &&
        senderPublicKey.length == MeshConstants.publicKeyLength &&
        signature.length == MeshConstants.signatureLength &&
        payload.length <=
            MeshConstants.maxPacketLength - MeshConstants.headerLength;
  }

  @override
  String toString() {
    return 'MeshPacket(type: ${type.name}, ttl: $ttl, hop: $hopCount, '
        'id: ${messageIdHex.substring(0, 8)}, sender: '
        '${senderIdHex.substring(0, 8)})';
  }
}
