import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafatra/app/providers.dart';
import 'package:hafatra/features/alerts/domain/signed_alert.dart';
import 'package:hafatra/features/settings/domain/app_settings.dart';

/// Démarre le maillage quand le profil est prêt, écoute les alertes vérifiées
/// et rafraîchit les permissions au retour dans l'application.
final class AppRuntime extends ConsumerStatefulWidget {
  const AppRuntime({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<AppRuntime> createState() => _AppRuntimeState();
}

final class _AppRuntimeState extends ConsumerState<AppRuntime>
    with WidgetsBindingObserver {
  StreamSubscription<SignedAlert>? _alertSubscription;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final deps = ref.read(appDependenciesProvider);
    _alertSubscription = deps.alertService.verifiedAlerts.listen((alert) {
      unawaited(deps.notificationService.showAlert(alert));
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_syncMesh());
    });
  }

  Future<void> _syncMesh() async {
    if (!mounted || _started) {
      return;
    }
    final session = ref.read(sessionControllerProvider);
    if (!session.onboardingComplete || session.channel == null) {
      return;
    }
    _started = true;
    try {
      await ref
          .read(meshControllerProvider.notifier)
          .start(settings: ref.read(settingsControllerProvider));
    } finally {
      _started = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }
    ref.invalidate(permissionStatusProvider);
    final controller = ref.read(meshControllerProvider.notifier);
    unawaited(controller.refresh());
    final mesh = ref.read(meshControllerProvider);
    if (controller.isWantedRunning && !mesh.isRunning && !mesh.isBusy) {
      unawaited(_syncMesh());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_alertSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(
      sessionControllerProvider.select((state) => state.onboardingComplete),
      (previous, next) {
        if (next) {
          unawaited(_syncMesh());
        }
      },
    );
    ref.listen<AppSettings>(settingsControllerProvider, (previous, next) {
      if (previous == null) {
        return;
      }
      unawaited(ref.read(meshControllerProvider.notifier).configure(next));
    });
    return widget.child;
  }
}
