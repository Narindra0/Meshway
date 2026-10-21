import 'dart:convert';
import 'dart:typed_data';

import 'package:hafatra/core/utils/byte_utils.dart';

enum AlertSeverity {
  info(0, 'alertSeverityInfo'),
  warning(1, 'alertSeverityWarning'),
  critical(2, 'alertSeverityCritical');

  AlertSeverity(this.value, this.labelKey);

  final int value;
  final String labelKey;

  static AlertSeverity fromValue(int value) {
    for (final severity in values) {
      if (severity.value == value) {
        return severity;
      }
    }
    return AlertSeverity.info;
  }

  static AlertSeverity fromJson(Object? value) {
    return switch (value) {
      'info' => AlertSeverity.info,
      'warning' => AlertSeverity.warning,
      'critical' => AlertSeverity.critical,
      final int number => fromValue(number),
      _ => AlertSeverity.info,
    };
  }

  String get jsonValue => name;
}

/// Alerte signée par une autorité de confiance.
final class SignedAlert {
  const SignedAlert({
    required this.authorityId,
    required this.alertId,
    required this.severity,
    required this.title,
    required this.body,
    required this.area,
    required this.issuedAt,
    required this.expiresAt,
    required this.signature,
  });

  factory SignedAlert.fromJson(Map<String, Object?> json) {
    final authorityId = json['authorityId'];
    final alertId = json['alertId'];
    final title = json['title'];
    final body = json['body'];
    final area = json['area'];
    final issuedAt = json['issuedAt'];
    final expiresAt = json['expiresAt'];
    final signature = json['signature'];
    if (authorityId is! String ||
        authorityId.trim().isEmpty ||
        alertId is! String ||
        alertId.trim().isEmpty ||
        title is! String ||
        title.trim().isEmpty ||
        body is! String ||
        body.trim().isEmpty ||
        area is! String ||
        issuedAt is! int ||
        expiresAt is! int ||
        signature is! String) {
      throw const FormatException('Champ d’alerte manquant ou invalide.');
    }
    final sig = Uint8List.fromList(base64Decode(signature));
    if (sig.length != 64) {
      throw const FormatException('Signature d’alerte invalide.');
    }
    if (title.length > 120 ||
        body.length > 1200 ||
        area.length > 120 ||
        alertId.length > 80) {
      throw const FormatException('Alerte trop volumineuse.');
    }
    if (expiresAt <= issuedAt) {
      throw const FormatException('Période de validité incohérente.');
    }
    return SignedAlert(
      authorityId: authorityId.trim(),
      alertId: alertId.trim(),
      severity: AlertSeverity.fromJson(json['severity']),
      title: title.trim(),
      body: body.trim(),
      area: area.trim(),
      issuedAt: DateTime.fromMillisecondsSinceEpoch(issuedAt, isUtc: true),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(expiresAt, isUtc: true),
      signature: sig,
    );
  }

  factory SignedAlert.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Fichier d’alerte invalide.');
    }
    return SignedAlert.fromJson(decoded);
  }

  final String authorityId;
  final String alertId;
  final AlertSeverity severity;
  final String title;
  final String body;
  final String area;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final Uint8List signature;

  bool isExpired(DateTime now) => !expiresAt.isAfter(now);

  String get signatureBase64 => base64Encode(signature);

  /// Représentation canonique, identique dans l'application et dans la CLI.
  Uint8List canonicalBytes() {
    final payload = <String, Object?>{
      'authorityId': authorityId,
      'alertId': alertId,
      'severity': severity.jsonValue,
      'title': title,
      'body': body,
      'area': area,
      'issuedAt': issuedAt.toUtc().millisecondsSinceEpoch,
      'expiresAt': expiresAt.toUtc().millisecondsSinceEpoch,
    };
    return Uint8List.fromList(utf8.encode(jsonEncode(payload)));
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'authorityId': authorityId,
      'alertId': alertId,
      'severity': severity.jsonValue,
      'title': title,
      'body': body,
      'area': area,
      'issuedAt': issuedAt.toUtc().millisecondsSinceEpoch,
      'expiresAt': expiresAt.toUtc().millisecondsSinceEpoch,
      'signature': signatureBase64,
    };
  }

  String get shortId =>
      alertId.length <= 8 ? alertId : alertId.substring(0, 8).toUpperCase();

  String get signatureFingerprint => ByteUtils.shortFingerprint(signature);
}
