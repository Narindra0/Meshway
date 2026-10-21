import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/core/database/app_database.dart';
import 'package:hafatra/core/design_system/app_colors.dart';
import 'package:hafatra/core/design_system/app_spacing.dart';
import 'package:hafatra/core/design_system/app_theme.dart';
import 'package:hafatra/core/l10n/l10n.dart';
import 'package:hafatra/core/utils/date_format.dart';
import 'package:hafatra/core/widgets/app_widgets.dart';
import 'package:hafatra/features/alerts/domain/signed_alert.dart';
import 'package:hafatra/features/alerts/presentation/alert_ui.dart';

/// Détail complet d'une alerte, avec les métadonnées vérifiables.
final class AlertDetailScreen extends ConsumerWidget {
  const AlertDetailScreen({required this.alertId, super.key});

  final String alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final alertAsync = ref.watch(alertByIdProvider(alertId));
    final authorities = ref.watch(authoritiesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.alertDetailsTitle)),
      body: alertAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.errorGeneric,
          body: l10n.errorStorage,
          action: FilledButton.tonal(
            onPressed: () => ref.invalidate(alertByIdProvider(alertId)),
            child: Text(l10n.retryLabel),
          ),
        ),
        data: (alert) {
          if (alert == null) {
            return EmptyState(
              icon: Icons.search_off_rounded,
              title: l10n.alertsEmptyTitle,
              body: l10n.alertsEmptyBody,
            );
          }
          return _AlertDetailBody(
            alert: alert,
            authorityName: AlertUi.authorityName(
              authorities,
              alert.authorityId,
            ),
          );
        },
      ),
    );
  }
}

final class _AlertDetailBody extends StatelessWidget {
  const _AlertDetailBody({required this.alert, required this.authorityName});

  final TrustedAlert alert;
  final String authorityName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final severity = AlertSeverity.fromValue(alert.severity);
    final color = AlertUi.color(severity, scheme);
    final expired = !alert.expiresAt.isAfter(DateTime.now());
    final signed = _parsePayload(alert.payload);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.gutter,
        AppSpacing.lg,
        AppSpacing.gutter,
        AppSpacing.xxl,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: context.surfaces.card,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: color.withValues(alpha: 0.32)),
            boxShadow: AppElevation.medium(context.surfaces.shadow),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: color.withValues(alpha: 0.28)),
                    ),
                    child: Icon(AlertUi.icon(severity), color: color, size: 26),
                  ),
                  const Spacer(),
                  if (signed != null)
                    StatusBadge(
                      label: l10n.alertVerified,
                      color: scheme.primary,
                      icon: Icons.verified_rounded,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                alert.title,
                style: theme.textTheme.headlineSmall?.copyWith(height: 1.22),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  StatusBadge(
                    label: AlertUi.label(l10n, severity),
                    color: color,
                  ),
                  if (expired)
                    StatusBadge(
                      label: l10n.alertExpired,
                      color: scheme.error,
                      icon: Icons.schedule_rounded,
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Text(
            alert.body,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
        ),
        if (expired) ...[
          const SizedBox(height: AppSpacing.lg),
          InfoBanner(
            icon: Icons.schedule_rounded,
            message: l10n.alertExpired,
            tone: InfoTone.warning,
          ),
        ],
        if (signed == null) ...[
          const SizedBox(height: AppSpacing.lg),
          InfoBanner(
            icon: Icons.error_outline_rounded,
            message: l10n.errorCrypto,
            tone: InfoTone.error,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: Column(
            children: [
              for (final row in <Widget>[
                _MetaRow(
                  icon: Icons.account_balance_outlined,
                  text: l10n.alertAuthority(authorityName),
                ),
                if (signed != null)
                  _MetaRow(
                    icon: Icons.place_outlined,
                    text: l10n.alertArea(signed.area),
                  ),
                _MetaRow(
                  icon: Icons.event_outlined,
                  text: l10n.alertIssued(
                    AppDateFormat.full(signed?.issuedAt ?? alert.receivedAt),
                  ),
                ),
                _MetaRow(
                  icon: Icons.schedule_rounded,
                  text: l10n.alertExpires(AppDateFormat.full(alert.expiresAt)),
                ),
                if (signed != null)
                  _MetaRow(
                    icon: Icons.fingerprint_rounded,
                    text: l10n.alertSignature(signed.signatureFingerprint),
                    code: true,
                  ),
                _MetaRow(
                  icon: Icons.tag_rounded,
                  text: '#${alert.alertId.toUpperCase()}',
                  code: true,
                ),
              ].indexed) ...[
                if (row.$1 > 0)
                  Container(height: 1, color: context.surfaces.hairline),
                row.$2,
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }

  static SignedAlert? _parsePayload(String payload) {
    try {
      return SignedAlert.fromJsonString(payload);
    } on Object {
      return null;
    }
  }
}

final class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.icon, required this.text, this.code = false});

  final IconData icon;
  final String text;
  final bool code;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: context.surfaces.field,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: code
                  ? AppTheme.code(theme.textTheme)
                        .copyWith(fontSize: 13, color: scheme.onSurfaceVariant)
                  : theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
