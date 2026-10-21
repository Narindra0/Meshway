import 'dart:convert';
import 'dart:typed_data';

import 'package:hafatra/core/crypto/crypto_service.dart';
import 'package:hafatra/core/utils/byte_utils.dart';

/// Salon public de quartier. Le code partagé n'est pas une clé de chiffrement.
final class ChannelInfo {
  const ChannelInfo({
    required this.id,
    required this.code,
    required this.name,
    required this.joinedAt,
  });

  final String id;
  final String code;
  final String name;
  final DateTime joinedAt;

  /// Identifiant binaire de 8 octets utilisé dans l'en-tête de paquet.
  Uint8List get idBytes => ByteUtils.fromHex(id);

  static String normalizeCode(String raw) {
    return raw.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
  }

  static Future<String> deriveId(String code, CryptoService crypto) async {
    final normalized = normalizeCode(code);
    final digest = await crypto.sha256(
      utf8.encode('hafatra:neighborhood:$normalized'),
    );
    return ByteUtils.toHex(digest.take(8));
  }

  static Future<ChannelInfo> create({
    required String code,
    required String name,
    required CryptoService crypto,
    required DateTime joinedAt,
  }) async {
    final normalized = normalizeCode(code);
    final id = await deriveId(normalized, crypto);
    return ChannelInfo(
      id: id,
      code: normalized,
      name: name.trim(),
      joinedAt: joinedAt,
    );
  }
}
