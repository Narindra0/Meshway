import 'dart:convert';

import 'package:hafatra/core/constants/app_constants.dart';
import 'package:hafatra/core/crypto/crypto_service.dart';
import 'package:hafatra/core/database/app_database.dart';
import 'package:hafatra/core/errors/app_exception.dart';
import 'package:hafatra/core/logging/app_logger.dart';
import 'package:hafatra/core/utils/clock.dart';
import 'package:hafatra/features/identity/domain/channel_info.dart';

/// Persiste le salon de quartier local.
final class ChannelService {
  ChannelService({
    required AppDatabase database,
    required CryptoService crypto,
    required Clock clock,
    required AppLogger logger,
  }) : _database = database,
       _crypto = crypto,
       _clock = clock,
       _logger = logger;

  final AppDatabase _database;
  final CryptoService _crypto;
  final Clock _clock;
  final AppLogger _logger;

  Future<ChannelInfo?> load() async {
    final row = await _database.getChannel();
    if (row == null) {
      return null;
    }
    return ChannelInfo(
      id: row.id,
      code: row.code,
      name: row.name,
      joinedAt: row.joinedAt,
    );
  }

  Future<ChannelInfo> create({
    required String code,
    required String name,
  }) async {
    final normalized = ChannelInfo.normalizeCode(code);
    if (normalized.length < AppConstants.minChannelCodeLength) {
      throw const ValidationException('Le code du quartier est trop court.');
    }
    if (normalized.length > AppConstants.maxChannelCodeLength) {
      throw const ValidationException('Le code du quartier est trop long.');
    }
    try {
      final channel = await ChannelInfo.create(
        code: normalized,
        name: name,
        crypto: _crypto,
        joinedAt: _clock.now(),
      );
      final codeHash = await _crypto.sha256(utf8.encode(channel.code));
      await _database.saveChannel(
        id: channel.id,
        code: channel.code,
        codeHash: codeHash,
        name: channel.name,
        joinedAt: channel.joinedAt,
      );
      _logger.info('Channel joined (${channel.id})');
      return channel;
    } on AppException {
      rethrow;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Channel join failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw StorageException(
        'Impossible d’enregistrer le salon.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
