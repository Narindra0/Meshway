import 'dart:async';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hafatra/app/bootstrap.dart';
import 'package:hafatra/core/database/app_database.dart';
import 'package:hafatra/core/errors/app_exception.dart';
import 'package:hafatra/core/logging/app_logger.dart';
import 'package:hafatra/core/permissions/permission_service.dart';
import 'package:hafatra/features/alerts/domain/signed_alert.dart';
import 'package:hafatra/features/alerts/domain/trusted_authority.dart';
import 'package:hafatra/features/chat/domain/chat_message.dart';
import 'package:hafatra/features/identity/domain/channel_info.dart';
import 'package:hafatra/features/identity/domain/local_identity.dart';
import 'package:hafatra/features/mesh/application/demo_companion.dart';
import 'package:hafatra/features/mesh/application/mesh_engine.dart';
import 'package:hafatra/features/mesh/application/mesh_runtime.dart';
import 'package:hafatra/features/mesh/data/transports/ble_mesh_transport.dart';
import 'package:hafatra/features/mesh/data/transports/simulated_transport.dart';
import 'package:hafatra/features/mesh/domain/mesh_transport.dart';
import 'package:hafatra/features/settings/domain/app_settings.dart';
import 'package:hafatra/l10n/generated/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Remplacé dans `main` par les services construits au démarrage.
final appDependenciesProvider = Provider<AppDependencies>((ref) {
  throw StateError('appDependenciesProvider doit être surchargé.');
});

final databaseProvider = Provider<AppDatabase>(
  (ref) => ref.watch(appDependenciesProvider).database,
);

final loggerProvider = Provider<AppLogger>(
  (ref) => ref.watch(appDependenciesProvider).logger,
);

final sessionControllerProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);

final identityProvider = Provider<LocalIdentity?>((ref) {
  return ref.watch(sessionControllerProvider.select((state) => state.identity));
});

final channelProvider = Provider<ChannelInfo?>((ref) {
  return ref.watch(sessionControllerProvider.select((state) => state.channel));
});

final meshEngineProvider = Provider<MeshEngine?>((ref) {
  final deps = ref.watch(appDependenciesProvider);
  final channel = ref.watch(
    sessionControllerProvider.select((state) => state.channel),
  );
  if (channel == null) {
    return null;
  }
  return MeshEngine(
    codec: deps.codec,
    chatRepository: deps.chatRepository,
    meshRepository: deps.meshRepository,
    alertService: deps.alertService,
    identityService: deps.identityService,
    channel: channel,
    clock: deps.clock,
    idGenerator: deps.idGenerator,
    logger: deps.logger,
  );
});

final meshControllerProvider =
    NotifierProvider<MeshController, MeshRuntimeState>(MeshController.new);

final chatControllerProvider = NotifierProvider<ChatController, bool>(
  ChatController.new,
);

// La famille n'est pas exportée par flutter_riverpod : l'inférence reste
// nécessaire ici.
// ignore: specify_nonobvious_property_types
final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((
  ref,
  channelId,
) {
  return ref
      .watch(appDependenciesProvider)
      .chatRepository
      .watchMessages(channelId);
});

final alertsProvider = StreamProvider<List<TrustedAlert>>((ref) {
  return ref.watch(databaseProvider).watchAllAlerts();
});

// La famille n'est pas exportée par flutter_riverpod : l'inférence reste
// nécessaire ici.
// ignore: specify_nonobvious_property_types
final alertByIdProvider = FutureProvider.family<TrustedAlert?, String>((
  ref,
  alertId,
) async {
  final rows = await ref.watch(alertsProvider.future);
  for (final row in rows) {
    if (row.alertId == alertId) {
      return row;
    }
  }
  final fallback = await ref.watch(databaseProvider).getAlert(alertId);
  return fallback;
});

final FutureProvider<List<TrustedAuthority>> authoritiesProvider =
    FutureProvider((ref) {
      return ref.watch(appDependenciesProvider).alertService.authorities;
    });

final permissionStatusProvider = FutureProvider<PermissionSnapshot>((ref) {
  return ref.watch(appDependenciesProvider).permissionService.status();
});

final demoAlertProvider = FutureProvider<SignedAlert>((ref) async {
  final source = await rootBundle.loadString('assets/demo/demo_alert.json');
  return SignedAlert.fromJsonString(source);
});

final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  final build = info.buildNumber.isEmpty ? '' : ' (${info.buildNumber})';
  return '${info.version}$build';
});

final deviceLabelProvider = FutureProvider<String>((ref) async {
  try {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;
    return '${android.manufacturer} ${android.model} · '
        'Android ${android.version.release} (API ${android.version.sdkInt})';
  } on Object {
    return 'Android';
  }
});

/// Flux des journaux récents, réinitialisé avec le tampon mémoire.
final logLinesProvider = StreamProvider<List<String>>((ref) {
  final logger = ref.watch(loggerProvider);
  final controller = StreamController<List<String>>();
  final buffer = List<String>.of(logger.lines);
  controller.add(List<String>.unmodifiable(buffer));
  final subscription = logger.lineStream.listen((line) {
    buffer.add(line);
    if (buffer.length > AppLogger.maxMemoryLines) {
      buffer.removeAt(0);
    }
    controller.add(List<String>.unmodifiable(buffer));
  });
  ref.onDispose(() {
    unawaited(subscription.cancel());
    unawaited(controller.close());
  });
  return controller.stream;
});

/// État de session : identité locale et salon, chargés au démarrage.
final class SessionState {
  const SessionState({
    required this.onboardingComplete,
    this.identity,
    this.channel,
  });

  final bool onboardingComplete;
  final LocalIdentity? identity;
  final ChannelInfo? channel;

  bool get hasProfile => identity != null && channel != null;
}

final class SessionController extends Notifier<SessionState> {
  @override
  SessionState build() {
    final deps = ref.watch(appDependenciesProvider);
    return SessionState(
      onboardingComplete: deps.onboardingComplete,
      identity: deps.initialIdentity,
      channel: deps.initialChannel,
    );
  }

  /// Termine l'onboarding : identité, salon, préférences, puis marqueur local.
  Future<void> completeOnboarding({
    required String displayName,
    required String channelCode,
    required bool demoMode,
  }) async {
    final deps = ref.read(appDependenciesProvider);
    final cleanedName = displayName.trim();
    final cleanedCode = channelCode.trim();
    if (cleanedName.isEmpty) {
      throw const ValidationException('Le nom affiché est requis.');
    }
    if (cleanedName.length > 40) {
      throw const ValidationException('Le nom affiché est trop long.');
    }
    if (cleanedCode.length < 3) {
      throw const ValidationException('Le code du quartier est trop court.');
    }
    final identity =
        state.identity ??
        await deps.identityService.create(displayName: cleanedName);
    final namedIdentity = identity.displayName == cleanedName
        ? identity
        : await deps.identityService.updateDisplayName(cleanedName);
    final channel =
        state.channel ??
        await deps.channelService.create(
          code: cleanedCode,
          name: cleanedCode.toUpperCase(),
        );
    final settings = ref
        .read(settingsControllerProvider)
        .copyWith(demoMode: demoMode);
    await deps.settingsRepository.save(settings);
    await deps.settingsRepository.setOnboardingComplete(true);
    ref.read(settingsControllerProvider.notifier).replace(settings);
    state = SessionState(
      onboardingComplete: true,
      identity: namedIdentity,
      channel: channel,
    );
    deps.logger.info('Onboarding completed');
  }

  Future<void> updateDisplayName(String displayName) async {
    final deps = ref.read(appDependenciesProvider);
    final updated = await deps.identityService.updateDisplayName(displayName);
    state = SessionState(
      onboardingComplete: state.onboardingComplete,
      identity: updated,
      channel: state.channel,
    );
  }
}

final class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    return ref.watch(appDependenciesProvider).initialSettings;
  }

  void replace(AppSettings settings) {
    if (identical(state, settings)) {
      return;
    }
    state = settings;
  }

  Future<void> setLocale(String localeCode) async {
    await _save(state.copyWith(localeCode: localeCode));
  }

  Future<void> setTheme(AppThemePreference theme) async {
    await _save(state.copyWith(theme: theme));
  }

  Future<void> setRelayEnabled(bool enabled) async {
    await _save(state.copyWith(relayEnabled: enabled));
  }

  Future<void> setBatteryThreshold(int threshold) async {
    await _save(state.copyWith(batteryThreshold: threshold));
  }

  Future<void> setDemoMode(bool enabled) async {
    await _save(state.copyWith(demoMode: enabled));
  }

  Future<void> _save(AppSettings next) async {
    final deps = ref.read(appDependenciesProvider);
    try {
      await deps.settingsRepository.save(next);
      state = next;
    } on AppException {
      rethrow;
    } on Object catch (error, stackTrace) {
      deps.logger.error(
        'Settings save failed',
        error: error,
        stackTrace: stackTrace,
      );
      throw StorageException(
        'Impossible d’enregistrer les réglages.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}

/// Pilote le transport actif et le service de premier plan.
final class MeshController extends Notifier<MeshRuntimeState> {
  MeshRuntime? _runtime;
  StreamSubscription<MeshRuntimeState>? _subscription;
  late final AppDependencies _deps;
  AppSettings? _settings;
  bool _wantedRunning = false;
  bool _starting = false;
  bool _disposed = false;

  @override
  MeshRuntimeState build() {
    _deps = ref.watch(appDependenciesProvider);
    ref.onDispose(() {
      _disposed = true;
      unawaited(_teardown(keepWanted: false, stopService: true));
    });
    return MeshRuntimeState(
      relayEnabled: _deps.initialSettings.relayEnabled,
      batteryThreshold: _deps.initialSettings.batteryThreshold,
    );
  }

  bool get isWantedRunning => _wantedRunning;

  Future<void> start({AppSettings? settings}) async {
    if (_disposed || _starting) {
      return;
    }
    final deps = _deps;
    // L'annotation explicite évite une inférence nullable de Riverpod ici.
    // ignore: omit_local_variable_types
    final AppSettings nextSettings =
        settings ?? ref.read(settingsControllerProvider);
    _settings = nextSettings;
    final session = ref.read(sessionControllerProvider);
    if (!session.onboardingComplete || session.channel == null) {
      return;
    }
    if (!nextSettings.demoMode) {
      final permissions = await deps.permissionService.status();
      if (!permissions.meshReady) {
        _wantedRunning = false;
        _setError(_l10n(nextSettings.localeCode).permissionBluetoothMissing);
        return;
      }
    }
    final existing = _runtime;
    if (existing != null &&
        existing.isRunning &&
        existing.state.demo == nextSettings.demoMode) {
      _wantedRunning = true;
      await existing.updateSettings(nextSettings);
      return;
    }
    _starting = true;
    _wantedRunning = true;
    try {
      await _teardown(keepWanted: true, stopService: true);
      final engine = ref.read(meshEngineProvider);
      if (engine == null) {
        _wantedRunning = false;
        _setError(_l10n(nextSettings.localeCode).errorGeneric);
        return;
      }
      final identity = session.identity;
      final channel = session.channel;
      if (identity == null || channel == null) {
        _wantedRunning = false;
        _setError(_l10n(nextSettings.localeCode).errorGeneric);
        return;
      }
      final l10n = _l10n(nextSettings.localeCode);
      late final MeshTransport transport;
      DemoCompanion? companion;
      if (nextSettings.demoMode) {
        final simulated = SimulatedTransport(
          network: SimulatedNetwork(latency: const Duration(milliseconds: 70)),
          nodeName: identity.displayName,
          virtualPeerCount: 3,
        );
        transport = simulated;
        companion = DemoCompanion(
          transport: simulated,
          codec: deps.codec,
          channel: channel,
          crypto: deps.crypto,
          chatRepository: deps.chatRepository,
          logger: deps.logger,
          welcomeText: l10n.demoWelcomeMessage,
        );
      } else {
        transport = BleMeshTransport(logger: deps.logger);
      }
      final runtime = MeshRuntime(
        transport: transport,
        engine: engine,
        meshRepository: deps.meshRepository,
        battery: deps.batteryInfo,
        clock: deps.clock,
        logger: deps.logger,
        initialSettings: nextSettings,
        demoCompanion: companion,
      );
      _runtime = runtime;
      _subscription = runtime.states.listen((next) {
        if (!_disposed) {
          state = next;
        }
      });
      state = runtime.state;
      await runtime.start();
      if (runtime.state.isRunning && !nextSettings.demoMode) {
        final serviceStarted = await deps.foregroundService.start(
          title: l10n.appName,
          text: l10n.backgroundNotificationText,
          demo: false,
        );
        runtime.setServiceRunning(
          serviceStarted || deps.foregroundService.isRunning,
        );
      }
    } on AppException catch (error, stackTrace) {
      deps.logger.error(
        'Mesh controller start failed',
        error: error,
        stackTrace: stackTrace,
      );
      _wantedRunning = false;
      _setError(error.message);
    } on Object catch (error, stackTrace) {
      deps.logger.error(
        'Mesh controller start failed',
        error: error,
        stackTrace: stackTrace,
      );
      _wantedRunning = false;
      _setError(error.toString());
    } finally {
      _starting = false;
    }
  }

  Future<void> stop() async {
    _wantedRunning = false;
    await _teardown(keepWanted: false, stopService: true);
  }

  Future<void> configure(AppSettings next) async {
    final previous = _settings;
    _settings = next;
    final runtime = _runtime;
    if (runtime != null) {
      if (previous != null && previous.demoMode != next.demoMode) {
        await _restart(next);
      } else {
        await runtime.updateSettings(next);
        if (runtime.state.isRunning) {
          final l10n = _l10n(next.localeCode);
          await _deps.foregroundService.update(
            title: l10n.appName,
            text: next.demoMode
                ? l10n.backgroundNotificationDemoText
                : l10n.backgroundNotificationText,
          );
        }
      }
      return;
    }
    if (_wantedRunning) {
      await start(settings: next);
    }
  }

  Future<void> refresh() async {
    await _runtime?.refreshBattery();
  }

  Future<void> sendTestMessage(String text) async {
    final engine = ref.read(meshEngineProvider);
    if (engine == null) {
      throw const ValidationException('Le salon local n’est pas prêt.');
    }
    await engine.sendChat(text);
  }

  Future<void> _restart(AppSettings settings) async {
    final shouldRun = _wantedRunning || _runtime?.isRunning == true;
    await _teardown(keepWanted: shouldRun, stopService: true);
    if (shouldRun) {
      await start(settings: settings);
    }
  }

  Future<void> _teardown({
    required bool keepWanted,
    required bool stopService,
  }) async {
    _wantedRunning = keepWanted;
    final deps = _deps;
    await _subscription?.cancel();
    _subscription = null;
    final runtime = _runtime;
    _runtime = null;
    if (runtime != null) {
      try {
        await runtime.stop();
        if (!_disposed) {
          state = runtime.state;
        }
      } on Object catch (error, stackTrace) {
        deps.logger.warning(
          'Mesh runtime teardown failed',
          error: error,
          stackTrace: stackTrace,
        );
      }
      await runtime.dispose();
    }
    if (stopService) {
      await deps.foregroundService.stop();
    }
    if (!_disposed) {
      state = state.copyWith(
        runState: MeshRunState.stopped,
        transportState: MeshTransportState.stopped,
        peerCount: 0,
        serviceRunning: false,
      );
    }
  }

  void _setError(String message) {
    if (_disposed) {
      return;
    }
    state = state.copyWith(
      runState: MeshRunState.error,
      transportState: MeshTransportState.error,
      lastError: message,
    );
  }

  AppLocalizations _l10n(String localeCode) {
    return lookupAppLocalizations(Locale(localeCode));
  }
}

final class ChatController extends Notifier<bool> {
  @override
  bool build() {
    ref.onDispose(() => _disposed = true);
    return false;
  }

  bool _disposed = false;

  Future<void> send(String text) async {
    if (state) {
      return;
    }
    final engine = ref.read(meshEngineProvider);
    if (engine == null) {
      throw const ValidationException('Le salon local n’est pas prêt.');
    }
    state = true;
    try {
      await engine.sendChat(text);
    } finally {
      if (!_disposed) {
        state = false;
      }
    }
  }
}
