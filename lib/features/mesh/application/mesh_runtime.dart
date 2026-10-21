import 'dart:async';
import 'dart:typed_data';

import 'package:hafatra/core/constants/app_constants.dart';
import 'package:hafatra/core/constants/mesh_constants.dart';
import 'package:hafatra/core/logging/app_logger.dart';
import 'package:hafatra/core/platform/battery_info.dart';
import 'package:hafatra/core/utils/clock.dart';
import 'package:hafatra/features/mesh/application/demo_companion.dart';
import 'package:hafatra/features/mesh/application/mesh_engine.dart';
import 'package:hafatra/features/mesh/data/mesh_repository.dart';
import 'package:hafatra/features/mesh/data/transports/simulated_transport.dart';
import 'package:hafatra/features/mesh/domain/mesh_transport.dart';
import 'package:hafatra/features/mesh/domain/relay_policy.dart';
import 'package:hafatra/features/settings/domain/app_settings.dart';

enum MeshRunState { idle, starting, running, stopping, stopped, error }

/// État observable du maillage pour l'interface et les diagnostics.
final class MeshRuntimeState {
  const MeshRuntimeState({
    this.runState = MeshRunState.idle,
    this.transportId,
    this.transportState = MeshTransportState.stopped,
    this.demo = false,
    this.peerCount = 0,
    this.queueCount = 0,
    this.seenCount = 0,
    this.batteryPercent = 100,
    this.charging = false,
    this.relayEnabled = true,
    this.batteryThreshold = AppConstants.defaultBatteryThreshold,
    this.serviceRunning = false,
    this.lastError,
    this.startedAt,
  });

  final MeshRunState runState;
  final String? transportId;
  final MeshTransportState transportState;
  final bool demo;
  final int peerCount;
  final int queueCount;
  final int seenCount;
  final int batteryPercent;
  final bool charging;
  final bool relayEnabled;
  final int batteryThreshold;
  final bool serviceRunning;
  final String? lastError;
  final DateTime? startedAt;

  bool get isRunning => runState == MeshRunState.running;
  bool get isBusy =>
      runState == MeshRunState.starting || runState == MeshRunState.stopping;
  bool get batteryCritical => !charging && batteryPercent < batteryThreshold;

  MeshRuntimeState copyWith({
    MeshRunState? runState,
    String? transportId,
    MeshTransportState? transportState,
    bool? demo,
    int? peerCount,
    int? queueCount,
    int? seenCount,
    int? batteryPercent,
    bool? charging,
    bool? relayEnabled,
    int? batteryThreshold,
    bool? serviceRunning,
    String? lastError,
    DateTime? startedAt,
    bool clearError = false,
  }) {
    return MeshRuntimeState(
      runState: runState ?? this.runState,
      transportId: transportId ?? this.transportId,
      transportState: transportState ?? this.transportState,
      demo: demo ?? this.demo,
      peerCount: peerCount ?? this.peerCount,
      queueCount: queueCount ?? this.queueCount,
      seenCount: seenCount ?? this.seenCount,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      charging: charging ?? this.charging,
      relayEnabled: relayEnabled ?? this.relayEnabled,
      batteryThreshold: batteryThreshold ?? this.batteryThreshold,
      serviceRunning: serviceRunning ?? this.serviceRunning,
      lastError: clearError ? null : (lastError ?? this.lastError),
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

/// Cycle de vie du transport, pompe de l'outbox et surveillance batterie.
final class MeshRuntime {
  MeshRuntime({
    required MeshTransport transport,
    required MeshEngine engine,
    required MeshRepository meshRepository,
    required BatteryInfoSource battery,
    required Clock clock,
    required AppLogger logger,
    required AppSettings initialSettings,
    DemoCompanion? demoCompanion,
    this.pumpInterval = MeshConstants.outboxPumpInterval,
    this.batteryInterval = const Duration(seconds: 60),
  }) : _transport = transport,
       _engine = engine,
       _meshRepository = meshRepository,
       _battery = battery,
       _clock = clock,
       _logger = logger,
       _demoCompanion = demoCompanion,
       _settings = initialSettings,
       _state = MeshRuntimeState(
         demo: transport is SimulatedTransport,
         relayEnabled: initialSettings.relayEnabled,
         batteryThreshold: initialSettings.batteryThreshold,
         transportId: transport.id,
       );

  final MeshTransport _transport;
  final MeshEngine _engine;
  final MeshRepository _meshRepository;
  final BatteryInfoSource _battery;
  final Clock _clock;
  final AppLogger _logger;
  final DemoCompanion? _demoCompanion;
  final Duration pumpInterval;
  final Duration batteryInterval;

  final StreamController<MeshRuntimeState> _states =
      StreamController<MeshRuntimeState>.broadcast();

  AppSettings _settings;
  MeshRuntimeState _state;
  StreamSubscription<Uint8List>? _incomingSubscription;
  StreamSubscription<MeshTransportStatus>? _statusSubscription;
  Timer? _pumpTimer;
  Timer? _batteryTimer;
  Timer? _maintenanceTimer;
  bool _pumping = false;
  bool _disposed = false;

  MeshRuntimeState get state => _state;

  Stream<MeshRuntimeState> get states => _states.stream;

  bool get isRunning => _state.isRunning;

  Future<void> start() async {
    if (_state.isRunning || _state.runState == MeshRunState.starting) {
      return;
    }
    _emit(
      _state.copyWith(
        runState: MeshRunState.starting,
        transportState: MeshTransportState.starting,
        clearError: true,
      ),
    );
    _incomingSubscription = _transport.incoming.listen(
      _onFrame,
      onError: (Object error, StackTrace stackTrace) {
        _logger.error(
          'Transport incoming stream failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
    _statusSubscription = _transport.statusStream.listen(
      _onTransportStatus,
      onError: (Object error, StackTrace stackTrace) {
        _logger.warning(
          'Transport status stream failed',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );
    try {
      await _refreshBattery();
      await _transport.start();
      await _demoCompanion?.start();
      _pumpTimer = Timer.periodic(pumpInterval, (_) => unawaited(_pump()));
      _batteryTimer = Timer.periodic(
        batteryInterval,
        (_) => unawaited(_refreshBattery()),
      );
      _maintenanceTimer = Timer.periodic(const Duration(hours: 1), (_) {
        unawaited(_runMaintenance());
      });
      await _runMaintenance();
      await _refreshCounts();
      _emit(
        _state.copyWith(
          runState: MeshRunState.running,
          transportState: MeshTransportState.running,
          peerCount: _transport.status.peerCount,
          startedAt: _clock.now(),
          clearError: true,
        ),
      );
      unawaited(_pump());
      _logger.info(
        'Mesh runtime started (${_transport.id}, demo=${_state.demo})',
      );
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Mesh runtime start failed',
        error: error,
        stackTrace: stackTrace,
      );
      await _cancelSubscriptions();
      try {
        await _transport.stop();
      } on Object {
        // Le transport n'a jamais démarré.
      }
      _emit(
        _state.copyWith(
          runState: MeshRunState.error,
          transportState: MeshTransportState.error,
          lastError: _messageFor(error),
          peerCount: 0,
        ),
      );
    }
  }

  Future<void> stop() async {
    if (_state.runState == MeshRunState.stopped ||
        _state.runState == MeshRunState.idle) {
      return;
    }
    _emit(_state.copyWith(runState: MeshRunState.stopping));
    _pumpTimer?.cancel();
    _batteryTimer?.cancel();
    _maintenanceTimer?.cancel();
    _pumpTimer = null;
    _batteryTimer = null;
    _maintenanceTimer = null;
    await _demoCompanion?.stop();
    await _cancelSubscriptions();
    try {
      await _transport.stop();
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Mesh transport stop failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
    await _refreshCounts();
    _emit(
      _state.copyWith(
        runState: MeshRunState.stopped,
        transportState: MeshTransportState.stopped,
        peerCount: 0,
      ),
    );
    _logger.info('Mesh runtime stopped (${_transport.id})');
  }

  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    _emit(
      _state.copyWith(
        relayEnabled: settings.relayEnabled,
        batteryThreshold: settings.batteryThreshold,
      ),
    );
    _applyRelayConditions();
  }

  Future<void> refreshBattery() => _refreshBattery();

  void setServiceRunning(bool running) {
    if (_state.serviceRunning != running) {
      _emit(_state.copyWith(serviceRunning: running));
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    await stop();
    await _states.close();
  }

  Future<void> _onFrame(Uint8List bytes) async {
    try {
      await _engine.handleFrame(bytes);
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Mesh frame handling failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _onTransportStatus(MeshTransportStatus status) {
    _emit(
      _state.copyWith(
        transportState: status.state,
        peerCount: status.peerCount,
        lastError: status.lastError,
        clearError: status.state == MeshTransportState.running,
        runState: _state.runState == MeshRunState.starting
            ? MeshRunState.starting
            : (status.state == MeshTransportState.error
                  ? MeshRunState.error
                  : _state.runState),
      ),
    );
    if (status.state == MeshTransportState.running) {
      unawaited(_pump());
    }
  }

  Future<void> _pump() async {
    if (_pumping || _disposed || !_state.isRunning) {
      return;
    }
    _pumping = true;
    try {
      final due = await _meshRepository.due(_clock.now());
      for (final entry in due) {
        if (!_transport.status.isRunning) {
          break;
        }
        var accepted = false;
        try {
          accepted = await _transport.send(entry.bytes);
          if (accepted) {
            await _meshRepository.remove(entry.packetId);
            await _meshRepository.markMessageSent(entry.messageId);
            await _engine.onPacketTransmitted(entry.bytes);
          } else {
            await _meshRepository.retryLater(
              entry.packetId,
              _nextAttempt(entry.attempts),
            );
          }
        } on Object catch (error, stackTrace) {
          _logger.warning(
            'Outbox packet delivery failed (${entry.packetId})',
            error: error,
            stackTrace: stackTrace,
          );
          await _meshRepository.retryLater(
            entry.packetId,
            _nextAttempt(entry.attempts),
          );
        }
      }
      await _refreshCounts();
    } finally {
      _pumping = false;
    }
  }

  DateTime _nextAttempt(int attempts) {
    final exponent = attempts.clamp(0, 8);
    final milliseconds =
        AppConstants.outboxRetryBase.inMilliseconds * (1 << exponent);
    final capped = milliseconds.clamp(
      AppConstants.outboxRetryBase.inMilliseconds,
      AppConstants.outboxRetryMax.inMilliseconds,
    );
    return _clock.now().add(Duration(milliseconds: capped));
  }

  Future<void> _refreshBattery() async {
    try {
      final info = await _battery.read();
      _emit(
        _state.copyWith(batteryPercent: info.percent, charging: info.charging),
      );
      _applyRelayConditions();
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Battery reading failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _applyRelayConditions() {
    _engine.relayConditions = RelayConditions(
      relayEnabled: _settings.relayEnabled,
      batteryPercent: _state.batteryPercent,
      charging: _state.charging,
      lowThreshold: _settings.batteryThreshold,
    );
  }

  Future<void> _refreshCounts() async {
    try {
      final queue = await _meshRepository.countOutbox();
      final seen = await _meshRepository.countSeenPackets();
      _emit(_state.copyWith(queueCount: queue, seenCount: seen));
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Mesh counters refresh failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _runMaintenance() async {
    try {
      await _meshRepository.purge(_clock.now());
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Mesh maintenance failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _cancelSubscriptions() async {
    await _incomingSubscription?.cancel();
    await _statusSubscription?.cancel();
    _incomingSubscription = null;
    _statusSubscription = null;
  }

  void _emit(MeshRuntimeState next) {
    _state = next;
    if (!_disposed && !_states.isClosed) {
      _states.add(next);
    }
  }

  static String _messageFor(Object error) {
    final text = error.toString();
    return text.length > 180 ? '${text.substring(0, 180)}…' : text;
  }
}
