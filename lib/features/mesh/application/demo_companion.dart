import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:hafatra/core/constants/mesh_constants.dart';
import 'package:hafatra/core/crypto/crypto_service.dart';
import 'package:hafatra/core/logging/app_logger.dart';
import 'package:hafatra/core/utils/byte_utils.dart';
import 'package:hafatra/features/chat/data/chat_repository.dart';
import 'package:hafatra/features/identity/domain/channel_info.dart';
import 'package:hafatra/features/mesh/data/codec/mesh_packet_codec.dart';
import 'package:hafatra/features/mesh/data/codec/payload_codecs.dart';
import 'package:hafatra/features/mesh/data/transports/simulated_transport.dart';
import 'package:hafatra/features/mesh/domain/mesh_packet.dart';

/// Un voisin fictif avec sa propre clé Ed25519.
final class DemoPeer {
  const DemoPeer({required this.name, required this.material});

  final String name;
  final KeyMaterial material;
}

/// Complète le réseau simulé avec des voisins crédibles : message d'accueil,
/// accusés de réception et reçus de relais signés par leurs propres clés.
final class DemoCompanion {
  DemoCompanion({
    required SimulatedTransport transport,
    required MeshPacketCodec codec,
    required ChannelInfo channel,
    required CryptoService crypto,
    required ChatRepository chatRepository,
    required AppLogger logger,
    required String welcomeText,
    Random? random,
    this.receiptDelay = const Duration(milliseconds: 900),
    this.ackDelay = const Duration(milliseconds: 2200),
  }) : _transport = transport,
       _codec = codec,
       _channel = channel,
       _crypto = crypto,
       _chatRepository = chatRepository,
       _logger = logger,
       _welcomeText = welcomeText,
       _random = random ?? Random();

  final SimulatedTransport _transport;
  final MeshPacketCodec _codec;
  final ChannelInfo _channel;
  final CryptoService _crypto;
  final ChatRepository _chatRepository;
  final AppLogger _logger;
  final String _welcomeText;
  final Random _random;
  final Duration receiptDelay;
  final Duration ackDelay;
  final List<Timer> _timers = [];
  final Set<String> _answered = {};

  StreamSubscription<Uint8List>? _sentSubscription;
  List<DemoPeer> _peers = const [];
  bool _started = false;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;
    _peers = await _buildPeers();
    _sentSubscription = _transport.sentFrames.listen(_onSentFrame);
    if ((await _chatRepository.getMessages(_channel.id)).isEmpty) {
      _schedule(const Duration(milliseconds: 1200), _sendWelcome);
    }
    _logger.info('Demo companion started (${_peers.length} virtual peers)');
  }

  Future<void> stop() async {
    _started = false;
    for (final timer in _timers) {
      timer.cancel();
    }
    _timers.clear();
    await _sentSubscription?.cancel();
    _sentSubscription = null;
  }

  void _schedule(Duration delay, Future<void> Function() action) {
    final timer = Timer(delay, () {
      if (!_started) {
        return;
      }
      unawaited(
        action().catchError((Object error, StackTrace stackTrace) {
          _logger.warning(
            'Demo companion action failed',
            error: error,
            stackTrace: stackTrace,
          );
        }),
      );
    });
    _timers.add(timer);
  }

  Future<void> _sendWelcome() async {
    if (_peers.isEmpty) {
      return;
    }
    final peer = _peers.first;
    final packet = await _codec.createSignedPacket(
      type: MeshPacketType.chat,
      channelId: _channel.idBytes,
      senderPublicKey: peer.material.publicKey,
      payload: ChatPayloadCodec.encode(
        ChatPayload(senderName: peer.name, text: _welcomeText),
      ),
      signer: (message) => _crypto.sign(message, peer.material),
    );
    _deliver(packet);
    _logger.debug('Demo peer ${peer.name} sent welcome message');
  }

  void _onSentFrame(Uint8List bytes) {
    if (!_started) {
      return;
    }
    unawaited(_handleSentFrame(bytes));
  }

  Future<void> _handleSentFrame(Uint8List bytes) async {
    MeshPacket packet;
    try {
      packet = _codec.decode(bytes);
    } on FormatException {
      return;
    }
    if (packet.type != MeshPacketType.chat || _peers.isEmpty) {
      return;
    }
    final messageId = ByteUtils.canonicalUuid(packet.messageId);
    if (_answered.contains(messageId)) {
      return;
    }
    final message = await _chatRepository.findById(messageId);
    if (message == null || !message.isOutgoing) {
      return;
    }
    _answered.add(messageId);
    final relayPeers = _peers.take(min(2, _peers.length)).toList();
    for (var index = 0; index < relayPeers.length; index++) {
      final peer = relayPeers[index];
      _schedule(
        receiptDelay + Duration(milliseconds: index * 450),
        () => _sendRelayReceipt(peer, messageId),
      );
    }
    final ackPeer = _peers[_random.nextInt(_peers.length)];
    _schedule(ackDelay, () => _sendDeliveryAck(ackPeer, messageId));
  }

  Future<void> _sendRelayReceipt(DemoPeer peer, String messageId) async {
    final packet = await _codec.createSignedPacket(
      type: MeshPacketType.relayReceipt,
      channelId: _channel.idBytes,
      senderPublicKey: peer.material.publicKey,
      payload: RelayReceiptCodec.encode(
        RelayReceiptPayload(messageId: messageId, hops: 1),
      ),
      signer: (message) => _crypto.sign(message, peer.material),
    );
    _deliver(packet);
  }

  Future<void> _sendDeliveryAck(DemoPeer peer, String messageId) async {
    final packet = await _codec.createSignedPacket(
      type: MeshPacketType.deliveryAck,
      channelId: _channel.idBytes,
      senderPublicKey: peer.material.publicKey,
      payload: DeliveryAckCodec.encode(
        DeliveryAckPayload(messageId: messageId, status: 1),
      ),
      signer: (message) => _crypto.sign(message, peer.material),
    );
    _deliver(packet);
  }

  void _deliver(MeshPacket packet) {
    if (!_started) {
      return;
    }
    _transport.receiveSimulated(_codec.encode(packet));
  }

  Future<List<DemoPeer>> _buildPeers() async {
    const names = ['Rasoa', 'Tobia', 'Naina'];
    final peers = <DemoPeer>[];
    for (final name in names) {
      final seed = await _crypto.sha256(
        utf8.encode('hafatra:demo-peer:v1:$name'),
      );
      final material = await _crypto.keyMaterialFromSeed(seed);
      peers.add(DemoPeer(name: name, material: material));
    }
    return List<DemoPeer>.unmodifiable(peers);
  }
}
