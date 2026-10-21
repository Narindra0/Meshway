import 'package:battery_plus/battery_plus.dart';

/// Photographie de la batterie, utilisée pour la politique de relais.
final class BatteryInfo {
  const BatteryInfo({required this.percent, required this.charging});

  const BatteryInfo.unknown() : percent = 100, charging = false;

  final int percent;
  final bool charging;
}

/// Contrat minimal pour pouvoir simuler la batterie dans les tests.
abstract interface class BatteryInfoSource {
  Future<BatteryInfo> read();
}

final class BatteryPlusInfoSource implements BatteryInfoSource {
  BatteryPlusInfoSource({Battery? battery}) : _battery = battery ?? Battery();

  final Battery _battery;

  @override
  Future<BatteryInfo> read() async {
    final percent = await _battery.batteryLevel;
    final state = await _battery.batteryState;
    return BatteryInfo(
      percent: percent.clamp(0, 100),
      charging:
          state == BatteryState.charging ||
          state == BatteryState.full ||
          state == BatteryState.connectedNotCharging,
    );
  }
}
