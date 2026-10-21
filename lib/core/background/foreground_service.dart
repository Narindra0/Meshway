import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:hafatra/core/design_system/app_colors.dart';
import 'package:hafatra/core/logging/app_logger.dart';

/// Handler minimal : le moteur BLE vit dans l'isolate principal. Le service de
/// premier plan maintient le processus actif sans créer un second émetteur.
final class HafatraTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {}
}

@pragma('vm:entry-point')
void hafatraForegroundCallback() {
  FlutterForegroundTask.setTaskHandler(HafatraTaskHandler());
}

/// Encapsule `flutter_foreground_task` pour que l'application n'en dépende pas
/// directement.
final class ForegroundServiceController {
  ForegroundServiceController({required AppLogger logger}) : _logger = logger;

  static const String _iconMetadata = 'mg.hafatra.SERVICE_ICON';
  static const int _serviceId = 41;

  final AppLogger _logger;
  bool _initialized = false;
  bool _running = false;

  bool get isRunning => _running;

  static void initialize() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'hafatra_service',
        channelName: 'Relais Hafatra',
        channelDescription:
            'Maintient le relais de messages actif en arrière-plan.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
        enableVibration: false,
        playSound: false,
        showWhen: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.nothing(),
        autoRunOnBoot: false,
        autoRunOnMyPackageReplaced: false,
        allowWakeLock: true,
        allowWifiLock: false,
        allowAutoRestart: true,
        stopWithTask: false,
      ),
    );
    FlutterForegroundTask.initCommunicationPort();
  }

  Future<bool> start({
    required String title,
    required String text,
    bool demo = false,
  }) async {
    _initialized = true;
    try {
      final result = FlutterForegroundTask.startService(
        serviceId: _serviceId,
        serviceTypes: const [ForegroundServiceTypes.connectedDevice],
        notificationTitle: title,
        notificationText: text,
        notificationIcon: const NotificationIcon(
          metaDataName: _iconMetadata,
          backgroundColor: AppColors.primary,
        ),
        notificationInitialRoute: '/chat',
        callback: hafatraForegroundCallback,
      );
      final request = await result;
      if (request is ServiceRequestSuccess) {
        _running = true;
        _logger.info('Foreground mesh service started (demo=$demo)');
        return true;
      }
      _logger.warning('Foreground mesh service refused: $request');
      return _running = await FlutterForegroundTask.isRunningService;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Foreground mesh service start failed',
        error: error,
        stackTrace: stackTrace,
      );
      _running = false;
      return false;
    }
  }

  Future<void> update({required String title, required String text}) async {
    if (!_initialized) {
      return;
    }
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.updateService(
          notificationTitle: title,
          notificationText: text,
        );
        _running = true;
      }
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Foreground mesh service update failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> stop() async {
    if (!_initialized) {
      return;
    }
    try {
      if (await FlutterForegroundTask.isRunningService) {
        await FlutterForegroundTask.stopService();
        _logger.info('Foreground mesh service stopped');
      }
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Foreground mesh service stop failed',
        error: error,
        stackTrace: stackTrace,
      );
    } finally {
      _running = false;
    }
  }
}
