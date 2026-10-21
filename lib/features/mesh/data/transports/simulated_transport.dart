import 'dart:async';
import 'dart:typed_data';

import 'package:hafatra/features/mesh/domain/mesh_transport.dart';

typedef SimulatedReachability = bool Function(
  SimulatedTransport from,
  SimulatedTransport to,
);

/// Réseau en mémoire partagé par des nœuds simulés (application ou tests).
final class SimulatedNetwork {
  SimulatedNetwork({
    this.latency = const Duration(milliseconds: 60),
    this.reachability,
  });

  final Duration latency;
  final SimulatedReachability? reachability;
  final List<SimulatedTransport> _nodes = [];

  List<SimulatedTransport> get nodes => List.unmodifiable(_nodes);

  void register(SimulatedTransport transport) {
    if (!_nodes.contains(transport)) {
      _nodes.add(transport);
      _refreshPeerCounts();
    }
  }

  void unregister(SimulatedTransport transport) {
    if (_nodes.remove(transport)) {
      _refreshPeerCounts();
    }
  }

  void _refreshPeerCounts() {
    for (final node in _nodes) {
      if (node.isRunning) {
        node._emit(MeshTransportState.running);
      }
    }
  }

  int peerCountFor(SimulatedTransport transport) {
    return _nodes
        .where((other) => other != transport && _canReach(transport, other))
        .length;
  }

  Future<bool> dispatch(SimulatedTransport from, Uint8List bytes) async {
    final targets = _nodes
        .where((other) => other != from && _canReach(from, other))
        .toList();
    if (targets.isEmpty) {
      return false;
    }
    for (final target in targets) {
      unawaited(
        Future<void>.delayed(latency, () {
          if (target.isRunning) {
            target.receiveSimulated(bytes);
          }
        }),
      );
    }
    return true;
  }

  bool _canReach(SimulatedTransport from, SimulatedTransport to) {
    return reachability?.call(from, to) ?? true;
  }
}

/// Transport local. Il ne prétend jamais être du Bluetooth.
final class SimulatedTransport implements MeshTransport {
  SimulatedTransport({
    required this.network,
    required this.nodeName,
    this.virtualPeerCount = 0,
  }) : _id = 'sim-${nodeName.toLowerCase().replaceAll(' ', '-')}';

  final SimulatedNetwork network;
  final String nodeName;

  /// Pairs fictifs visibles en mode démonstration (sans second téléphone).
  final int virtualPeerCount;

  final String _id;
  final StreamController<Uint8List> _incoming =
      StreamController<Uint8List>.broadcast();
  final StreamController<MeshTransportStatus> _statusController =
      StreamController<MeshTransportStatus>.broadcast();
  final StreamController<Uint8List> _sentFrames =
      StreamController<Uint8List>.broadcast();

  late MeshTransportStatus _status = MeshTransportStatus(
    transportId: _id,
    state: MeshTransportState.stopped,
  );

  bool _running = false;

  @override
  String get id => _id;

  bool get isRunning => _running;

  @override
  Stream<Uint8List> get incoming => _incoming.stream;

  @override
  Stream<MeshTransportStatus> get statusStream => _statusController.stream;

  @override
  MeshTransportStatus get status => _status;

  /// Permet à la couche démonstration de générer des accusés réalistes.
  Stream<Uint8List> get sentFrames => _sentFrames.stream;

  @override
  Future<void> start() async {
    if (_running) {
      return;
    }
    _running = true;
    network.register(this);
    _emit(MeshTransportState.running);
  }

  @override
  Future<void> stop() async {
    if (!_running) {
      return;
    }
    _running = false;
    network.unregister(this);
    _emit(MeshTransportState.stopped, peerCount: 0);
  }

  @override
  Future<bool> send(Uint8List bytes) async {
    if (!_running) {
      return false;
    }
    _sentFrames.add(bytes);
    final accepted = await network.dispatch(this, bytes);
    _emit(MeshTransportState.running);
    return accepted || virtualPeerCount > 0;
  }

  void receiveSimulated(Uint8List bytes) {
    if (_running && !_incoming.isClosed) {
      _incoming.add(Uint8List.fromList(bytes));
    }
  }

  void _emit(MeshTransportState state, {int? peerCount}) {
    final count = peerCount ?? network.peerCountFor(this) + virtualPeerCount;
    _status = MeshTransportStatus(
      transportId: _id,
      state: state,
      peerCount: count,
    );
    if (!_statusController.isClosed) {
      _statusController.add(_status);
    }
  }

  Future<void> dispose() async {
    await stop();
    await _incoming.close();
    await _statusController.close();
    await _sentFrames.close();
  }
}
