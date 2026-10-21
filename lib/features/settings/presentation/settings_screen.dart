import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/core/constants/app_constants.dart';
import 'package:hafatra/core/design_system/app_spacing.dart';
import 'package:hafatra/core/design_system/app_theme.dart';
import 'package:hafatra/core/l10n/l10n.dart';
import 'package:hafatra/core/permissions/permission_service.dart';
import 'package:hafatra/core/widgets/app_widgets.dart';
import 'package:hafatra/features/settings/domain/app_settings.dart';

/// Réglages de langue, d'apparence, de relais et de permissions.
final class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final identity = ref.watch(identityProvider);
    final channel = ref.watch(channelProvider);
    final permissionsAsync = ref.watch(permissionStatusProvider);
    final versionAsync = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: [
          SectionHeader(title: l10n.settingsProfile),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InitialAvatar(
                    name: identity?.displayName ?? '',
                    size: 54,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          identity?.displayName ?? l10n.unknownLabel,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs + 2),
                        if (identity != null)
                          Text(
                            'ID ${identity.fingerprint}',
                            style: AppTheme.code(theme.textTheme).copyWith(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        if (channel != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          InkWell(
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(text: channel.code),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.channelCodeCopied),
                                    ),
                                  );
                              }
                            },
                            child: StatusBadge(
                              label: channel.code,
                              color: theme.colorScheme.primary,
                              icon: Icons.copy_rounded,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: identity == null
                        ? null
                        : () => _editDisplayName(
                            context,
                            ref,
                            identity.displayName,
                          ),
                    child: Text(l10n.settingsChangeName),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(title: l10n.settingsAppearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ChoiceTile(
                    icon: Icons.translate_rounded,
                    title: l10n.languageLabel,
                    child: SegmentedButton<String>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: AppConstants.localeFrench,
                          label: Text(l10n.languageFrench),
                        ),
                        ButtonSegment(
                          value: AppConstants.localeMalagasy,
                          label: Text(l10n.languageMalagasy),
                        ),
                      ],
                      selected: {settings.localeCode},
                      onSelectionChanged: (selection) async {
                        if (selection.isEmpty) {
                          return;
                        }
                        try {
                          await ref
                              .read(settingsControllerProvider.notifier)
                              .setLocale(selection.first);
                          if (context.mounted) {
                            _showMessage(context, l10n.languageChanged);
                          }
                        } on Object {
                          if (context.mounted) {
                            _showMessage(context, l10n.errorGeneric);
                          }
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: AppSpacing.gutter),
                  _ChoiceTile(
                    icon: Icons.contrast_rounded,
                    title: l10n.themeLabel,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SegmentedButton<AppThemePreference>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: AppThemePreference.system,
                              label: Text(l10n.themeSystem),
                            ),
                            ButtonSegment(
                              value: AppThemePreference.light,
                              label: Text(l10n.themeLight),
                            ),
                            ButtonSegment(
                              value: AppThemePreference.dark,
                              label: Text(l10n.themeDark),
                            ),
                          ],
                          selected: {settings.theme},
                          onSelectionChanged: (selection) async {
                            if (selection.isEmpty) {
                              return;
                            }
                            try {
                              await ref
                                  .read(settingsControllerProvider.notifier)
                                  .setTheme(selection.first);
                              if (context.mounted) {
                                _showMessage(context, l10n.settingsSaved);
                              }
                            } on Object {
                              if (context.mounted) {
                                _showMessage(context, l10n.errorGeneric);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SectionHeader(title: l10n.settingsMesh),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: Column(
              children: [
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SwitchListTile.adaptive(
                        value: settings.relayEnabled,
                        onChanged: (value) async {
                          try {
                            await ref
                                .read(settingsControllerProvider.notifier)
                                .setRelayEnabled(value);
                          } on Object {
                            if (context.mounted) {
                              _showMessage(context, l10n.errorGeneric);
                            }
                          }
                        },
                        secondary: const Icon(Icons.swap_horiz_rounded),
                        title: Text(l10n.settingsRelay),
                        subtitle: Text(l10n.relayBody),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                      const Divider(height: 1, indent: AppSpacing.gutter),
                      ListTile(
                        leading: const Icon(Icons.battery_saver_outlined),
                        title: Text(l10n.settingsBatteryThreshold),
                        subtitle: Text(
                          l10n.meshThreshold(settings.batteryThreshold),
                        ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.go('/mesh'),
                      ),
                      const Divider(height: 1, indent: AppSpacing.gutter),
                      SwitchListTile.adaptive(
                        value: settings.demoMode,
                        onChanged: (value) async {
                          try {
                            await ref
                                .read(settingsControllerProvider.notifier)
                                .setDemoMode(value);
                          } on Object {
                            if (context.mounted) {
                              _showMessage(context, l10n.errorGeneric);
                            }
                          }
                        },
                        secondary: const Icon(Icons.science_outlined),
                        title: Text(l10n.settingsDemoMode),
                        subtitle: Text(l10n.demoModeBody),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ],
                  ),
                ),
                if (settings.demoMode) ...[
                  const SizedBox(height: AppSpacing.sm),
                  InfoBanner(
                    icon: Icons.info_outline_rounded,
                    message: l10n.settingsDemoWarning,
                    tone: InfoTone.warning,
                  ),
                ],
              ],
            ),
          ),
          SectionHeader(title: l10n.settingsPermissions),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.sm,
                    ),
                    child: Text(
                      l10n.settingsPermissionsBody,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  permissionsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stackTrace) => ListTile(
                      leading: const Icon(Icons.error_outline_rounded),
                      title: Text(l10n.errorPermission),
                    ),
                    data: (permissions) => Column(
                      children: [
                        _PermissionStatusTile(
                          icon: Icons.bluetooth_rounded,
                          title: l10n.permissionBluetoothTitle,
                          granted: permissions.bluetooth,
                          onRequest: () => _requestPermission(
                            context,
                            ref,
                            () => ref
                                .read(appDependenciesProvider)
                                .permissionService
                                .requestBluetooth(),
                          ),
                        ),
                        const Divider(height: 1, indent: AppSpacing.gutter),
                        _PermissionStatusTile(
                          icon: Icons.notifications_outlined,
                          title: l10n.permissionNotificationTitle,
                          granted: permissions.notifications,
                          onRequest: () => _requestPermission(
                            context,
                            ref,
                            () => ref
                                .read(appDependenciesProvider)
                                .permissionService
                                .requestNotifications(),
                          ),
                        ),
                        const Divider(height: 1, indent: AppSpacing.gutter),
                        _PermissionStatusTile(
                          icon: Icons.battery_saver_outlined,
                          title: l10n.permissionBatteryTitle,
                          granted: permissions.batteryUnrestricted,
                          onRequest: () => _requestBattery(context, ref),
                        ),
                      ],
                    ),
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
          SectionHeader(title: l10n.settingsDiagnostics),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
            child: AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.tune_rounded),
                    title: Text(l10n.diagnosticsTitle),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/diagnostics'),
                  ),
                  const Divider(height: 1, indent: AppSpacing.gutter),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(l10n.settingsAbout),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/about'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: versionAsync.when(
              data: (version) => Text(
                l10n.versionLabel(version),
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              loading: () =>
                  Text(l10n.loadingLabel, style: theme.textTheme.bodySmall),
              error: (error, stackTrace) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Text(l10n.aboutLicense, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Future<void> _editDisplayName(
    BuildContext context,
    WidgetRef ref,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final l10n = dialogContext.l10n;
        return AlertDialog(
          title: Text(l10n.settingsNameDialogTitle),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: AppConstants.maxDisplayNameLength,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(labelText: l10n.displayNameLabel),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancelLabel),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (value.isNotEmpty) {
                  Navigator.of(dialogContext).pop(value);
                }
              },
              child: Text(l10n.settingsSaveLabel),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (result == null || !context.mounted) {
      return;
    }
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .updateDisplayName(result);
      if (context.mounted) {
        _showMessage(context, context.l10n.settingsNameUpdated);
      }
    } on Object {
      if (context.mounted) {
        _showMessage(context, context.l10n.errorGeneric);
      }
    }
  }

  Future<void> _requestPermission(
    BuildContext context,
    WidgetRef ref,
    Future<PermissionSnapshot> Function() request,
  ) async {
    try {
      final snapshot = await request();
      ref.invalidate(permissionStatusProvider);
      if (!context.mounted) {
        return;
      }
      final settings = ref.read(settingsControllerProvider);
      final session = ref.read(sessionControllerProvider);
      final mesh = ref.read(meshControllerProvider);
      if (snapshot.bluetooth &&
          !settings.demoMode &&
          session.onboardingComplete &&
          !mesh.isRunning) {
        await ref.read(meshControllerProvider.notifier).start();
      }
    } on Object {
      if (context.mounted) {
        _showMessage(context, context.l10n.errorPermission);
      }
    }
  }

  Future<void> _requestBattery(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(appDependenciesProvider)
          .permissionService
          .requestBatteryUnrestricted();
      ref.invalidate(permissionStatusProvider);
    } on Object {
      if (context.mounted) {
        _showMessage(context, context.l10n.errorPermission);
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

final class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _PermissionStatusTile extends StatelessWidget {
  const _PermissionStatusTile({
    required this.icon,
    required this.title,
    required this.granted,
    required this.onRequest,
  });

  final IconData icon;
  final String title;
  final bool granted;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (granted ? scheme.primary : scheme.error).withValues(
            alpha: 0.12,
          ),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: granted ? scheme.primary : scheme.error),
      ),
      title: Text(title, style: theme.textTheme.titleSmall),
      subtitle: Text(
        granted ? l10n.permissionGranted : l10n.permissionDenied,
        style: theme.textTheme.bodySmall?.copyWith(
          color: granted ? scheme.primary : scheme.error,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: granted
          ? Icon(Icons.check_circle_rounded, color: scheme.primary)
          : TextButton(onPressed: onRequest, child: Text(l10n.allowLabel)),
    );
  }
}
