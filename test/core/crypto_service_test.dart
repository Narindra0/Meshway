import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hafatra/core/crypto/crypto_service.dart';

void main() {
  final crypto = CryptoService();
  final seed = Uint8List.fromList(List<int>.generate(32, (index) => index));
  late KeyMaterial material;

  setUpAll(() async {
    material = await crypto.keyMaterialFromSeed(seed);
  });

  group('CryptoService', () {
    test('dérive la même clé publique depuis une graine', () async {
      final again = await crypto.keyMaterialFromSeed(seed);

      expect(again.seed, orderedEquals(seed));
      expect(again.publicKey, orderedEquals(material.publicKey));
      expect(material.publicKey, hasLength(32));
    });

    test('signe puis vérifie un message avec la bonne clé', () async {
      final message = utf8.encode('Hafatra — message de test');
      final signature = await crypto.sign(message, material);

      expect(signature, hasLength(64));
      expect(
        await crypto.verify(
          message: message,
          signature: signature,
          publicKey: material.publicKey,
        ),
        isTrue,
      );
    });

    test('refuse un message modifié après signature', () async {
      final message = utf8.encode('message original');
      final signature = await crypto.sign(message, material);

      expect(
        await crypto.verify(
          message: utf8.encode('message altéré'),
          signature: signature,
          publicKey: material.publicKey,
        ),
        isFalse,
      );
    });

    test('refuse une signature altérée', () async {
      final message = utf8.encode('message');
      final signature = await crypto.sign(message, material);
      final tampered = Uint8List.fromList(signature);
      tampered[0] ^= 0x01;

      expect(
        await crypto.verify(
          message: message,
          signature: tampered,
          publicKey: material.publicKey,
        ),
        isFalse,
      );
    });

    test(
      'refuse une clé publique ou une signature de taille invalide',
      () async {
        expect(
          await crypto.verify(
            message: const [1, 2, 3],
            signature: Uint8List(64),
            publicKey: Uint8List(16),
          ),
          isFalse,
        );
        expect(
          await crypto.verify(
            message: const [1, 2, 3],
            signature: Uint8List(63),
            publicKey: material.publicKey,
          ),
          isFalse,
        );
      },
    );

    test('calcule SHA-256 au format hexadécimal', () async {
      expect(
        await crypto.sha256Hex(utf8.encode('abc')),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('refuse une graine de taille incorrecte', () async {
      expect(
        () => crypto.keyMaterialFromSeed(Uint8List(16)),
        throwsArgumentError,
      );
    });
  });
}
