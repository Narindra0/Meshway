import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:hafatra/core/crypto/crypto_service.dart';
import 'package:hafatra/core/utils/byte_utils.dart';
import 'package:hafatra/features/alerts/domain/alert_verifier.dart';
import 'package:hafatra/features/alerts/domain/signed_alert.dart';
import 'package:hafatra/features/alerts/domain/trusted_authority.dart';

/// Outil hors application pour gérer les autorités d'alerte.
///
/// Exemples :
///   dart run tool/alert_tool.dart init --out tool/demo_authority.json \
///     --authorities assets/trusted_authorities.json
///   dart run tool/alert_tool.dart sign --key tool/demo_authority.json \
///     --out assets/demo/demo_alert.json --severity warning
///   dart run tool/alert_tool.dart verify --alert assets/demo/demo_alert.json \
///     --authorities assets/trusted_authorities.json
Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty || arguments.first == '--help') {
    _printUsage();
    return;
  }
  final command = arguments.first;
  final options = _parseOptions(arguments.skip(1).toList());
  try {
    switch (command) {
      case 'init':
        await _init(options);
      case 'sign':
        await _sign(options);
      case 'verify':
        await _verify(options);
      default:
        stderr.writeln('Commande inconnue : $command');
        _printUsage();
        exitCode = 64;
    }
  } on Object catch (error, stackTrace) {
    stderr.writeln('Échec : $error');
    if (options['verbose'] == 'true') {
      stderr.writeln(stackTrace);
    }
    exitCode = 1;
  }
}

Future<void> _init(Map<String, String> options) async {
  final outPath = options['out'] ?? 'tool/demo_authority.json';
  final authoritiesPath =
      options['authorities'] ?? 'assets/trusted_authorities.json';
  final id = options['id'] ?? 'demo-hafatra';
  final name = options['name'] ?? 'Autorité de démonstration (non officielle)';
  final validFrom = DateTime.parse(
    options['valid-from'] ?? '2026-01-01T00:00:00Z',
  ).toUtc();
  final validTo = DateTime.parse(options['valid-to'] ?? '2036-01-01T00:00:00Z')
      .toUtc();
  if (!validTo.isAfter(validFrom)) {
    throw const FormatException('La période de validité est incohérente.');
  }
  if (File(outPath).existsSync() && options['force'] != 'true') {
    throw StateError(
      '$outPath existe déjà. Ajoutez --force pour le remplacer.',
    );
  }

  final crypto = CryptoService();
  final material = await crypto.generateKeyMaterial();
  final authority = <String, Object?>{
    'id': id,
    'name': name,
    'publicKey': ByteUtils.toHex(material.publicKey),
    'validFrom': validFrom.toIso8601String(),
    'validTo': validTo.toIso8601String(),
  };
  final privateDocument = <String, Object?>{
    'warning':
        'CLÉ DE DÉMONSTRATION UNIQUEMENT. Ne jamais l’embarquer dans une '
        'application ni l’utiliser pour des alertes réelles.',
    ...authority,
    'seed': ByteUtils.toHex(material.seed),
  };

  await _writeJson(outPath, privateDocument);
  await _writeJson(authoritiesPath, {
    'authorities': [authority],
  });

  stdout
    ..writeln('Autorité générée : $id')
    ..writeln('  clé privée (hors APK) : $outPath')
    ..writeln('  clés publiques        : $authoritiesPath')
    ..writeln(
      '  empreinte             : '
      '${authority['publicKey'].toString().substring(0, 16)}…',
    );
}

Future<void> _sign(Map<String, String> options) async {
  final keyPath = options['key'] ?? 'tool/demo_authority.json';
  final outPath = options['out'] ?? 'assets/demo/demo_alert.json';
  final document = await _readJson(keyPath);
  final seedHex = document['seed'];
  final authorityId = document['id'];
  if (seedHex is! String || authorityId is! String) {
    throw const FormatException(
      'Le fichier de clé doit contenir "seed" et "id".',
    );
  }
  final seed = ByteUtils.fromHex(seedHex);
  final crypto = CryptoService();
  final material = await crypto.keyMaterialFromSeed(seed);

  final now = DateTime.now().toUtc();
  final issuedAt = options['issued'] != null
      ? DateTime.parse(options['issued']!).toUtc()
      : now;
  final expiresAt = options['expires'] != null
      ? DateTime.parse(options['expires']!).toUtc()
      : now.add(const Duration(days: 30));
  final alert = SignedAlert(
    authorityId: authorityId,
    alertId: options['alert-id'] ?? 'demo-alert-001',
    severity: _parseSeverity(options['severity'] ?? 'warning'),
    title: options['title'] ?? 'Démonstration — fortes pluies à Antananarivo',
    body:
        options['body'] ??
        'Ceci est une alerte de démonstration. De fortes pluies sont '
            'annoncées dans les prochaines heures. Évitez les zones basses, '
            'prévenez vos voisins et suivez les consignes des autorités.',
    area: options['area'] ?? 'Antananarivo — quartiers denses',
    issuedAt: issuedAt,
    expiresAt: expiresAt,
    signature: Uint8List(64),
  );
  final signature = await crypto.sign(alert.canonicalBytes(), material);
  final signed = SignedAlert(
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
  await _writeJson(outPath, signed.toJson());
  stdout
    ..writeln('Alerte signée : ${signed.alertId}')
    ..writeln('  sortie     : $outPath')
    ..writeln('  signature  : ${signed.signatureFingerprint}')
    ..writeln('  expiration : ${signed.expiresAt.toIso8601String()}');
}

Future<void> _verify(Map<String, String> options) async {
  final alertPath = options['alert'] ?? 'assets/demo/demo_alert.json';
  final authoritiesPath =
      options['authorities'] ?? 'assets/trusted_authorities.json';
  final alertDocument = await _readJson(alertPath);
  final alert = SignedAlert.fromJson(alertDocument);
  final authorities = TrustedAuthority.listFromJsonString(
    await File(authoritiesPath).readAsString(),
  );
  final now = options['now'] != null
      ? DateTime.parse(options['now']!).toUtc()
      : DateTime.now().toUtc();
  final result = await AlertVerifier(CryptoService())
      .verify(alert: alert, authorities: authorities, now: now);
  if (result.isAccepted) {
    stdout.writeln(
      'Alerte valide : ${alert.alertId} '
      '(${result.authority?.name ?? alert.authorityId})',
    );
    return;
  }
  stderr.writeln('Alerte refusée : ${result.rejection?.name ?? 'inconnue'}');
  exitCode = 1;
}

Future<Map<String, Object?>> _readJson(String path) async {
  final decoded = jsonDecode(await File(path).readAsString());
  if (decoded is! Map<String, Object?>) {
    throw FormatException('$path ne contient pas un objet JSON.');
  }
  return decoded;
}

Future<void> _writeJson(String path, Map<String, Object?> value) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(value)}\n');
}

AlertSeverity _parseSeverity(String value) {
  return switch (value.toLowerCase()) {
    'info' => AlertSeverity.info,
    'warning' => AlertSeverity.warning,
    'critical' => AlertSeverity.critical,
    _ => throw FormatException('Sévérité inconnue : $value'),
  };
}

Map<String, String> _parseOptions(List<String> arguments) {
  final options = <String, String>{};
  for (var index = 0; index < arguments.length; index++) {
    final argument = arguments[index];
    if (!argument.startsWith('--')) {
      continue;
    }
    final key = argument.substring(2);
    final hasValue =
        index + 1 < arguments.length && !arguments[index + 1].startsWith('--');
    if (hasValue) {
      options[key] = arguments[index + 1];
      index++;
    } else {
      options[key] = 'true';
    }
  }
  return options;
}

void _printUsage() {
  stdout.writeln('''
Hafatra — outil d'alertes (hors application)

Usage :
  dart run tool/alert_tool.dart init [options]
      --out <fichier>           clé privée de démonstration
                                (défaut : tool/demo_authority.json)
      --authorities <fichier>   clés publiques de confiance
                                (défaut : assets/trusted_authorities.json)
      --id <identifiant>        identifiant de l'autorité
      --name <nom>              nom lisible de l'autorité
      --valid-from <ISO-8601>   début de validité
      --valid-to <ISO-8601>     fin de validité
      --force                   remplace les fichiers existants

  dart run tool/alert_tool.dart sign [options]
      --key <fichier>           clé privée (défaut : tool/demo_authority.json)
      --out <fichier>           alerte signée
                                (défaut : assets/demo/demo_alert.json)
      --alert-id <id>           identifiant de l'alerte
      --severity <info|warning|critical>
      --title <texte>           titre de l'alerte
      --body <texte>            corps de l'alerte
      --area <texte>            zone concernée
      --issued <ISO-8601>       date d'émission
      --expires <ISO-8601>      date d'expiration

  dart run tool/alert_tool.dart verify [options]
      --alert <fichier>         alerte à vérifier
      --authorities <fichier>   clés publiques de confiance
      --now <ISO-8601>          instant de vérification

La clé privée ne doit jamais être placée dans les assets ni dans l'APK.
''');
}
