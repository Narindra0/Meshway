import 'dart:convert';
import 'dart:typed_data';

import 'package:hafatra/core/utils/byte_utils.dart';

/// Contenu d'un message de salon public.
final class ChatPayload {
  const ChatPayload({required this.senderName, required this.text});

  final String senderName;
  final String text;
}

abstract final class ChatPayloadCodec {
  static Uint8List encode(ChatPayload payload) {
    return Uint8List.fromList(
      utf8.encode(
        jsonEncode({'n': payload.senderName.trim(), 't': payload.text}),
      ),
    );
  }

  static ChatPayload decode(Uint8List bytes) {
    final decoded = jsonDecode(utf8.decode(bytes, allowMalformed: false));
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Charge utile de chat invalide.');
    }
    final name = decoded['n'];
    final text = decoded['t'];
    if (name is! String || text is! String) {
      throw const FormatException('Champs de chat manquants.');
    }
    if (name.trim().isEmpty || name.length > 40) {
      throw const FormatException('Nom affiché invalide.');
    }
    if (text.trim().isEmpty || utf8.encode(text).length > 512) {
      throw const FormatException('Message invalide.');
    }
    return ChatPayload(senderName: name.trim(), text: text);
  }
}

/// Accusé de réception d'un message de salon.
final class DeliveryAckPayload {
  const DeliveryAckPayload({required this.messageId, required this.status});

  final String messageId;
  final int status;
}

abstract final class DeliveryAckCodec {
  static Uint8List encode(DeliveryAckPayload payload) {
    final id = ByteUtils.fromHex(payload.messageId.replaceAll('-', ''));
    if (id.length != 16) {
      throw ArgumentError.value(payload.messageId, 'messageId', '16 octets');
    }
    return Uint8List(17)
      ..setRange(0, 16, id)
      ..[16] = payload.status;
  }

  static DeliveryAckPayload decode(Uint8List bytes) {
    if (bytes.length != 17) {
      throw const FormatException('Accusé de réception invalide.');
    }
    return DeliveryAckPayload(
      messageId: ByteUtils.canonicalUuid(bytes.sublist(0, 16)),
      status: bytes[16],
    );
  }
}

/// Preuve qu'un relais a observé le message ciblé.
final class RelayReceiptPayload {
  const RelayReceiptPayload({required this.messageId, required this.hops});

  final String messageId;
  final int hops;
}

abstract final class RelayReceiptCodec {
  static Uint8List encode(RelayReceiptPayload payload) {
    final id = ByteUtils.fromHex(payload.messageId.replaceAll('-', ''));
    if (id.length != 16) {
      throw ArgumentError.value(payload.messageId, 'messageId', '16 octets');
    }
    return Uint8List(17)
      ..setRange(0, 16, id)
      ..[16] = payload.hops;
  }

  static RelayReceiptPayload decode(Uint8List bytes) {
    if (bytes.length != 17) {
      throw const FormatException('Reçu de relais invalide.');
    }
    return RelayReceiptPayload(
      messageId: ByteUtils.canonicalUuid(bytes.sublist(0, 16)),
      hops: bytes[16],
    );
  }
}
