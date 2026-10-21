import 'dart:async';
import 'dart:convert';

import 'package:hafatra/core/database/app_database.dart';
import 'package:hafatra/core/errors/app_exception.dart';
import 'package:hafatra/core/logging/app_logger.dart';
import 'package:hafatra/core/utils/clock.dart';
import 'package:hafatra/features/alerts/data/trusted_authority_source.dart';
import 'package:hafatra/features/alerts/domain/alert_verifier.dart';
import 'package:hafatra/features/alerts/domain/signed_alert.dart';
import 'package:hafatra/features/alerts/domain/trusted_authority.dart';

/// Vérifie, déduplique et persiste les alertes signées.
final class AlertService {
  AlertService({
    required AppDatabase database,
    required AlertVerifier verifier,
    required TrustedAuthoritySource authoritySource,
    required Clock clock,
    required AppLogger logger,
  }) : _database = database,
       _verifier = verifier,
       _authoritySource = authoritySource,
       _clock = clock,
       _logger = logger;

  final AppDatabase _database;
  final AlertVerifier _verifier;
  final TrustedAuthoritySource _authoritySource;
  final Clock _clock;
  final AppLogger _logger;
  final StreamController<SignedAlert> _verified =
      StreamController<SignedAlert>.broadcast();

  Stream<SignedAlert> get verifiedAlerts => _verified.stream;

  Future<List<TrustedAuthority>> get authorities => _authoritySource.load();

  Future<AlertVerification> verifyAndStore(SignedAlert alert) async {
    try {
      final authorities = await _authoritySource.load();
      final now = _clock.now();
      final result = await _verifier.verify(
        alert: alert,
        authorities: authorities,
        now: now,
      );
      if (!result.isAccepted) {
        _logger.warning(
          'Alert rejected (${result.rejection?.name}, ${alert.shortId})',
        );
        return result;
      }
      final existing = await _database.getAlert(alert.alertId);
      if (existing != null) {
        _logger.info('Alert replayed and ignored (${alert.shortId})');
        return const AlertVerification.rejected(AlertRejection.replayed);
      }
      final authority = result.authority;
      if (authority == null) {
        return const AlertVerification.rejected(
          AlertRejection.unknownAuthority,
        );
      }
      await _database.saveAlert(
        TrustedAlertsCompanion.insert(
          alertId: alert.alertId,
          authorityId: alert.authorityId,
          payload: jsonEncode(alert.toJson()),
          severity: alert.severity.value,
          title: alert.title,
          body: alert.body,
          receivedAt: now,
          expiresAt: alert.expiresAt,
        ),
      );
      _logger.info(
        'Verified alert stored (${alert.shortId}, authority=${authority.id})',
      );
      if (!_verified.isClosed) {
        _verified.add(alert);
      }
      return result;
    } on AppException {
      rethrow;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Alert verification failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw CryptoException(
        'Impossible de vérifier l’alerte.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Vérifie une alerte de démonstration sans la diffuser.
  Future<AlertVerification> verifyOnly(SignedAlert alert) async {
    return await _verifier.verify(
      alert: alert,
      authorities: await _authoritySource.load(),
      now: _clock.now(),
    );
  }

  Future<void> dispose() => _verified.close();
}
