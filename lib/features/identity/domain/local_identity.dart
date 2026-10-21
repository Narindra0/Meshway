import 'dart:typed_data';

import 'package:hafatra/core/utils/byte_utils.dart';

/// Identité publique locale. La graine privée reste dans le Keystore.
final class LocalIdentity {
  const LocalIdentity({
    required this.id,
    required this.publicKey,
    required this.displayName,
    required this.createdAt,
  });

  final String id;
  final Uint8List publicKey;
  final String displayName;
  final DateTime createdAt;

  String get fingerprint => ByteUtils.shortFingerprint(publicKey, length: 8);

  String get publicKeyHex => ByteUtils.toHex(publicKey);

  LocalIdentity copyWith({String? displayName}) {
    return LocalIdentity(
      id: id,
      publicKey: publicKey,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt,
    );
  }
}
