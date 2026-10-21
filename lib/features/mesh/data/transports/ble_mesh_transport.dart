import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:bluetooth_low_energy/bluetooth_low_energy.dart';
import 'package:hafatra/core/constants/mesh_constants.dart';
import 'package:hafatra/core/errors/app_exception.dart';
import 'package:hafatra/core/logging/app_logger.dart';
import 'package:hafatra/core/utils/byte_utils.dart';
import 'package:hafatra/features/mesh/data/transports/ble_chunk_codec.dart';
import 'package:hafatra/features/mesh/domain/mesh_transport.dart';

/// Central + périphérique BLE sur un même service GATT.
///
/// Le téléphone qui possède le plus petit jeton d'annonce ouvre la connexion ;
/// l'autre attend. Les notifications de son characteristic `outbox` portent
/// les trames du périphérique vers le central.
final class BleMeshTransport implements MeshTransport {
  BleMeshTransport({
    required AppLogger logger,
    CentralManager? centralManager,
    PeripheralManager? peripheralManager,
  }) : _logger = logger,
       _central = centralManager ?? CentralManager(),
       _peripheral = peripheralManager ?? PeripheralManager(),
       _serviceUuid = UUID(MeshConstants.serviceUuid.bytes),
       _inboxUuid = UUID(MeshConstants.inboxUuid.bytes),
       _outboxUuid = UUID(MeshConstants.outboxUuid.bytes);

  @override
  String get id => 'ble';

  final AppLogger _logger;
  final CentralManager _central;
  final PeripheralManager _peripheral;
  final UUID _serviceUuid;
  final UUID _inboxUuid;
  final UUID _outboxUuid;

  final StreamController<Uint8List> _incoming =
      StreamController<Uint8List>.broadcast();
  final StreamController<MeshTransportStatus> _statusStream =
      StreamController<MeshTransportStatus>.broadcast();
  final Random _random = Random.secure();
  final List<StreamSubscription<Object?>> _subscriptions = [];
  final Map<String, _CentralLink> _links = {};
  final Map<String, Central> _centrals = {};
  final Map<String, int> _centralChunkSizes = {};
  final Map<String, BleChunkAssembler> _assemblers = {};
  final Set<String> _connecting = {};
  final Map<String, DateTime> _connectCooldown = {};
  final Set<String> _connectedPeers = {};

  late Uint8List _token;
  GATTCharacteristic? _outboxCharacteristic;
  bool _running = false;
  bool _starting = false;
  bool _disposed = false;
  late MeshTransportStatus _status = MeshTransportStatus(
    transportId: id,
    state: MeshTransportState.stopped,
  );

  @override
  Stream<Uint8List> get incoming => _incoming.stream;

  @override
  Stream<MeshTransportStatus> get statusStream => _statusStream.stream;

  @override
  MeshTransportStatus get status => _status;

  @override
  Future<void> start() async {
    if (_running || _starting) {
      return;
    }
    _starting = true;
    _emit(MeshTransportState.starting);
    try {
      _ensurePoweredOn();
      _token = ByteUtils.randomBytes(8);
      _listenToEvents();
      await _publishService();
      await _peripheral.startAdvertising(
        Advertisement(
          serviceUUIDs: [_serviceUuid],
          serviceData: {_serviceUuid: _token},
        ),
      );
      await _central.startDiscovery(serviceUUIDs: [_serviceUuid]);
      _running = true;
      _emit(MeshTransportState.running);
      _logger.info('BLE transport started');
    } on Object catch (error, stackTrace) {
      _logger.error(
        'BLE transport start failed',
        error: error,
        stackTrace: stackTrace,
      );
      await _stopInternal();
      _emit(
        MeshTransportState.error,
        lastError: error is AppException ? error.message : error.toString(),
      );
      if (error is AppException) {
        rethrow;
      }
      throw TransportException(
        'Le Bluetooth n’a pas pu démarrer.',
        cause: error,
        stackTrace: stackTrace,
      );
    } finally {
      _starting = false;
    }
  }

  @override
  Future<void> stop() async {
    await _stopInternal();
    _emit(MeshTransportState.stopped, peerCount: 0);
    _logger.info('BLE transport stopped');
  }

  @override
  Future<bool> send(Uint8List bytes) async {
    if (!_running) {
      return false;
    }
    var accepted = false;
    final savedValue = Uint8List.fromList(bytes);

    final linkEntries = _links.entries.toList();
    for (final entry in linkEntries) {
      try {
        final chunks = BleChunkCodec.encode(
          savedValue,
          transferId: _random.nextInt(65536),
          payloadLength: entry.value.maxWriteLength,
        );
        for (final chunk in chunks) {
          await _central.writeCharacteristic(
            entry.value.peripheral,
            entry.value.inbox,
            value: chunk,
            type: GATTCharacteristicWriteType.withResponse,
          );
        }
        accepted = true;
      } on Object catch (error, stackTrace) {
        _logger.warning(
          'BLE write failed (${_shortUuid(entry.key)})',
          error: error,
          stackTrace: stackTrace,
        );
        _removeLink(entry.key);
      }
    }

    final outbox = _outboxCharacteristic;
    if (outbox != null) {
      final centralEntries = _centrals.entries.toList();
      for (final entry in centralEntries) {
        if (!_isSubscribed(entry.key)) {
          continue;
        }
        try {
          final payloadLength = _centralChunkSizes[entry.key] ?? 20;
          final chunks = BleChunkCodec.encode(
            savedValue,
            transferId: _random.nextInt(65536),
            payloadLength: payloadLength,
          );
          for (final chunk in chunks) {
            await _peripheral.notifyCharacteristic(
              entry.value,
              outbox,
              value: chunk,
            );
            await Future<void>.delayed(const Duration(milliseconds: 8));
          }
          accepted = true;
        } on Object catch (error, stackTrace) {
          _logger.warning(
            'BLE notify failed (${_shortUuid(entry.key)})',
            error: error,
            stackTrace: stackTrace,
          );
          _centrals.remove(entry.key);
          _centralChunkSizes.remove(entry.key);
          _connectedPeers.remove(entry.key);
        }
      }
    }
    if (accepted) {
      _emit(MeshTransportState.running);
    }
    return accepted;
  }

  Future<void> dispose() async {
    _disposed = true;
    await stop();
    await _incoming.close();
    await _statusStream.close();
  }

  bool _isSubscribed(String centralId) {
    return _centralChunkSizes.containsKey(centralId);
  }

  void _ensurePoweredOn() {
    final centralState = _central.state;
    final peripheralState = _peripheral.state;
    if (centralState == BluetoothLowEnergyState.unsupported ||
        peripheralState == BluetoothLowEnergyState.unsupported) {
      throw const TransportException(
        'Ce téléphone ne prend pas en charge le Bluetooth LE.',
      );
    }
    if (centralState == BluetoothLowEnergyState.unauthorized ||
        peripheralState == BluetoothLowEnergyState.unauthorized) {
      throw const PermissionException(
        'L’autorisation Bluetooth est nécessaire.',
      );
    }
    if (centralState != BluetoothLowEnergyState.poweredOn ||
        peripheralState != BluetoothLowEnergyState.poweredOn) {
      throw const TransportException(
        'Activez le Bluetooth pour rejoindre le maillage.',
      );
    }
  }

  void _listenToEvents() {
    _subscriptions
      ..add(
        _central.stateChanged.listen((event) {
          if (event.state != BluetoothLowEnergyState.poweredOn) {
            _emit(
              MeshTransportState.unavailable,
              lastError: 'Bluetooth désactivé.',
            );
          } else if (_running) {
            _emit(MeshTransportState.running);
          }
        }),
      )
      ..add(
        _peripheral.stateChanged.listen((event) {
          if (event.state != BluetoothLowEnergyState.poweredOn) {
            _emit(
              MeshTransportState.unavailable,
              lastError: 'Bluetooth désactivé.',
            );
          }
        }),
      )
      ..add(_central.discovered.listen(_onDiscovered))
      ..add(_central.connectionStateChanged.listen(_onCentralConnectionChanged))
      ..add(_central.characteristicNotified.listen(_onCharacteristicNotified))
      ..add(
        _peripheral.connectionStateChanged.listen(
          _onPeripheralConnectionChanged,
        ),
      )
      ..add(
        _peripheral.characteristicWriteRequested.listen(
          _onCharacteristicWriteRequested,
        ),
      )
      ..add(
        _peripheral.characteristicNotifyStateChanged.listen(
          _onNotifyStateChanged,
        ),
      );
  }

  Future<void> _publishService() async {
    await _peripheral.removeAllServices();
    final inbox = GATTCharacteristic.mutable(
      uuid: _inboxUuid,
      properties: [
        GATTCharacteristicProperty.write,
        GATTCharacteristicProperty.writeWithoutResponse,
      ],
      permissions: [GATTCharacteristicPermission.write],
      descriptors: [],
    );
    final outbox = GATTCharacteristic.mutable(
      uuid: _outboxUuid,
      properties: [GATTCharacteristicProperty.notify],
      permissions: [GATTCharacteristicPermission.read],
      descriptors: [],
    );
    final service = GATTService(
      uuid: _serviceUuid,
      isPrimary: true,
      includedServices: [],
      characteristics: [inbox, outbox],
    );
    await _peripheral.addService(service);
    _outboxCharacteristic = outbox;
  }

  void _onDiscovered(DiscoveredEventArgs event) {
    final advertisement = event.advertisement;
    if (!advertisement.serviceUUIDs.contains(_serviceUuid)) {
      return;
    }
    final peerId = event.peripheral.uuid.toString();
    if (_links.containsKey(peerId) ||
        _connecting.contains(peerId) ||
        !_shouldInitiate(advertisement, peerId)) {
      return;
    }
    final lastAttempt = _connectCooldown[peerId];
    if (lastAttempt != null &&
        DateTime.now().difference(lastAttempt) <
            MeshConstants.bleReconnectCooldown) {
      return;
    }
    _connectCooldown[peerId] = DateTime.now();
    unawaited(_connect(event.peripheral, event.rssi));
  }

  bool _shouldInitiate(Advertisement advertisement, String peerId) {
    final remote = advertisement.serviceData[_serviceUuid];
    if (remote == null || remote.length != 8) {
      // Android diffuse toujours serviceData. Si un pair ne le fait pas, on
      // évite les doubles connexions en ne prenant l'initiative qu'une fois sur
      // deux, de façon déterministe à partir de son adresse.
      return peerId.hashCode.isEven;
    }
    for (var i = 0; i < 8; i++) {
      if (_token[i] < remote[i]) {
        return true;
      }
      if (_token[i] > remote[i]) {
        return false;
      }
    }
    return false;
  }

  Future<void> _connect(Peripheral peripheral, int rssi) async {
    final peerId = peripheral.uuid.toString();
    _connecting.add(peerId);
    try {
      await _central
          .connect(peripheral)
          .timeout(MeshConstants.bleConnectionTimeout);
      final services = await _central
          .discoverGATT(peripheral)
          .timeout(MeshConstants.bleConnectionTimeout);
      GATTService? service;
      for (final candidate in services) {
        if (candidate.uuid == _serviceUuid) {
          service = candidate;
          break;
        }
      }
      if (service == null) {
        throw const TransportException('Service Hafatra absent.');
      }
      GATTCharacteristic? inbox;
      GATTCharacteristic? outbox;
      for (final characteristic in service.characteristics) {
        if (characteristic.uuid == _inboxUuid) {
          inbox = characteristic;
        } else if (characteristic.uuid == _outboxUuid) {
          outbox = characteristic;
        }
      }
      if (inbox == null || outbox == null) {
        throw const TransportException('Characteristics Hafatra absentes.');
      }
      await _central.setCharacteristicNotifyState(
        peripheral,
        outbox,
        state: true,
      );
      var maxWriteLength = MeshConstants.bleChunkPayloadLength;
      try {
        await _central.requestMTU(peripheral, mtu: 517);
        final maxLength = await _central.getMaximumWriteLength(
          peripheral,
          type: GATTCharacteristicWriteType.withResponse,
        );
        maxWriteLength = (maxLength - MeshConstants.bleChunkHeaderLength).clamp(
          1,
          MeshConstants.bleChunkPayloadLength,
        );
      } on Object {
        maxWriteLength = 20;
      }
      _links[peerId] = _CentralLink(
        peripheral: peripheral,
        inbox: inbox,
        maxWriteLength: maxWriteLength,
      );
      _assemblers.putIfAbsent(peerId, BleChunkAssembler.new);
      _connectedPeers.add(peerId);
      _logger.info('BLE link established (${_shortUuid(peerId)}, rssi=$rssi)');
      _emit(MeshTransportState.running);
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'BLE connection failed (${_shortUuid(peerId)})',
        error: error,
        stackTrace: stackTrace,
      );
      try {
        await _central.disconnect(peripheral);
      } on Object {
        // La connexion n'a jamais abouti : rien à libérer.
      }
    } finally {
      _connecting.remove(peerId);
    }
  }

  void _onCentralConnectionChanged(
    PeripheralConnectionStateChangedEventArgs event,
  ) {
    if (event.state != ConnectionState.connected) {
      _removeLink(event.peripheral.uuid.toString());
    }
  }

  void _onPeripheralConnectionChanged(
    CentralConnectionStateChangedEventArgs event,
  ) {
    final id = event.central.uuid.toString();
    if (event.state == ConnectionState.connected) {
      _centrals[id] = event.central;
      _connectedPeers.add(id);
      _emit(MeshTransportState.running);
    } else {
      _centrals.remove(id);
      _centralChunkSizes.remove(id);
      _connectedPeers.remove(id);
      _emit(MeshTransportState.running);
    }
  }

  void _onCharacteristicNotified(GATTCharacteristicNotifiedEventArgs event) {
    if (event.characteristic.uuid != _outboxUuid) {
      return;
    }
    final peerId = event.peripheral.uuid.toString();
    try {
      _handleChunk(peerId, event.value);
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'BLE incoming notification rejected (${_shortUuid(peerId)})',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> _onCharacteristicWriteRequested(
    GATTCharacteristicWriteRequestedEventArgs event,
  ) async {
    final peerId = event.central.uuid.toString();
    var ok = false;
    try {
      if (event.characteristic.uuid == _inboxUuid) {
        _handleChunk(peerId, event.request.value);
        ok = true;
      }
    } on Object catch (error) {
      _logger.warning('BLE incoming chunk rejected', error: error);
    }
    try {
      if (ok) {
        await _peripheral.respondWriteRequest(event.request);
      } else {
        await _peripheral.respondWriteRequestWithError(
          event.request,
          error: GATTError.invalidAttributeValueLength,
        );
      }
    } on Object catch (error, stackTrace) {
      _logger.warning(
        'BLE write response failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _handleChunk(String peerId, Uint8List chunk) {
    final assembler = _assemblers.putIfAbsent(peerId, BleChunkAssembler.new);
    final frame = assembler.add(chunk);
    if (frame != null) {
      if (!_incoming.isClosed) {
        _incoming.add(frame);
      }
      _emit(MeshTransportState.running);
    }
  }

  Future<void> _onNotifyStateChanged(
    GATTCharacteristicNotifyStateChangedEventArgs event,
  ) async {
    if (event.characteristic.uuid != _outboxUuid) {
      return;
    }
    final id = event.central.uuid.toString();
    if (!event.state) {
      _centralChunkSizes.remove(id);
      return;
    }
    var length = 20;
    try {
      final maxLength = await _peripheral.getMaximumNotifyLength(event.central);
      length = (maxLength - MeshConstants.bleChunkHeaderLength).clamp(
        1,
        MeshConstants.bleChunkPayloadLength,
      );
    } on Object {
      length = 20;
    }
    _centralChunkSizes[id] = length;
    _centrals[id] = event.central;
    _emit(MeshTransportState.running);
  }

  void _removeLink(String peerId) {
    _links.remove(peerId);
    _connectedPeers.remove(peerId);
    _assemblers.remove(peerId);
    _emit(MeshTransportState.running);
  }

  Future<void> _stopInternal() async {
    _running = false;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    try {
      await _central.stopDiscovery();
    } on Object {
      // Le plugin peut déjà être arrêté.
    }
    try {
      await _peripheral.stopAdvertising();
    } on Object {
      // Idem.
    }
    for (final link in _links.values) {
      try {
        await _central.disconnect(link.peripheral);
      } on Object {
        // Déjà déconnecté.
      }
    }
    for (final central in _centrals.values) {
      try {
        await _peripheral.disconnect(central);
      } on Object {
        // Déjà déconnecté.
      }
    }
    _links.clear();
    _centrals.clear();
    _centralChunkSizes.clear();
    _assemblers.clear();
    _connectedPeers.clear();
    try {
      await _peripheral.removeAllServices();
    } on Object {
      // Service jamais publié.
    }
    _outboxCharacteristic = null;
  }

  void _emit(MeshTransportState state, {int? peerCount, String? lastError}) {
    if (_disposed) {
      return;
    }
    _status = MeshTransportStatus(
      transportId: id,
      state: state,
      peerCount: peerCount ?? _connectedPeers.length,
      lastError: lastError,
    );
    if (!_statusStream.isClosed) {
      _statusStream.add(_status);
    }
  }

  static String _shortUuid(String value) {
    return value.length <= 8 ? value : value.substring(0, 8);
  }
}

final class _CentralLink {
  const _CentralLink({
    required this.peripheral,
    required this.inbox,
    required this.maxWriteLength,
  });

  final Peripheral peripheral;
  final GATTCharacteristic inbox;
  final int maxWriteLength;
}
