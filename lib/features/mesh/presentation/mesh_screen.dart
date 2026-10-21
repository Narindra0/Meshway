import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/core/constants/app_constants.dart';
import 'package:hafatra/core/design_system/app_colors.dart';
import 'package:hafatra/core/design_system/app_spacing.dart';
import 'package:hafatra/core/l10n/l10n.dart';
import 'package:hafatra/core/utils/date_format.dart';
import 'package:hafatra/core/widgets/app_widgets.dart';
import 'package:hafatra/features/mesh/application/mesh_runtime.dart';

/// État du relais, réglages de batterie et test de bout en bout.
final class MeshScreen extends ConsumerStatefulWidget {
  const MeshScreen({super.key});

  @override
  ConsumerState<MeshScreen> createState() => _MeshScreenState();
}

final class _MeshScreenState extends ConsumerState<MeshScreen> {
  double? _thresholdDrag;
  bool _busy = false;

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _toggleMesh() async {
    if (_busy) {
      return;
    }
    final wasRunning = ref.read(meshControllerProvider).isRunning;
    setState(() => _busy = true);
    try {
      final controller = ref.read(meshControllerProvider.notifier);
      if (wasRunning) {
        await controller.stop();
      } else {
        await controller.start();
      }
    } on Object {
      if (mounted) {
        _showMessage(context.l10n.errorMeshNotReady);
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _requestBluetooth() async {
    final deps = ref.read(appDependenciesProvider);
    try {
      final snapshot = await deps.permissionService.requestBluetooth();
      ref.invalidate(permissionStatusProvider);
      if (snapshot.meshReady) {
        await ref.read(meshControllerProvider.notifier).start();
      }
    } on Object {
      if (mounted) {
        _showMessage(context.l10n.errorPermission);
      }
    }
  }

  Future<void> _sendTestMessage() async {
    try {
      await ref
          .read(meshControllerProvider.notifier)
          .sendTestMessage(context.l10n.meshTestMessage);
      if (mounted) {
        _showMessage(context.l10n.meshTestSent);
      }
    } on Object {
      if (mounted) {
        _showMessage(context.l10n.errorMeshNotReady);
      }
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(permissionStatusProvider);
    await ref.read(meshControllerProvider.notifier).refresh();
  }

  Future<void> _saveThreshold(double value) async {
    setState(() => _thresholdDrag = null);
    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .setBatteryThreshold(value.round());
    } on Object {
      if (mounted) {
        _showMessage(context.l10n.errorGeneric);
      }
    }
  }

  Future<void> _setRelayEnabled(bool enabled) async {
    try {
      await ref
          .read(settingsControllerProvider.notifier)
          .setRelayEnabled(enabled);
    } on Object {
      if (mounted) {
        _showMessage(context.l10n.errorGeneric);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final mesh = ref.watch(meshControllerProvider);
    final settings = ref.watch(settingsControllerProvider);
    final permissionsAsync = ref.watch(permissionStatusProvider);
    final permissions = permissionsAsync.value;
    final needsBluetooth =
        !settings.demoMode && permissions != null && !permissions.bluetooth;
    final threshold = _thresholdDrag ?? settings.batteryThreshold.toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.meshTitle),
        actions: [
          IconButton(
            tooltip: l10n.refreshLabel,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.gutter,
            AppSpacing.lg,
            AppSpacing.gutter,
            AppSpacing.xxl,
          ),
          children: [
            _MeshHero(state: mesh, busy: _busy, onToggle: _toggleMesh),
            if (mesh.lastError != null) ...[
              const SizedBox(height: AppSpacing.md),
              InfoBanner(
                icon: Icons.error_outline_rounded,
                message: l10n.meshLastError(mesh.lastError!),
                tone: InfoTone.error,
              ),
            ],
            if (settings.demoMode) ...[
              const SizedBox(height: AppSpacing.md),
              InfoBanner(
                icon: Icons.science_outlined,
                message: l10n.meshDemoNotice,
                tone: InfoTone.warning,
              ),
            ],
            if (needsBluetooth) ...[
              const SizedBox(height: AppSpacing.md),
              InfoBanner(
                icon: Icons.bluetooth_disabled_rounded,
                message: l10n.meshPermissionMissing,
                tone: InfoTone.error,
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.tonalIcon(
                  onPressed: _requestBluetooth,
                  icon: const Icon(Icons.bluetooth_searching_rounded),
                  label: Text(l10n.allowLabel),
                ),
              ),
            ],
            if (mesh.isRunning && mesh.batteryCritical) ...[
              const SizedBox(height: AppSpacing.md),
              InfoBanner(
                icon: Icons.battery_alert_rounded,
                message: l10n.meshBatteryCritical,
                tone: InfoTone.warning,
              ),
            ],
            if (mesh.isRunning && mesh.peerCount == 0) ...[
              const SizedBox(height: AppSpacing.md),
              InfoBanner(
                icon: Icons.devices_other_rounded,
                message: l10n.meshNoPeersHint,
                tone: InfoTone.neutral,
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 520 ? 4 : 2;
                return GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: columns == 4 ? 1.45 : 1.25,
                  children: [
                    MetricTile(
                      icon: Icons.devices_rounded,
                      label: l10n.meshPeers,
                      value: '${mesh.peerCount}',
                    ),
                    MetricTile(
                      icon: Icons.outbox_rounded,
                      label: l10n.meshQueue,
                      value: '${mesh.queueCount}',
                      tone: mesh.queueCount > 0 ? scheme.secondary : null,
                    ),
                    MetricTile(
                      icon: Icons.inventory_2_outlined,
                      label: l10n.meshSeen,
                      value: '${mesh.seenCount}',
                    ),
                    MetricTile(
                      icon: mesh.charging
                          ? Icons.battery_charging_full_rounded
                          : Icons.battery_std_rounded,
                      label: mesh.charging ? l10n.charging : l10n.meshBattery,
                      value: '${mesh.batteryPercent} %',
                      tone: mesh.batteryCritical ? scheme.error : null,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: EdgeInsets.zero,
              child: SwitchListTile.adaptive(
                value: settings.relayEnabled,
                onChanged: _setRelayEnabled,
                secondary: const Icon(Icons.swap_horiz_rounded),
                title: Text(l10n.relayTitle),
                subtitle: Text(l10n.relayBody),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.battery_saver_outlined, color: scheme.primary),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.meshThreshold(threshold.round()),
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Slider(
                    value: threshold,
                    min: AppConstants.minBatteryThreshold.toDouble(),
                    max: AppConstants.maxBatteryThreshold.toDouble(),
                    divisions:
                        (AppConstants.maxBatteryThreshold -
                            AppConstants.minBatteryThreshold) ~/
                        5,
                    label: '${threshold.round()} %',
                    onChanged: (value) {
                      setState(() => _thresholdDrag = value);
                    },
                    onChangeEnd: _saveThreshold,
                  ),
                  Text(
                    l10n.meshThresholdHelp,
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sendTestMessage,
                    icon: const Icon(Icons.send_outlined),
                    label: Text(l10n.meshTest),
                  ),
                ),
              ],
            ),
            if (mesh.startedAt != null && mesh.isRunning) ...[
              const SizedBox(height: AppSpacing.md),
              Center(
                child: Text(
                  l10n.meshStartedAt(AppDateFormat.time(mesh.startedAt!)),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                l10n.meshStartHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _MeshHero extends StatelessWidget {
  const _MeshHero({
    required this.state,
    required this.busy,
    required this.onToggle,
  });

  final MeshRuntimeState state;
  final bool busy;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final surfaces = context.surfaces;
    final active = state.isRunning;
    final error = state.runState == MeshRunState.error;

    final heroBackground = error
        ? scheme.errorContainer
        : active
        ? null
        : surfaces.card;
    final foreground = error
        ? scheme.onErrorContainer
        : active
        ? context.gradients.brandInk
        : scheme.onSurface;
    final muted = foreground.withValues(alpha: 0.78);
    final status = switch (state.runState) {
      MeshRunState.running => l10n.meshRunning,
      MeshRunState.starting => l10n.meshStarting,
      MeshRunState.stopping => l10n.meshStopping,
      MeshRunState.error => l10n.meshError,
      MeshRunState.idle => l10n.meshStopped,
      MeshRunState.stopped => l10n.meshStopped,
    };

    return DecoratedBox(
      decoration: BoxDecoration(
        color: heroBackground,
        gradient: active && !error ? context.gradients.hero : null,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: active && !error
            ? AppElevation.glow(surfaces.glow)
            : AppElevation.medium(surfaces.shadow),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: foreground.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: foreground.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        active ? Icons.hub_rounded : Icons.hub_outlined,
                        color: foreground,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          LiveDot(
                            active: active,
                            color: active
                                ? context.gradients.brandInk
                                : scheme.error,
                            size: 8,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              status,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: foreground,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        state.demo
                            ? l10n.meshTransportSimulated
                            : l10n.meshTransportBle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(
                  label: state.demo ? l10n.demoTag : l10n.bleTag,
                  color: foreground,
                  icon: state.demo
                      ? Icons.science_outlined
                      : Icons.bluetooth_rounded,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: state.isBusy || busy ? null : onToggle,
                style: FilledButton.styleFrom(
                  backgroundColor: active
                      ? context.gradients.brandInk
                      : error
                      ? scheme.onErrorContainer
                      : null,
                  foregroundColor: active
                      ? const Color(0xFF0A3F3A)
                      : error
                      ? scheme.errorContainer
                      : null,
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: state.isBusy || busy
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        active
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_fill_rounded,
                        size: 22,
                      ),
                label: Text(active ? l10n.meshStop : l10n.meshStart),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
