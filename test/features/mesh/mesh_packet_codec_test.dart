import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hafatra/core/constants/mesh_constants.dart';
import 'package:hafatra/core/crypto/crypto_service.dart';
import 'package:hafatra/core/utils/clock.dart';
import 'package:hafatra/core/utils/id_generator.dart';
import 'package:hafatra/features/mesh/data/codec/mesh_packet_codec.dart';
import 'package:hafatra/features/mesh/domain/mesh_packet.dart';

void main() {
  final crypto = CryptoService();
  final clock = FixedClock(DateTime.utc(2026, 10, 20, 9, 30));
  final idGenerator = SequentialIdGenerator(42);
  final codec = MeshPacketCodec(
    crypto: crypto,
    clock: clock,
    idGenerator: idGenerator,
  );
  final channelId = Uint8List.fromList(
    List<int>.generate(MeshConstants.channelIdLength, (index) => index + 1),
  );
  late KeyMaterial material;

  setUpAll(() async {
    final seed = Uint8List.fromList(
      List<int>.generate(32, (index) => 255 - index),
    );
    material = await crypto.keyMaterialFromSeed(seed);
  });

  Future<MeshPacket> createPacket({
    Uint8List? payload,
    int ttl = MeshConstants.defaultTtl,
  }) {
    return codec.createSignedPacket(
      type: MeshPacketType.chat,
      channelId: channelId,
      senderPublicKey: material.publicKey,
      payload:
          payload ?? Uint8List.fromList(utf8.encode('Bonjour le quartier')),
      signer: (message) => crypto.sign(message, material),
      ttl: ttl,
    );
  }

  group('MeshPacketCodec', () {
    test('encode puis décode un paquet sans perte', () async {
      final packet = await createPacket();
      final encoded = codec.encode(packet);
      final decoded = codec.decode(encoded);

      expect(
        encoded,
        hasLength(MeshConstants.headerLength + packet.payload.length),
      );
      expect(decoded.type, MeshPacketType.chat);
      expect(decoded.ttl, packet.ttl);
      expect(decoded.hopCount, 0);
      expect(decoded.messageId, orderedEquals(packet.messageId));
      expect(decoded.channelId, orderedEquals(channelId));
      expect(decoded.createdAt, clock.now());
      expect(decoded.senderId, orderedEquals(packet.senderId));
      expect(decoded.senderPublicKey, orderedEquals(material.publicKey));
      expect(decoded.signature, orderedEquals(packet.signature));
      expect(decoded.payload, orderedEquals(packet.payload));
      expect(await codec.verify(decoded), isTrue);
    });

    test('refuse une charge utile altérée en transit', () async {
      final encoded = codec.encode(await createPacket());
      encoded[MeshConstants.headerLength] ^= 0x01;

      final decoded = codec.decode(encoded);

      expect(await codec.verify(decoded), isFalse);
    });

    test('refuse un identifiant d’émetteur altéré', () async {
      final encoded = codec.encode(await createPacket());
      encoded[42] ^= 0x01;

      final decoded = codec.decode(encoded);

      expect(await codec.verify(decoded), isFalse);
    });

    test(
      'refuse un paquet dont la signature ne couvre pas le contenu',
      () async {
        final packet = await createPacket();
        final other = await codec.createSignedPacket(
          type: MeshPacketType.chat,
          channelId: channelId,
          senderPublicKey: material.publicKey,
          payload: Uint8List.fromList(utf8.encode('Autre message')),
          signer: (message) => crypto.sign(message, material),
        );
        final mixed = MeshPacket(
          type: packet.type,
          ttl: packet.ttl,
          hopCount: packet.hopCount,
          messageId: packet.messageId,
          channelId: packet.channelId,
          createdAt: packet.createdAt,
          senderId: packet.senderId,
          senderPublicKey: packet.senderPublicKey,
          signature: other.signature,
          payload: packet.payload,
        );

        expect(await codec.verify(mixed), isFalse);
      },
    );

    test('TTL et nombre de sauts restent hors signature mais bornés', () async {
      final packet = await createPacket();
      final relayed = packet.copyWith(ttl: 3, hopCount: 2);

      expect(await codec.verify(relayed), isTrue);

      final roundTrip = codec.decode(codec.encode(relayed));
      expect(roundTrip.ttl, 3);
      expect(roundTrip.hopCount, 2);

      final invalid = codec.encode(relayed);
      invalid[7] = MeshConstants.maxHopCount + 1;
      expect(() => codec.decode(invalid), throwsFormatException);
    });

    test('refuse un magic, une version ou une longueur invalides', () async {
      final encoded = codec.encode(await createPacket());

      final badMagic = Uint8List.fromList(encoded)..[0] = 0x00;
      expect(() => codec.decode(badMagic), throwsFormatException);

      final badVersion = Uint8List.fromList(encoded)..[4] = 99;
      expect(() => codec.decode(badVersion), throwsFormatException);

      final truncated = Uint8List.sublistView(encoded, 0, encoded.length - 1);
      expect(() => codec.decode(truncated), throwsFormatException);

      expect(
        () => codec.decode(Uint8List(MeshConstants.headerLength - 1)),
        throwsFormatException,
      );
    });

    test('refuse de créer un paquet avec un TTL hors limites', () async {
      expect(() => createPacket(ttl: 0), throwsArgumentError);
      expect(
        () => createPacket(ttl: MeshConstants.maxTtl + 1),
        throwsArgumentError,
      );
    });

    test('refuse un identifiant de paquet invalide', () {
      final packet = MeshPacket(
        type: MeshPacketType.chat,
        ttl: MeshConstants.defaultTtl,
        hopCount: 0,
        messageId: Uint8List(8),
        channelId: channelId,
        createdAt: clock.now(),
        senderId: Uint8List(MeshConstants.senderIdLength),
        senderPublicKey: material.publicKey,
        signature: Uint8List(MeshConstants.signatureLength),
        payload: Uint8List(0),
      );

      expect(() => codec.encode(packet), throwsFormatException);
    });
  });
}
