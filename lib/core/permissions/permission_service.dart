import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:hafatra/core/logging/app_logger.dart';
import 'package:permission_handler/permission_handler.dart';

/// État des autorisations nécessaires au maillage et aux alertes.
final class PermissionSnapshot {
  const PermissionSnapshot({
    required this.bluetooth,
    required this.notifications,
    required this.batteryUnrestricted,
  });

  const PermissionSnapshot.unknown()
    : bluetooth = false,
      notifications = false,
      batteryUnrestricted = false;

  final bool bluetooth;
  final bool notifications;
  final bool batteryUnrestricted;

  bool get meshReady => bluetooth;
}

/// Centralise les demandes de permissions Android sans exposer les plugins à
/// l'interface.
final class PermissionService {
  PermissionService({required AppLogger logger, DeviceInfoPlugin? deviceInfo})
    : _logger = logger,
      _deviceInfo = deviceInfo ?? DeviceInfoPlugin();

  final AppLogger _logger;
  final DeviceInfoPlugin _deviceInfo;
  int? _sdkInt;

  Future<int> _androidSdk() async {
    final cached = _sdkInt;
    if (cached != null) {
      return cached;
    }
    if (!Platform.isAndroid) {
      return 0;
    }
    final info = await _deviceInfo.androidInfo;
    _sdkInt = info.version.sdkInt;
    return _sdkInt!;
  }

  Future<PermissionSnapshot> status() async {
    try {
      final sdk = await _androidSdk();
      final bluetooth = sdk >= 31
          ? await _allStatusGranted([
              Permission.bluetoothScan,
              Permission.bluetoothAdvertise,
              Permission.bluetoothConnect,
            ])
          : (await Permission.locationWhenInUse.status).isGranted &&
                (await Permission.bluetooth.status).isGranted;
      final notificationStatus = await Permission.notification.status;
      var batteryUnrestricted = false;
      try {
        batteryUnrestricted =
            await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      } on Object catch (error) {
        _logger.warning(
          'Battery optimization status unavailable',
          error: error,
        );
      }
      return PermissionSnapshot(
        bluetooth: bluetooth,
        notifications: notificationStatus.isGranted,
        batteryUnrestricted: batteryUnrestricted,
      );
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'Permission status unavailable',
        error: error,
        stackTrace: stackTrace,
      );
      return const PermissionSnapshot.unknown();
    }
  }

  Future<PermissionSnapshot> requestBluetooth() async {
    try {
      final sdk = await _androidSdk();
      if (sdk >= 31) {
        await [
          Permission.bluetoothScan,
          Permission.bluetoothAdvertise,
          Permission.bluetoothConnect,
        ].request();
      } else {
        await [Permission.locationWhenInUse, Permission.bluetooth].request();
      }
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Bluetooth permission request failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return await status();
  }

  Future<PermissionSnapshot> requestNotifications() async {
    try {
      await Permission.notification.request();
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Notification permission request failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
    return await status();
  }

  Future<bool> requestBatteryUnrestricted() async {
    try {
      final result =
          await FlutterForegroundTask.requestIgnoreBatteryOptimization();
      return result;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Battery optimization request failed',
        error: error,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  Future<bool> openSettings() => openAppSettings();

  Future<bool> _allStatusGranted(List<Permission> permissions) async {
    final statuses = await Future.wait(
      permissions.map((permission) => permission.status),
    );
    return statuses.every((status) => status.isGranted);
  }
}
