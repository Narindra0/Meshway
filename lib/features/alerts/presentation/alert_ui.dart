import 'package:flutter/material.dart';
import 'package:hafatra/features/alerts/domain/signed_alert.dart';
import 'package:hafatra/features/alerts/domain/trusted_authority.dart';
import 'package:hafatra/l10n/generated/app_localizations.dart';

/// Correspondances visuelles partagées par la liste et le détail d'alerte.
abstract final class AlertUi {
  static IconData icon(AlertSeverity severity) => switch (severity) {
    AlertSeverity.info => Icons.info_outline_rounded,
    AlertSeverity.warning => Icons.warning_amber_rounded,
    AlertSeverity.critical => Icons.emergency_rounded,
  };

  static Color color(AlertSeverity severity, ColorScheme scheme) {
    return switch (severity) {
      AlertSeverity.info => scheme.primary,
      AlertSeverity.warning => scheme.secondary,
      AlertSeverity.critical => scheme.error,
    };
  }

  static String label(AppLocalizations l10n, AlertSeverity severity) {
    return switch (severity) {
      AlertSeverity.info => l10n.alertSeverityInfo,
      AlertSeverity.warning => l10n.alertSeverityWarning,
      AlertSeverity.critical => l10n.alertSeverityCritical,
    };
  }

  static String authorityName(List<TrustedAuthority> authorities, String id) {
    for (final authority in authorities) {
      if (authority.id == id) {
        return authority.name;
      }
    }
    return id;
  }
}
