import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/core/database/app_database.dart';
import 'package:hafatra/core/design_system/app_colors.dart';
import 'package:hafatra/core/design_system/app_spacing.dart';
import 'package:hafatra/core/l10n/l10n.dart';
import 'package:hafatra/core/utils/date_format.dart';
import 'package:hafatra/core/widgets/app_widgets.dart';
import 'package:hafatra/features/alerts/domain/signed_alert.dart';
import 'package:hafatra/features/alerts/presentation/alert_ui.dart';

/// Liste des alertes vérifiées, stockées localement.
final class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final alertsAsync = ref.watch(alertsProvider);
    final authorities = ref.watch(authoritiesProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.alertsTitle),
        actions: [
          IconButton(
            tooltip: l10n.diagnosticsTitle,
            onPressed: () => context.push('/diagnostics'),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.errorGeneric,
          body: l10n.errorStorage,
          action: FilledButton.tonal(
            onPressed: () => ref.invalidate(alertsProvider),
            child: Text(l10n.retryLabel),
          ),
        ),
        data: (alerts) {
          if (alerts.isEmpty) {
            return EmptyState(
              icon: Icons.verified_user_outlined,
              title: l10n.alertsEmptyTitle,
              body: l10n.alertsEmptyBody,
              action: OutlinedButton.icon(
                onPressed: () => context.push('/diagnostics'),
                icon: const Icon(Icons.science_outlined),
                label: Text(l10n.diagnosticsDemoAlert),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter,
              AppSpacing.lg,
              AppSpacing.gutter,
              AppSpacing.xxl,
            ),
            itemCount: alerts.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.sectionGap),
            itemBuilder: (context, index) {
              final alert = alerts[index];
              return _AlertCard(
                alert: alert,
                authorityName: AlertUi.authorityName(
                  authorities,
                  alert.authorityId,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

final class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert, required this.authorityName});

  final TrustedAlert alert;
  final String authorityName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final severity = AlertSeverity.fromValue(alert.severity);
    final color = AlertUi.color(severity, theme.colorScheme);
    final expired = !alert.expiresAt.isAfter(DateTime.now());
    return AppCard(
      onTap: () => context.push('/alerts/${alert.alertId}'),
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: color.withValues(alpha: 0.26)),
                ),
                child: Icon(AlertUi.icon(severity), color: color, size: 22),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs + 2),
                    Text(
                      alert.body,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusBadge(
                label: l10n.alertVerified,
                color: theme.colorScheme.primary,
                icon: Icons.verified_rounded,
              ),
              StatusBadge(label: AlertUi.label(l10n, severity), color: color),
              if (expired)
                StatusBadge(
                  label: l10n.alertExpired,
                  color: theme.colorScheme.error,
                  icon: Icons.schedule_rounded,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(height: 1, color: context.surfaces.hairline),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Icon(
                Icons.account_balance_outlined,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.alertAuthority(authorityName),
                  style: theme.textTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                AppDateFormat.short(alert.receivedAt),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
