import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/core/constants/app_constants.dart';
import 'package:hafatra/core/design_system/app_colors.dart';
import 'package:hafatra/core/design_system/app_spacing.dart';
import 'package:hafatra/core/errors/app_exception.dart';
import 'package:hafatra/core/l10n/l10n.dart';
import 'package:hafatra/core/permissions/permission_service.dart';
import 'package:hafatra/core/widgets/app_widgets.dart';
import 'package:hafatra/features/identity/domain/channel_info.dart';

/// Introduction en trois étapes : promesse, profil, permissions.
final class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _PermissionKind { bluetooth, notifications, battery }

final class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  int _page = 0;
  bool _demoMode = false;
  bool _submitting = false;
  String? _profileError;
  PermissionSnapshot? _permissions;
  _PermissionKind? _busyPermission;

  @override
  void initState() {
    super.initState();
    final deps = ref.read(appDependenciesProvider);
    final session = ref.read(sessionControllerProvider);
    final settings = ref.read(settingsControllerProvider);
    _demoMode = settings.demoMode;
    _nameController.text = session.identity?.displayName ?? '';
    _codeController.text =
        session.channel?.code ?? AppConstants.defaultChannelCode;
    unawaited(_refreshPermissions(deps.permissionService));
  }

  Future<void> _refreshPermissions(PermissionService service) async {
    final snapshot = await service.status();
    if (mounted) {
      setState(() => _permissions = snapshot);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  bool _validateProfile(AppLocalizations l10n) {
    final name = _nameController.text.trim();
    final code = ChannelInfo.normalizeCode(_codeController.text);
    if (name.isEmpty) {
      setState(() => _profileError = l10n.displayNameRequired);
      return false;
    }
    if (name.length > AppConstants.maxDisplayNameLength) {
      setState(() => _profileError = l10n.displayNameRequired);
      return false;
    }
    if (code.length < AppConstants.minChannelCodeLength) {
      setState(() => _profileError = l10n.neighborhoodCodeTooShort);
      return false;
    }
    if (code.length > AppConstants.maxChannelCodeLength) {
      setState(() => _profileError = l10n.neighborhoodCodeTooShort);
      return false;
    }
    setState(() => _profileError = null);
    return true;
  }

  Future<void> _next() async {
    final l10n = context.l10n;
    if (_page == 1 && !_validateProfile(l10n)) {
      return;
    }
    if (_page < 2) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    await _finish();
  }

  Future<void> _finish() async {
    if (_submitting) {
      return;
    }
    final l10n = context.l10n;
    if (!_validateProfile(l10n)) {
      await _pageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await ref
          .read(sessionControllerProvider.notifier)
          .completeOnboarding(
            displayName: _nameController.text,
            channelCode: _codeController.text,
            demoMode: _demoMode,
          );
      if (mounted) {
        context.go('/chat');
      }
    } on AppException catch (error) {
      if (mounted) {
        _showMessage(error.message);
      }
    } on Object {
      if (mounted) {
        _showMessage(l10n.errorGeneric);
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _requestPermission(_PermissionKind kind) async {
    setState(() => _busyPermission = kind);
    final deps = ref.read(appDependenciesProvider);
    try {
      final snapshot = switch (kind) {
        _PermissionKind.bluetooth =>
          await deps.permissionService.requestBluetooth(),
        _PermissionKind.notifications =>
          await deps.permissionService.requestNotifications(),
        _PermissionKind.battery => await _requestBattery(
          deps.permissionService,
        ),
      };
      if (!mounted) {
        return;
      }
      setState(() => _permissions = snapshot);
      ref.invalidate(permissionStatusProvider);
    } on Object {
      if (mounted) {
        _showMessage(context.l10n.errorPermission);
      }
    } finally {
      if (mounted) {
        setState(() => _busyPermission = null);
      }
    }
  }

  Future<PermissionSnapshot> _requestBattery(PermissionService service) async {
    await service.requestBatteryUnrestricted();
    return await service.status();
  }

  Future<void> _openSystemSettings() async {
    await ref.read(appDependenciesProvider).permissionService.openSettings();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _updatePage(int page) => setState(() => _page = page);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const _OnboardingTopBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(child: _StepSegments(page: _page)),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    l10n.onboardingStep(_page + 1, 3),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: _updatePage,
                children: [
                  const _WelcomeStep(),
                  _ProfileStep(
                    nameController: _nameController,
                    codeController: _codeController,
                    demoMode: _demoMode,
                    onDemoChanged: (value) => setState(() => _demoMode = value),
                    localeCode: settings.localeCode,
                    error: _profileError,
                    onProfileChanged: () {
                      if (_profileError != null) {
                        setState(() => _profileError = null);
                      }
                    },
                    onLocaleChanged: (locale) async {
                      try {
                        await ref
                            .read(settingsControllerProvider.notifier)
                            .setLocale(locale);
                      } on Object {
                        if (mounted) {
                          _showMessage(l10n.errorGeneric);
                        }
                      }
                    },
                  ),
                  _PermissionsStep(
                    permissions: _permissions,
                    demoMode: _demoMode,
                    busyPermission: _busyPermission,
                    onRequest: _requestPermission,
                    onOpenSettings: _openSystemSettings,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  if (_page > 0) ...[
                    TextButton(
                      onPressed: _submitting
                          ? null
                          : () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 240),
                              curve: Curves.easeOutCubic,
                            ),
                      child: Text(l10n.backLabel),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _submitting ? null : _next,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                      ),
                      icon: _submitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _page == 2
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                      label: Text(
                        _page == 2 ? l10n.startLabel : l10n.continueLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bandeau d'introduction : pastille de marque en degrade et nom de
/// l'application.
final class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: context.gradients.brand,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              boxShadow: AppElevation.glow(context.surfaces.glow),
            ),
            child: SizedBox.square(
              dimension: 30,
              child: Icon(
                Icons.hub_rounded,
                size: 18,
                color: context.gradients.brandInk,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Text(
            AppLocalizations.of(context).appName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Progression en trois segments : le segment courant porte le degrad de
/// marque, les segments franchis restent teintés.
final class _StepSegments extends StatelessWidget {
  const _StepSegments({required this.page});

  final int page;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: List.generate(3, (index) {
        final done = index <= page;
        final current = index == page;
        return Expanded(
          child: AnimatedContainer(
            duration: AppMotion.reveal,
            curve: AppMotion.standard,
            margin: EdgeInsets.only(left: index == 0 ? 0 : AppSpacing.xs),
            height: current ? 6 : 4,
            decoration: BoxDecoration(
              gradient: current ? context.gradients.brand : null,
              color: current
                  ? null
                  : (done ? scheme.primary : context.surfaces.highest),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        );
      }),
    );
  }
}

final class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: context.gradients.hero,
                boxShadow: AppElevation.glow(context.surfaces.glow),
              ),
              child: SizedBox.square(
                dimension: 116,
                child: Center(
                  child: Icon(
                    Icons.forum_rounded,
                    size: 54,
                    color: context.gradients.brandInk,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            l10n.onboardingWelcomeTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.onboardingWelcomeBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _FeatureRow(
            icon: Icons.wifi_off_rounded,
            text: l10n.onboardingFeatureOffline,
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureRow(
            icon: Icons.hub_rounded,
            text: l10n.onboardingFeatureMesh,
          ),
          const SizedBox(height: AppSpacing.md),
          _FeatureRow(
            icon: Icons.verified_user_outlined,
            text: l10n.onboardingFeatureAlerts,
          ),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              l10n.appTagline,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: scheme.primary,
                fontWeight: const FontWeight(650),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: context.gradients.brandSoft,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: context.surfaces.hairlineStrong),
          ),
          child: Icon(icon, size: 22, color: scheme.onPrimaryContainer),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

final class _ProfileStep extends StatelessWidget {
  const _ProfileStep({
    required this.nameController,
    required this.codeController,
    required this.demoMode,
    required this.onDemoChanged,
    required this.localeCode,
    required this.error,
    required this.onProfileChanged,
    required this.onLocaleChanged,
  });

  final TextEditingController nameController;
  final TextEditingController codeController;
  final bool demoMode;
  final ValueChanged<bool> onDemoChanged;
  final String localeCode;
  final String? error;
  final VoidCallback onProfileChanged;
  final ValueChanged<String> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.onboardingProfileTitle,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.onboardingProfileBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(l10n.languageLabel, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: 'fr', label: Text(l10n.languageFrench)),
                ButtonSegment(value: 'mg', label: Text(l10n.languageMalagasy)),
              ],
              selected: {localeCode},
              onSelectionChanged: (selection) {
                if (selection.isNotEmpty) {
                  onLocaleChanged(selection.first);
                }
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            maxLength: AppConstants.maxDisplayNameLength,
            onChanged: (_) => onProfileChanged(),
            decoration: InputDecoration(
              labelText: l10n.displayNameLabel,
              hintText: l10n.displayNameHint,
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: codeController,
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.done,
            maxLength: AppConstants.maxChannelCodeLength,
            onChanged: (_) => onProfileChanged(),
            decoration: InputDecoration(
              labelText: l10n.neighborhoodCodeLabel,
              hintText: l10n.neighborhoodCodeHint,
              helperText: l10n.neighborhoodCodeHelp,
              helperMaxLines: 3,
              prefixIcon: const Icon(Icons.map_outlined),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: AppSpacing.sm),
            InfoBanner(
              icon: Icons.error_outline_rounded,
              message: error!,
              tone: InfoTone.error,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile.adaptive(
              value: demoMode,
              onChanged: onDemoChanged,
              secondary: const Icon(Icons.science_outlined),
              title: Text(l10n.demoModeTitle),
              subtitle: Text(l10n.demoModeBody),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.onboardingDemoHint, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

final class _PermissionsStep extends StatelessWidget {
  const _PermissionsStep({
    required this.permissions,
    required this.demoMode,
    required this.busyPermission,
    required this.onRequest,
    required this.onOpenSettings,
  });

  final PermissionSnapshot? permissions;
  final bool demoMode;
  final _PermissionKind? busyPermission;
  final ValueChanged<_PermissionKind> onRequest;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final snapshot = permissions;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.permissionsTitle, style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.permissionsBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (demoMode) ...[
            const SizedBox(height: AppSpacing.lg),
            InfoBanner(
              icon: Icons.science_outlined,
              message: l10n.meshDemoNotice,
              tone: InfoTone.warning,
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          _PermissionTile(
            icon: Icons.bluetooth_rounded,
            title: l10n.permissionBluetoothTitle,
            body: l10n.permissionBluetoothBody,
            granted: snapshot?.bluetooth,
            busy: busyPermission == _PermissionKind.bluetooth,
            onAllow: demoMode
                ? null
                : () => onRequest(_PermissionKind.bluetooth),
          ),
          const SizedBox(height: AppSpacing.md),
          _PermissionTile(
            icon: Icons.notifications_outlined,
            title: l10n.permissionNotificationTitle,
            body: l10n.permissionNotificationBody,
            granted: snapshot?.notifications,
            busy: busyPermission == _PermissionKind.notifications,
            onAllow: () => onRequest(_PermissionKind.notifications),
          ),
          const SizedBox(height: AppSpacing.md),
          _PermissionTile(
            icon: Icons.battery_saver_outlined,
            title: l10n.permissionBatteryTitle,
            body: l10n.permissionBatteryBody,
            granted: snapshot?.batteryUnrestricted,
            busy: busyPermission == _PermissionKind.battery,
            onAllow: () => onRequest(_PermissionKind.battery),
          ),
          const SizedBox(height: AppSpacing.lg),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
              label: Text(l10n.permissionOpenSettings),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.permissionsSkipHint, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

final class _PermissionTile extends StatelessWidget {
  const _PermissionTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.granted,
    required this.busy,
    required this.onAllow,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool? granted;
  final bool busy;
  final VoidCallback? onAllow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final isGranted = granted == true;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isGranted
                  ? scheme.primaryContainer
                  : context.surfaces.field,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: context.surfaces.hairline),
            ),
            child: Icon(
              icon,
              color: isGranted ? scheme.onPrimaryContainer : scheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(body, style: Theme.of(context).textTheme.bodySmall),
                if (granted != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        isGranted
                            ? Icons.check_circle_rounded
                            : Icons.cancel_outlined,
                        size: 16,
                        color: isGranted ? scheme.primary : scheme.error,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        isGranted
                            ? l10n.permissionGranted
                            : l10n.permissionDenied,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: isGranted ? scheme.primary : scheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (onAllow != null && !isGranted)
            if (busy)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              TextButton(onPressed: onAllow, child: Text(l10n.allowLabel)),
        ],
      ),
    );
  }
}
