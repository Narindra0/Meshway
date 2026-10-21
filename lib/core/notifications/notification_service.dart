import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hafatra/core/design_system/app_colors.dart';
import 'package:hafatra/core/logging/app_logger.dart';
import 'package:hafatra/features/alerts/domain/signed_alert.dart';

/// Notifications locales des alertes vérifiées.
final class NotificationService {
  NotificationService({
    required AppLogger logger,
    FlutterLocalNotificationsPlugin? plugin,
  }) : _logger = logger,
       _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String channelId = 'hafatra_alerts';
  static const String channelName = 'Alertes Hafatra';
  static const String channelDescription =
      'Alertes vérifiées par une autorité de confiance.';

  final AppLogger _logger;
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    try {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_hafatra'),
      );
      await _plugin.initialize(settings: settings);
      _initialized = true;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Local notifications initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> requestPermission() async {
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Notification permission request failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<void> showAlert(SignedAlert alert) async {
    if (!_initialized) {
      await initialize();
    }
    if (!_initialized) {
      return;
    }
    try {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_stat_hafatra',
          color: AppColors.tertiary,
          styleInformation: BigTextStyleInformation(
            alert.body,
            contentTitle: alert.title,
          ),
          ticker: alert.title,
          onlyAlertOnce: false,
        ),
      );
      await _plugin.show(
        id: alert.alertId.hashCode & 0x7fffffff,
        title: alert.title,
        body: alert.body,
        notificationDetails: details,
        payload: alert.alertId,
      );
      _logger.info('Alert notification displayed (${alert.shortId})');
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Alert notification failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
