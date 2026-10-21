import 'package:hafatra/core/constants/mesh_constants.dart';

final class RelayConditions {
  const RelayConditions({
    required this.relayEnabled,
    required this.batteryPercent,
    required this.charging,
    required this.lowThreshold,
  });

  final bool relayEnabled;
  final int batteryPercent;
  final bool charging;
  final int lowThreshold;

  bool get batteryCritical => !charging && batteryPercent < lowThreshold;
  bool get batteryLow =>
      !charging && batteryPercent >= lowThreshold && batteryPercent <= 30;
}

/// Décide si un paquet reçu peut être retransmis.
final class RelayPolicy {
  const RelayPolicy();

  bool shouldRelay({
    required MeshPacketType type,
    required RelayConditions conditions,
  }) {
    if (!conditions.relayEnabled || conditions.batteryCritical) {
      return false;
    }
    if (conditions.batteryLow) {
      return type == MeshPacketType.alert ||
          type == MeshPacketType.deliveryAck ||
          type == MeshPacketType.relayReceipt;
    }
    return true;
  }
}
