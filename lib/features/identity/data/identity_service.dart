import 'dart:convert';
import 'dart:typed_data';

import 'package:hafatra/core/crypto/crypto_service.dart';
import 'package:hafatra/core/database/app_database.dart';
import 'package:hafatra/core/errors/app_exception.dart';
import 'package:hafatra/core/logging/app_logger.dart';
import 'package:hafatra/core/utils/byte_utils.dart';
import 'package:hafatra/core/utils/clock.dart';
import 'package:hafatra/features/identity/data/secret_store.dart';
import 'package:hafatra/features/identity/domain/local_identity.dart';

/// Charge, crée et signe avec l'identité Ed25519 locale.
final class IdentityService {
  IdentityService({
    required AppDatabase database,
    required CryptoService crypto,
    required SecretStore secretStore,
    required Clock clock,
    required AppLogger logger,
  }) : _database = database,
       _crypto = crypto,
       _secretStore = secretStore,
       _clock = clock,
       _logger = logger;

  static const String _seedKey = 'hafatra.identity.seed.v1';

  final AppDatabase _database;
  final CryptoService _crypto;
  final SecretStore _secretStore;
  final Clock _clock;
  final AppLogger _logger;

  KeyMaterial? _material;
  LocalIdentity? _identity;

  LocalIdentity? get current => _identity;

  bool get hasIdentity => _identity != null;

  Future<LocalIdentity?> load() async {
    try {
      final encoded = await _secretStore.read(_seedKey);
      if (encoded == null || encoded.isEmpty) {
        _identity = null;
        _material = null;
        return null;
      }
      final seed = Uint8List.fromList(base64Decode(encoded));
      final material = await _crypto.keyMaterialFromSeed(seed);
      final id = await _deriveId(material.publicKey);
      final saved = await _database.getIdentity();
      final displayName = saved?.displayName.trim();
      final identity = LocalIdentity(
        id: id,
        publicKey: material.publicKey,
        displayName: displayName == null || displayName.isEmpty
            ? 'Voisin'
            : displayName,
        createdAt: saved?.createdAt ?? _clock.now(),
      );
      await _database.saveIdentity(
        id: identity.id,
        publicKey: identity.publicKey,
        displayName: identity.displayName,
        createdAt: identity.createdAt,
      );
      _material = material;
      _identity = identity;
      return identity;
    } on AppException {
      rethrow;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Identity load failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw CryptoException(
        'Impossible de charger l’identité locale.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<LocalIdentity> create({required String displayName}) async {
    final cleaned = displayName.trim();
    if (cleaned.isEmpty) {
      throw const ValidationException('Le nom affiché est requis.');
    }
    try {
      final material = await _crypto.generateKeyMaterial();
      final id = await _deriveId(material.publicKey);
      final identity = LocalIdentity(
        id: id,
        publicKey: material.publicKey,
        displayName: cleaned,
        createdAt: _clock.now(),
      );
      await _secretStore.write(_seedKey, base64Encode(material.seed));
      await _database.saveIdentity(
        id: identity.id,
        publicKey: identity.publicKey,
        displayName: identity.displayName,
        createdAt: identity.createdAt,
      );
      _material = material;
      _identity = identity;
      _logger.info(
        'Identity created (${ByteUtils.shortFingerprint(identity.publicKey)})',
      );
      return identity;
    } on AppException {
      rethrow;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Identity creation failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw CryptoException(
        'Impossible de créer l’identité locale.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<LocalIdentity> updateDisplayName(String displayName) async {
    final current = _identity;
    if (current == null) {
      throw const CryptoException('Aucune identité locale.');
    }
    final cleaned = displayName.trim();
    if (cleaned.isEmpty) {
      throw const ValidationException('Le nom affiché est requis.');
    }
    final updated = current.copyWith(displayName: cleaned);
    await _database.saveIdentity(
      id: updated.id,
      publicKey: updated.publicKey,
      displayName: updated.displayName,
      createdAt: updated.createdAt,
    );
    _identity = updated;
    return updated;
  }

  Future<Uint8List> sign(List<int> message) {
    final material = _material;
    if (material == null) {
      throw const CryptoException('La clé privée locale n’est pas chargée.');
    }
    return _crypto.sign(message, material);
  }

  Future<String> _deriveId(List<int> publicKey) async {
    final digest = await _crypto.sha256(publicKey);
    return ByteUtils.toHex(digest.take(8));
  }
}
