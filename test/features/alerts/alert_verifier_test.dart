import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hafatra/core/constants/mesh_constants.dart';
import 'package:hafatra/core/crypto/crypto_service.dart';
import 'package:hafatra/features/alerts/domain/alert_verifier.dart';
import 'package:hafatra/features/alerts/domain/signed_alert.dart';
import 'package:hafatra/features/alerts/domain/trusted_authority.dart';

void main() {
  final crypto = CryptoService();
  final now = DateTime.utc(2026, 10, 20, 10);
  late KeyMaterial authorityKey;
  late KeyMaterial attackerKey;
  late TrustedAuthority authority;

  setUpAll(() async {
    authorityKey = await crypto.keyMaterialFromSeed(
      Uint8List.fromList(List<int>.generate(32, (index) => index + 1)),
    );
    attackerKey = await crypto.keyMaterialFromSeed(
      Uint8List.fromList(List<int>.generate(32, (index) => index + 101)),
    );
    authority = TrustedAuthority(
      id: 'authority-test',
      name: 'Autorité de test',
      publicKey: authorityKey.publicKey,
      validFrom: DateTime.utc(2026),
      validTo: DateTime.utc(2027),
    );
  });

  Future<SignedAlert> signedAlert({
    String authorityId = 'authority-test',
    DateTime? issuedAt,
    DateTime? expiresAt,
    String title = 'Fortes pluies',
    KeyMaterial? signer,
  }) async {
    final alert = SignedAlert(
      authorityId: authorityId,
      alertId: 'alert-test-001',
      severity: AlertSeverity.warning,
      title: title,
      body: 'Évitez les zones basses et prévenez vos voisins.',
      area: 'Antananarivo',
      issuedAt: issuedAt ?? now.subtract(const Duration(minutes: 5)),
      expiresAt: expiresAt ?? now.add(const Duration(hours: 12)),
      signature: Uint8List(MeshConstants.signatureLength),
    );
    final signature = await crypto.sign(
      alert.canonicalBytes(),
      signer ?? authorityKey,
    );
    return SignedAlert(
      authorityId: alert.authorityId,
      alertId: alert.alertId,
      severity: alert.severity,
      title: alert.title,
      body: alert.body,
      area: alert.area,
      issuedAt: alert.issuedAt,
      expiresAt: alert.expiresAt,
      signature: signature,
    );
  }

  group('AlertVerifier', () {
    test('accepte une alerte signée par une autorité connue', () async {
      final alert = await signedAlert();
      final result = await AlertVerifier(crypto)
          .verify(alert: alert, authorities: [authority], now: now);

      expect(result.isAccepted, isTrue);
      expect(result.rejection, isNull);
      expect(result.alert?.alertId, alert.alertId);
      expect(result.authority?.id, authority.id);
    });

    test('refuse une autorité inconnue', () async {
      final alert = await signedAlert(authorityId: 'autre-autorite');
      final result = await AlertVerifier(crypto)
          .verify(alert: alert, authorities: [authority], now: now);

      expect(result.isAccepted, isFalse);
      expect(result.rejection, AlertRejection.unknownAuthority);
    });

    test('refuse une alerte expirée', () async {
      final alert = await signedAlert(
        issuedAt: now.subtract(const Duration(days: 2)),
        expiresAt: now.subtract(const Duration(days: 1)),
      );
      final result = await AlertVerifier(crypto)
          .verify(alert: alert, authorities: [authority], now: now);

      expect(result.isAccepted, isFalse);
      expect(result.rejection, AlertRejection.expired);
    });

    test('refuse une alerte émise après la fenêtre de tolérance', () async {
      final issuedAt = now.add(
        MeshConstants.alertFutureTolerance + const Duration(minutes: 1),
      );
      final alert = await signedAlert(
        issuedAt: issuedAt,
        expiresAt: issuedAt.add(const Duration(hours: 1)),
      );
      final result = await AlertVerifier(crypto)
          .verify(alert: alert, authorities: [authority], now: now);

      expect(result.isAccepted, isFalse);
      expect(result.rejection, AlertRejection.issuedInFuture);
    });

    test('refuse une alerte émise hors période de l’autorité', () async {
      final alert = await signedAlert(
        issuedAt: DateTime.utc(2025, 12, 31, 23, 55),
        expiresAt: DateTime.utc(2026, 1, 1, 12),
      );
      final result = await AlertVerifier(crypto)
          .verify(alert: alert, authorities: [authority], now: now);

      expect(result.isAccepted, isFalse);
      expect(result.rejection, AlertRejection.invalidAuthorityPeriod);
    });

    test('refuse une signature altérée', () async {
      final alert = await signedAlert(signer: attackerKey);
      final result = await AlertVerifier(crypto)
          .verify(alert: alert, authorities: [authority], now: now);

      expect(result.isAccepted, isFalse);
      expect(result.rejection, AlertRejection.invalidSignature);
    });

    test('refuse un contenu modifié après signature', () async {
      final original = await signedAlert(title: 'Inondation');
      final tampered = SignedAlert(
        authorityId: original.authorityId,
        alertId: original.alertId,
        severity: original.severity,
        title: 'Inondation — évacuation immédiate',
        body: original.body,
        area: original.area,
        issuedAt: original.issuedAt,
        expiresAt: original.expiresAt,
        signature: original.signature,
      );
      final result = await AlertVerifier(crypto)
          .verify(alert: tampered, authorities: [authority], now: now);

      expect(result.isAccepted, isFalse);
      expect(result.rejection, AlertRejection.invalidSignature);
    });

    test('refuse un JSON d’alerte incomplet ou invalide', () {
      expect(
        () => SignedAlert.fromJsonString('{"authorityId":"a","alertId":"b"}'),
        throwsFormatException,
      );
      expect(() => SignedAlert.fromJsonString('[]'), throwsFormatException);
    });
  });

  group('Actifs de démonstration', () {
    test('l’alerte embarquée est valide avec l’autorité embarquée', () async {
      final authoritySource = await File('assets/trusted_authorities.json')
          .readAsString();
      final alertSource = await File('assets/demo/demo_alert.json')
          .readAsString();
      final authorities = TrustedAuthority.listFromJsonString(authoritySource);
      final alert = SignedAlert.fromJsonString(alertSource);
      final result = await AlertVerifier(crypto)
          .verify(alert: alert, authorities: authorities, now: now);

      expect(result.isAccepted, isTrue, reason: '${result.rejection}');
      expect(alert.alertId, 'demo-cyclone-001');
    });
  });
}
