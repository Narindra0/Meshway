import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/core/design_system/app_colors.dart';
import 'package:hafatra/core/design_system/app_spacing.dart';
import 'package:hafatra/core/design_system/app_theme.dart';
import 'package:hafatra/core/l10n/l10n.dart';
import 'package:hafatra/core/widgets/app_widgets.dart';
import 'package:hafatra/features/mesh/application/mesh_runtime.dart';

/// Outils de support : état du système, permissions, alerte de démo, journaux.
final class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

final class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  bool _injecting = false;
  bool _copying = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _copyLogs() async {
    if (_copying) {
      return;
    }
    setState(() => _copying = true);
    try {
      final text = await ref.read(loggerProvider).export();
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        _showMessage(context.l10n.diagnosticsCopied);
      }
    } on Object {
      if (mounted) {
        _showMessage(context.l10n.errorGeneric);
      }
    } finally {
      if (mounted) {
        setState(() => _copying = false);
      }
    }
  }

  Future<void> _injectDemoAlert() async {
    if (_injecting) {
      return;
    }
    setState(() => _injecting = true);
    try {
      final alert = await ref.read(demoAlertProvider.future);
      final engine = ref.read(meshEngineProvider);
      if (engine == null) {
        throw StateError('Aucun salon local.');
      }
      final verification = await engine.injectAlert(alert);
      if (!mounted) {
        return;
      }
      if (verification.isAccepted) {
        _showMessage(context.l10n.diagnosticsAlertAdded);
      } else {
        _showMessage(
          context.l10n.diagnosticsAlertRejected(
            verification.rejection?.name ?? 'unknown',
          ),
        );
      }
    } on Object {
      if (mounted) {
        _showMessage(context.l10n.alertInjectionError);
      }
    } finally {
      if (mounted) {
        setState(() => _injecting = false);
      }
    }
  }

  Future<void> _refresh() async {
    ref
      ..invalidate(appVersionProvider)
      ..invalidate(deviceLabelProvider)
      ..invalidate(permissionStatusProvider)
      ..invalidate(logLinesProvider);
    await ref.read(meshControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final version = ref.watch(appVersionProvider).value ?? l10n.loadingLabel;
    final device = ref.watch(deviceLabelProvider).value ?? l10n.loadingLabel;
    final mesh = ref.watch(meshControllerProvider);
    final permissions = ref.watch(permissionStatusProvider);
    final logs = ref.watch(logLinesProvider);
    final logsValue = logs.value ?? const <String>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.diagnosticsTitle),
        actions: [
          IconButton(
            tooltip: l10n.refreshLabel,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          SectionHeader(title: l10n.diagnosticsSystem),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: AppCard(
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.apps_rounded,
                    label: l10n.diagnosticsAppVersion,
                    value: version,
                  ),
                  _InfoRow(
                    icon: Icons.phone_android_rounded,
                    label: l10n.diagnosticsPlatform,
                    value: device,
                  ),
                  _InfoRow(
                    icon: Icons.storage_rounded,
                    label: l10n.databaseLabel,
                    value: l10n.diagnosticsDatabaseOk,
                  ),
                  _InfoRow(
                    icon: Icons.hub_outlined,
                    label: l10n.meshStatus,
                    value: _meshStatus(l10n, mesh),
                  ),
                  _InfoRow(
                    icon: Icons.bluetooth_rounded,
                    label: l10n.transportLabel,
                    value: mesh.demo
                        ? l10n.meshTransportSimulated
                        : l10n.meshTransportBle,
                  ),
                  _InfoRow(
                    icon: Icons.notifications_active_outlined,
                    label: l10n.serviceLabel,
                    value: mesh.serviceRunning
                        ? l10n.meshRunning
                        : l10n.meshStopped,
                  ),
                  _InfoRow(
                    icon: Icons.inventory_2_outlined,
                    label: l10n.meshQueue,
                    value: '${mesh.queueCount}',
                  ),
                  _InfoRow(
                    icon: Icons.visibility_outlined,
                    label: l10n.meshSeen,
                    value: '${mesh.seenCount}',
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(title: l10n.diagnosticsPermissions),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: permissions.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stackTrace) => ListTile(
                  leading: const Icon(Icons.error_outline_rounded),
                  title: Text(l10n.errorPermission),
                ),
                data: (snapshot) => Column(
                  children: [
                    _PermissionRow(
                      icon: Icons.bluetooth_rounded,
                      label: l10n.permissionBluetoothTitle,
                      granted: snapshot.bluetooth,
                    ),
                    const Divider(height: 1, indent: AppSpacing.gutter),
                    _PermissionRow(
                      icon: Icons.notifications_outlined,
                      label: l10n.permissionNotificationTitle,
                      granted: snapshot.notifications,
                    ),
                    const Divider(height: 1, indent: AppSpacing.gutter),
                    _PermissionRow(
                      icon: Icons.battery_saver_outlined,
                      label: l10n.permissionBatteryTitle,
                      granted: snapshot.batteryUnrestricted,
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: Text(l10n.settingsOpenSystemSettings),
                      trailing: const Icon(Icons.open_in_new_rounded),
                      onTap: () => ref
                          .read(appDependenciesProvider)
                          .permissionService
                          .openSettings(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SectionHeader(title: l10n.diagnosticsAlertTools),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.alertDemoHint, style: theme.textTheme.bodySmall),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.tonalIcon(
                    onPressed: _injecting ? null : _injectDemoAlert,
                    icon: _injecting
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.science_outlined),
                    label: Text(l10n.diagnosticsDemoAlert),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(
            title: l10n.diagnosticsLogs,
            trailing: TextButton.icon(
              onPressed: _copying ? null : _copyLogs,
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(l10n.diagnosticsCopy),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 180),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: context.surfaces.field,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: context.surfaces.hairline),
                    ),
                    child: logsValue.isEmpty
                        ? Text(
                            l10n.diagnosticsNoLogs,
                            style: theme.textTheme.bodySmall,
                          )
                        : SizedBox(
                            height: 260,
                            child: ListView.builder(
                              reverse: true,
                              itemCount: logsValue.length,
                              itemBuilder: (context, index) {
                                final line =
                                    logsValue[logsValue.length - 1 - index];
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: Text(
                                    line,
                                    style: AppTheme.code(theme.textTheme)
                                        .copyWith(fontSize: 11.5, height: 1.4),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      l10n.diagnosticsLogsHint,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _meshStatus(AppLocalizations l10n, MeshRuntimeState state) {
    return switch (state.runState) {
      MeshRunState.running => l10n.meshRunning,
      MeshRunState.starting => l10n.meshStarting,
      MeshRunState.stopping => l10n.meshStopping,
      MeshRunState.error => l10n.meshError,
      MeshRunState.idle || MeshRunState.stopped => l10n.meshStopped,
    };
  }
}

final class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 5,
            child: Text(label, style: theme.textTheme.bodySmall),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.icon,
    required this.label,
    required this.granted,
  });

  final IconData icon;
  final String label;
  final bool granted;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: granted ? scheme.primary : scheme.error),
      title: Text(label, style: Theme.of(context).textTheme.titleSmall),
      trailing: StatusBadge(
        label: granted ? l10n.permissionGranted : l10n.permissionDenied,
        color: granted ? scheme.primary : scheme.error,
        icon: granted ? Icons.check_rounded : Icons.close_rounded,
      ),
    );
  }
}
