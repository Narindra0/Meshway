import 'dart:typed_data';

enum MeshTransportState { stopped, starting, running, unavailable, error }

final class MeshTransportStatus {
  const MeshTransportStatus({
    required this.transportId,
    required this.state,
    this.peerCount = 0,
    this.detail,
    this.lastError,
  });

  final String transportId;
  final MeshTransportState state;
  final int peerCount;
  final String? detail;
  final String? lastError;

  bool get isRunning => state == MeshTransportState.running;

  MeshTransportStatus copyWith({
    MeshTransportState? state,
    int? peerCount,
    String? detail,
    String? lastError,
    bool clearError = false,
  }) {
    return MeshTransportStatus(
      transportId: transportId,
      state: state ?? this.state,
      peerCount: peerCount ?? this.peerCount,
      detail: detail ?? this.detail,
      lastError: clearError ? null : (lastError ?? this.lastError),
    );
  }
}

/// Contrat que tout transport (BLE, simulation, futur Wi-Fi Direct…) respecte.
abstract interface class MeshTransport {
  String get id;

  Stream<Uint8List> get incoming;

  Stream<MeshTransportStatus> get statusStream;

  MeshTransportStatus get status;

  Future<void> start();

  Future<void> stop();

  /// Retourne true si la trame a été acceptée par au moins un pair.
  Future<bool> send(Uint8List bytes);
}
