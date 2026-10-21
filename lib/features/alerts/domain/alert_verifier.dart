import 'package:hafatra/core/constants/mesh_constants.dart';
import 'package:hafatra/core/crypto/crypto_service.dart';
import 'package:hafatra/features/alerts/domain/signed_alert.dart';
import 'package:hafatra/features/alerts/domain/trusted_authority.dart';

enum AlertRejection {
  unknownAuthority,
  invalidAuthorityPeriod,
  invalidSignature,
  expired,
  issuedInFuture,
  replayed,
  malformed,
}

final class AlertVerification {
  const AlertVerification.accepted({
    required this.alert,
    required this.authority,
  }) : rejection = null;

  const AlertVerification.rejected(this.rejection)
    : alert = null,
      authority = null;

  final SignedAlert? alert;
  final TrustedAuthority? authority;
  final AlertRejection? rejection;

  bool get isAccepted => rejection == null;
}

/// Vérification pure, réutilisable par l'application et par la CLI.
final class AlertVerifier {
  const AlertVerifier(this._crypto);

  final CryptoService _crypto;

  Future<AlertVerification> verify({
    required SignedAlert alert,
    required List<TrustedAuthority> authorities,
    required DateTime now,
  }) async {
    TrustedAuthority? authority;
    for (final candidate in authorities) {
      if (candidate.id == alert.authorityId) {
        authority = candidate;
        break;
      }
    }
    if (authority == null) {
      return const AlertVerification.rejected(AlertRejection.unknownAuthority);
    }
    if (!authority.isValidAt(alert.issuedAt)) {
      return const AlertVerification.rejected(
        AlertRejection.invalidAuthorityPeriod,
      );
    }
    if (alert.isExpired(now)) {
      return const AlertVerification.rejected(AlertRejection.expired);
    }
    if (alert.issuedAt.isAfter(now.add(MeshConstants.alertFutureTolerance))) {
      return const AlertVerification.rejected(AlertRejection.issuedInFuture);
    }
    final valid = await _crypto.verify(
      message: alert.canonicalBytes(),
      signature: alert.signature,
      publicKey: authority.publicKey,
    );
    if (!valid) {
      return const AlertVerification.rejected(AlertRejection.invalidSignature);
    }
    return AlertVerification.accepted(alert: alert, authority: authority);
  }
}
