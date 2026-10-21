import 'dart:convert';
import 'dart:typed_data';

import 'package:hafatra/core/utils/byte_utils.dart';

/// Clé publique d'une autorité autorisée à émettre des alertes.
final class TrustedAuthority {
  const TrustedAuthority({
    required this.id,
    required this.name,
    required this.publicKey,
    required this.validFrom,
    required this.validTo,
  });

  factory TrustedAuthority.fromJson(Map<String, Object?> json) {
    final id = json['id'];
    final name = json['name'];
    final publicKey = json['publicKey'];
    final validFrom = json['validFrom'];
    final validTo = json['validTo'];
    if (id is! String ||
        id.trim().isEmpty ||
        name is! String ||
        name.trim().isEmpty ||
        publicKey is! String ||
        validFrom is! String ||
        validTo is! String) {
      throw const FormatException('Autorité de confiance invalide.');
    }
    final key = ByteUtils.fromHex(publicKey);
    if (key.length != 32) {
      throw const FormatException('Clé publique d’autorité invalide.');
    }
    return TrustedAuthority(
      id: id.trim(),
      name: name.trim(),
      publicKey: key,
      validFrom: DateTime.parse(validFrom).toUtc(),
      validTo: DateTime.parse(validTo).toUtc(),
    );
  }

  final String id;
  final String name;
  final Uint8List publicKey;
  final DateTime validFrom;
  final DateTime validTo;

  String get fingerprint => ByteUtils.shortFingerprint(publicKey);

  bool isValidAt(DateTime moment) {
    return !moment.isBefore(validFrom) && !moment.isAfter(validTo);
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'publicKey': ByteUtils.toHex(publicKey),
      'validFrom': validFrom.toUtc().toIso8601String(),
      'validTo': validTo.toUtc().toIso8601String(),
    };
  }

  static List<TrustedAuthority> listFromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Liste d’autorités invalide.');
    }
    final items = decoded['authorities'];
    if (items is! List<Object?>) {
      throw const FormatException('Clé "authorities" absente.');
    }
    return items
        .whereType<Map<String, Object?>>()
        .map(TrustedAuthority.fromJson)
        .toList(growable: false);
  }
}
