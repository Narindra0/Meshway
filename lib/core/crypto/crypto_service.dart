import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography_plus/cryptography_plus.dart';

/// Matériel de clé Ed25519 manipulé uniquement en mémoire.
final class KeyMaterial {
  const KeyMaterial({required this.seed, required this.publicKey});

  final Uint8List seed;
  final Uint8List publicKey;
}

/// Façade unique pour les primitives cryptographiques de Hafatra.
final class CryptoService {
  CryptoService({Ed25519? ed25519}) : _ed25519 = ed25519 ?? Ed25519();

  final Ed25519 _ed25519;

  Future<KeyMaterial> generateKeyMaterial() {
    final random = Random.secure();
    final seed = Uint8List(32);
    for (var i = 0; i < seed.length; i++) {
      seed[i] = random.nextInt(256);
    }
    return keyMaterialFromSeed(seed);
  }

  Future<KeyMaterial> keyMaterialFromSeed(Uint8List seed) async {
    if (seed.length != 32) {
      throw ArgumentError.value(seed.length, 'seed', '32 octets attendus');
    }
    final pair = await _ed25519.newKeyPairFromSeed(seed);
    final publicKey = await pair.extractPublicKey();
    return KeyMaterial(
      seed: Uint8List.fromList(seed),
      publicKey: Uint8List.fromList(publicKey.bytes),
    );
  }

  Future<Uint8List> sign(List<int> message, KeyMaterial material) async {
    final pair = await _ed25519.newKeyPairFromSeed(material.seed);
    final signature = await _ed25519.sign(message, keyPair: pair);
    return Uint8List.fromList(signature.bytes);
  }

  Future<bool> verify({
    required List<int> message,
    required List<int> signature,
    required List<int> publicKey,
  }) async {
    if (signature.length != 64 || publicKey.length != 32) {
      return false;
    }
    try {
      return await _ed25519.verify(
        message,
        signature: Signature(
          signature,
          publicKey: SimplePublicKey(publicKey, type: KeyPairType.ed25519),
        ),
      );
    } on Object {
      return false;
    }
  }

  Future<Uint8List> sha256(List<int> bytes) async {
    final hash = await Sha256().hash(bytes);
    return Uint8List.fromList(hash.bytes);
  }

  Future<String> sha256Hex(List<int> bytes) async {
    final digest = await sha256(bytes);
    return digest.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
