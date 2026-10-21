import 'dart:convert';
import 'dart:typed_data';

import 'package:hafatra/core/constants/mesh_constants.dart';
import 'package:hafatra/core/crypto/crypto_service.dart';
import 'package:hafatra/core/utils/byte_utils.dart';
import 'package:hafatra/core/utils/clock.dart';
import 'package:hafatra/core/utils/id_generator.dart';
import 'package:hafatra/features/mesh/domain/mesh_packet.dart';

typedef PacketSigner = Future<Uint8List> Function(Uint8List message);

/// Encode, decode et verifie l'enveloppe binaire HFT1.
final class MeshPacketCodec {
  const MeshPacketCodec({
    required CryptoService crypto,
    required Clock clock,
    required IdGenerator idGenerator,
  }) : _crypto = crypto,
       _clock = clock,
       _idGenerator = idGenerator;

  final CryptoService _crypto;
  final Clock _clock;
  final IdGenerator _idGenerator;

  Future<MeshPacket> createSignedPacket({
    required MeshPacketType type,
    required Uint8List channelId,
    required Uint8List senderPublicKey,
    required Uint8List payload,
    required PacketSigner signer,
    int ttl = MeshConstants.defaultTtl,
  }) async {
    if (channelId.length != MeshConstants.channelIdLength) {
      throw ArgumentError.value(
        channelId.length,
        'channelId',
        '${MeshConstants.channelIdLength} octets attendus',
      );
    }
    if (senderPublicKey.length != MeshConstants.publicKeyLength) {
      throw ArgumentError.value(
        senderPublicKey.length,
        'senderPublicKey',
        '${MeshConstants.publicKeyLength} octets attendus',
      );
    }
    if (payload.length >
        MeshConstants.maxPacketLength - MeshConstants.headerLength) {
      throw ArgumentError.value(payload.length, 'payload', 'Paquet trop grand');
    }
    if (ttl < MeshConstants.minTtl || ttl > MeshConstants.maxTtl) {
      throw ArgumentError.value(ttl, 'ttl', 'TTL hors limites');
    }
    final digest = await _crypto.sha256(senderPublicKey);
    final senderId = Uint8List.fromList(
      digest.take(MeshConstants.senderIdLength).toList(),
    );
    final unsigned = MeshPacket(
      type: type,
      ttl: ttl,
      hopCount: 0,
      messageId: _idGenerator.nextBytes(),
      channelId: channelId,
      createdAt: _clock.now().toUtc(),
      senderId: senderId,
      senderPublicKey: senderPublicKey,
      signature: Uint8List(MeshConstants.signatureLength),
      payload: Uint8List.fromList(payload),
    );
    final signature = await signer(signedBytes(unsigned));
    if (signature.length != MeshConstants.signatureLength) {
      throw StateError('Signature Ed25519 de taille invalide.');
    }
    return unsigned.copyWith(signature: signature);
  }

  /// Partie couverte par la signature : TTL, hopCount et signature exclus.
  Uint8List signedBytes(MeshPacket packet) {
    final payloadLength = packet.payload.length;
    final builder = BytesBuilder(copy: false)
      ..add(ascii.encode(MeshConstants.magic))
      ..addByte(MeshConstants.protocolVersion)
      ..addByte(packet.type.value)
      ..add([(payloadLength >> 8) & 0xff, payloadLength & 0xff])
      ..add(packet.messageId)
      ..add(packet.channelId)
      ..add(_uint64(packet.createdAt.millisecondsSinceEpoch))
      ..add(packet.senderId)
      ..add(packet.senderPublicKey)
      ..add(packet.payload);
    return builder.takeBytes();
  }

  Uint8List encode(MeshPacket packet) {
    if (!packet.hasValidFieldLengths()) {
      throw const FormatException('Champs de paquet invalides.');
    }
    if (packet.ttl > MeshConstants.maxTtl ||
        packet.hopCount > MeshConstants.maxHopCount) {
      throw const FormatException('TTL ou nombre de sauts invalide.');
    }
    final bytes = Uint8List(MeshConstants.headerLength + packet.payload.length)
      ..setRange(0, 4, ascii.encode(MeshConstants.magic))
      ..[4] = MeshConstants.protocolVersion
      ..[5] = packet.type.value
      ..[6] = packet.ttl
      ..[7] = packet.hopCount;
    ByteUtils.writeUint16(bytes, 8, packet.payload.length);
    bytes
      ..setRange(10, 26, packet.messageId)
      ..setRange(26, 34, packet.channelId)
      ..setRange(42, 50, packet.senderId)
      ..setRange(50, 82, packet.senderPublicKey)
      ..setRange(82, 146, packet.signature)
      ..setRange(146, bytes.length, packet.payload);
    ByteUtils.writeUint64(bytes, 34, packet.createdAt.millisecondsSinceEpoch);
    return bytes;
  }

  MeshPacket decode(Uint8List bytes) {
    if (bytes.length < MeshConstants.headerLength) {
      throw const FormatException('Paquet trop court.');
    }
    if (bytes[0] != 0x48 ||
        bytes[1] != 0x46 ||
        bytes[2] != 0x54 ||
        bytes[3] != 0x31) {
      throw const FormatException('Magic HFT1 absent.');
    }
    if (bytes[4] != MeshConstants.protocolVersion) {
      throw const FormatException('Version de protocole inconnue.');
    }
    final type = MeshPacketType.fromValue(bytes[5]);
    if (type == null) {
      throw const FormatException('Type de paquet inconnu.');
    }
    final ttl = bytes[6];
    final hopCount = bytes[7];
    if (ttl > MeshConstants.maxTtl || hopCount > MeshConstants.maxHopCount) {
      throw const FormatException('TTL ou nombre de sauts invalide.');
    }
    final payloadLength = ByteUtils.readUint16(bytes, 8);
    if (payloadLength >
        MeshConstants.maxPacketLength - MeshConstants.headerLength) {
      throw const FormatException('Charge utile trop grande.');
    }
    if (bytes.length != MeshConstants.headerLength + payloadLength) {
      throw const FormatException('Longueur de paquet incoherente.');
    }
    final createdAtMillis = ByteUtils.readUint64(bytes, 34);
    if (createdAtMillis <= 0 || createdAtMillis > 4102444800000) {
      throw const FormatException('Horodatage de paquet invalide.');
    }
    return MeshPacket(
      type: type,
      ttl: ttl,
      hopCount: hopCount,
      messageId: Uint8List.sublistView(bytes, 10, 26),
      channelId: Uint8List.sublistView(bytes, 26, 34),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        createdAtMillis,
        isUtc: true,
      ),
      senderId: Uint8List.sublistView(bytes, 42, 50),
      senderPublicKey: Uint8List.sublistView(bytes, 50, 82),
      signature: Uint8List.sublistView(bytes, 82, 146),
      payload: Uint8List.sublistView(bytes, 146),
    );
  }

  Future<bool> verify(MeshPacket packet) async {
    if (!packet.hasValidFieldLengths()) {
      return false;
    }
    if (packet.ttl > MeshConstants.maxTtl ||
        packet.hopCount > MeshConstants.maxHopCount) {
      return false;
    }
    final digest = await _crypto.sha256(packet.senderPublicKey);
    final expectedSender = digest.take(MeshConstants.senderIdLength).toList();
    if (!ByteUtils.constantTimeEquals(expectedSender, packet.senderId)) {
      return false;
    }
    return await _crypto.verify(
      message: signedBytes(packet),
      signature: packet.signature,
      publicKey: packet.senderPublicKey,
    );
  }

  static Uint8List _uint64(int value) {
    final bytes = Uint8List(8);
    ByteUtils.writeUint64(bytes, 0, value);
    return bytes;
  }
}
