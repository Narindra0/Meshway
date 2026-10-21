import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:hafatra/core/constants/app_constants.dart';
import 'package:hafatra/core/constants/mesh_constants.dart';
import 'package:hafatra/core/errors/app_exception.dart';
import 'package:hafatra/core/logging/app_logger.dart';
import 'package:hafatra/core/utils/byte_utils.dart';
import 'package:hafatra/core/utils/clock.dart';
import 'package:hafatra/core/utils/id_generator.dart';
import 'package:hafatra/features/alerts/data/alert_service.dart';
import 'package:hafatra/features/alerts/domain/alert_verifier.dart';
import 'package:hafatra/features/alerts/domain/signed_alert.dart';
import 'package:hafatra/features/chat/data/chat_repository.dart';
import 'package:hafatra/features/chat/domain/chat_message.dart';
import 'package:hafatra/features/identity/data/identity_service.dart';
import 'package:hafatra/features/identity/domain/channel_info.dart';
import 'package:hafatra/features/mesh/data/codec/mesh_packet_codec.dart';
import 'package:hafatra/features/mesh/data/codec/payload_codecs.dart';
import 'package:hafatra/features/mesh/data/mesh_repository.dart';
import 'package:hafatra/features/mesh/domain/mesh_packet.dart';
import 'package:hafatra/features/mesh/domain/rate_limiter.dart';
import 'package:hafatra/features/mesh/domain/relay_policy.dart';

/// Cœur du protocole : reçoit, vérifie, persiste, accuse et relaie.
final class MeshEngine {
  MeshEngine({
    required MeshPacketCodec codec,
    required ChatRepository chatRepository,
    required MeshRepository meshRepository,
    required AlertService alertService,
    required IdentityService identityService,
    required ChannelInfo channel,
    required Clock clock,
    required IdGenerator idGenerator,
    required AppLogger logger,
    MeshRateLimiter? rateLimiter,
    RelayPolicy relayPolicy = const RelayPolicy(),
  }) : _codec = codec,
       _chatRepository = chatRepository,
       _meshRepository = meshRepository,
       _alertService = alertService,
       _identityService = identityService,
       _channel = channel,
       _clock = clock,
       _idGenerator = idGenerator,
       _logger = logger,
       _rateLimiter = rateLimiter ?? MeshRateLimiter(),
       _relayPolicy = relayPolicy;

  final MeshPacketCodec _codec;
  final ChatRepository _chatRepository;
  final MeshRepository _meshRepository;
  final AlertService _alertService;
  final IdentityService _identityService;
  final ChannelInfo _channel;
  final Clock _clock;
  final IdGenerator _idGenerator;
  final AppLogger _logger;
  final MeshRateLimiter _rateLimiter;
  final RelayPolicy _relayPolicy;

  /// Conditions locales utilisées par la politique de relais.
  RelayConditions relayConditions = const RelayConditions(
    relayEnabled: true,
    batteryPercent: 100,
    charging: false,
    lowThreshold: 15,
  );
  Future<void> _processing = Future<void>.value();

  /// Envoie un message de salon et le place dans l'outbox persistante.
  Future<MeshPacket> sendChat(String text) async {
    final identity = _identityService.current;
    if (identity == null) {
      throw const CryptoException('Aucune identité locale.');
    }
    final clean = text.trim();
    if (clean.isEmpty) {
      throw const ValidationException('Le message est vide.');
    }
    final byteLength = utf8.encode(clean).length;
    if (byteLength > AppConstants.maxMessageBytes) {
      throw ValidationException(
        'Message trop long ($byteLength octets sur '
        '${AppConstants.maxMessageBytes}).',
      );
    }
    final payload = ChatPayloadCodec.encode(
      ChatPayload(senderName: identity.displayName, text: clean),
    );
    final packet = await _codec.createSignedPacket(
      type: MeshPacketType.chat,
      channelId: _channel.idBytes,
      senderPublicKey: identity.publicKey,
      payload: payload,
      signer: _identityService.sign,
    );
    final messageId = ByteUtils.canonicalUuid(packet.messageId);
    final message = ChatMessage(
      id: messageId,
      channelId: _channel.id,
      senderId: packet.senderIdHex,
      senderName: identity.displayName,
      body: clean,
      createdAt: packet.createdAt,
      direction: MessageDirection.outgoing,
      status: ChatMessageStatus.queued,
      priority: MeshConstants.priorityChat,
      relayCount: 0,
      seenCount: 0,
      expiresAt: packet.createdAt.add(AppConstants.messageLifetime),
    );
    await _chatRepository.insertOutgoing(message);
    await _enqueuePacket(
      packet,
      priority: MeshConstants.priorityChat,
      markSeen: true,
    );
    _logger.info('Chat packet queued (${packet.messageIdHex.substring(0, 8)})');
    return packet;
  }

  /// Injecte une alerte déjà vérifiée dans le maillage, avec une signature de
  /// transport par l'identité locale.
  Future<MeshPacket> broadcastVerifiedAlert(SignedAlert alert) async {
    final identity = _identityService.current;
    if (identity == null) {
      throw const CryptoException('Aucune identité locale.');
    }
    final payload = Uint8List.fromList(utf8.encode(jsonEncode(alert.toJson())));
    final packet = await _codec.createSignedPacket(
      type: MeshPacketType.alert,
      channelId: _channel.idBytes,
      senderPublicKey: identity.publicKey,
      payload: payload,
      signer: _identityService.sign,
    );
    await _enqueuePacket(
      packet,
      priority: MeshConstants.priorityAlert,
      markSeen: true,
    );
    return packet;
  }

  /// Vérifie et stocke une alerte locale puis la diffuse si elle est valide.
  Future<AlertVerification> injectAlert(SignedAlert alert) async {
    final verification = await _alertService.verifyAndStore(alert);
    if (verification.isAccepted) {
      await broadcastVerifiedAlert(alert);
    }
    return verification;
  }

  Future<void> handleFrame(Uint8List bytes) {
    final next = _processing.then((_) => _handleFrame(bytes));
    return _processing = next.catchError((Object error, StackTrace stackTrace) {
      _logger.error(
        'Mesh frame processing failed',
        error: error,
        stackTrace: stackTrace,
      );
    });
  }

  Future<void> _handleFrame(Uint8List bytes) async {
    MeshPacket packet;
    try {
      packet = _codec.decode(bytes);
    } on FormatException catch (error) {
      _logger.warning('Invalid mesh packet dropped', error: error);
      return;
    }
    final now = _clock.now();
    if (!ByteUtils.constantTimeEquals(packet.channelId, _channel.idBytes)) {
      _logger.warning('Packet for another channel dropped');
      return;
    }
    final validSignature = await _codec.verify(packet);
    if (!validSignature) {
      _logger.warning('Packet with invalid signature dropped');
      return;
    }
    if (packet.createdAt.isAfter(now.add(const Duration(minutes: 10))) ||
        packet.createdAt.isBefore(now.subtract(const Duration(days: 8)))) {
      _logger.warning('Packet with implausible timestamp dropped');
      return;
    }
    final identity = _identityService.current;
    if (identity != null && packet.senderIdHex == identity.id) {
      // Paquet local revenu par un relais : le dédoublonnage local l'a déjà vu.
      return;
    }
    final isNew = await _meshRepository.markPacketSeen(
      packetId: packet.messageIdHex,
      now: now,
      expiresAt: now.add(MeshConstants.dedupRetention),
    );
    if (!isNew) {
      return;
    }
    if ((packet.type == MeshPacketType.chat ||
            packet.type == MeshPacketType.alert) &&
        !_rateLimiter.allow(packet.senderIdHex, now)) {
      _logger.warning(
        'Sender rate limit reached (${packet.senderIdHex.substring(0, 8)})',
      );
      return;
    }

    var shouldRelay = false;
    try {
      switch (packet.type) {
        case MeshPacketType.chat:
          shouldRelay = await _handleChat(packet, now);
        case MeshPacketType.alert:
          shouldRelay = await _handleAlert(packet, now);
        case MeshPacketType.deliveryAck:
          shouldRelay = await _handleDeliveryAck(packet, now);
        case MeshPacketType.relayReceipt:
          shouldRelay = await _handleRelayReceipt(packet, now);
        case MeshPacketType.safety:
        case MeshPacketType.profile:
          shouldRelay = false;
      }
    } on FormatException catch (error) {
      _logger.warning('Invalid payload dropped', error: error);
      return;
    } on Object catch (error, stackTrace) {
      _logger.error(
        'Mesh packet handling failed',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }

    if (!shouldRelay || packet.ttl <= MeshConstants.minTtl) {
      return;
    }
    if (!_relayPolicy.shouldRelay(
      type: packet.type,
      conditions: relayConditions,
    )) {
      return;
    }
    final relayed = packet.copyWith(
      ttl: packet.ttl - 1,
      hopCount: packet.hopCount + 1,
    );
    await _enqueuePacket(
      relayed,
      priority: _priorityFor(packet.type),
      markSeen: false,
    );
    _logger.debug(
      'Packet relayed (${packet.messageIdHex.substring(0, 8)}, '
      'ttl=${relayed.ttl})',
    );
  }

  /// Appelé par le runtime après qu'un paquet de l'outbox a été accepté par au
  /// moins un pair. Le reçu de relais n'est émis qu'à ce moment : « relayé »
  /// signifie donc que le paquet a réellement quitté le téléphone.
  Future<void> onPacketTransmitted(Uint8List bytes) async {
    try {
      final packet = _codec.decode(bytes);
      if (packet.type == MeshPacketType.chat && packet.hopCount > 0) {
        await _sendRelayReceipt(packet, packet.hopCount);
      }
    } on FormatException catch (error) {
      _logger.warning('Outbox packet could not be decoded', error: error);
    }
  }

  Future<bool> _handleChat(MeshPacket packet, DateTime now) async {
    final payload = ChatPayloadCodec.decode(packet.payload);
    final messageId = ByteUtils.canonicalUuid(packet.messageId);
    final inserted = await _chatRepository.insertIncoming(
      ChatMessage(
        id: messageId,
        channelId: _channel.id,
        senderId: packet.senderIdHex,
        senderName: payload.senderName,
        body: payload.text,
        createdAt: packet.createdAt,
        direction: MessageDirection.incoming,
        status: ChatMessageStatus.seen,
        priority: MeshConstants.priorityChat,
        relayCount: 0,
        seenCount: 0,
        expiresAt: now.add(AppConstants.messageRetention),
      ),
    );
    if (inserted) {
      await _sendDeliveryAck(messageId, packet.senderIdHex);
    }
    return true;
  }

  Future<bool> _handleAlert(MeshPacket packet, DateTime now) async {
    final source = utf8.decode(packet.payload, allowMalformed: false);
    final alert = SignedAlert.fromJsonString(source);
    final verification = await _alertService.verifyAndStore(alert);
    return verification.isAccepted;
  }

  Future<bool> _handleDeliveryAck(MeshPacket packet, DateTime now) async {
    final payload = DeliveryAckCodec.decode(packet.payload);
    await _meshRepository.recordDeliveryAck(
      messageId: payload.messageId,
      ackSenderId: packet.senderIdHex,
      status: payload.status,
      receivedAt: now,
    );
    return true;
  }

  Future<bool> _handleRelayReceipt(MeshPacket packet, DateTime now) async {
    final payload = RelayReceiptCodec.decode(packet.payload);
    await _meshRepository.recordRelayReceipt(
      messageId: payload.messageId,
      relayId: packet.senderIdHex,
      hops: payload.hops,
      receivedAt: now,
    );
    return true;
  }

  Future<void> _sendDeliveryAck(String messageId, String recipientId) async {
    final identity = _identityService.current;
    if (identity == null || identity.id == recipientId) {
      return;
    }
    final packet = await _codec.createSignedPacket(
      type: MeshPacketType.deliveryAck,
      channelId: _channel.idBytes,
      senderPublicKey: identity.publicKey,
      payload: DeliveryAckCodec.encode(
        DeliveryAckPayload(messageId: messageId, status: 1),
      ),
      signer: _identityService.sign,
    );
    await _enqueuePacket(
      packet,
      priority: MeshConstants.priorityAck,
      markSeen: true,
    );
  }

  Future<void> _sendRelayReceipt(MeshPacket original, int hops) async {
    final identity = _identityService.current;
    if (identity == null || original.senderIdHex == identity.id) {
      return;
    }
    final packet = await _codec.createSignedPacket(
      type: MeshPacketType.relayReceipt,
      channelId: _channel.idBytes,
      senderPublicKey: identity.publicKey,
      payload: RelayReceiptCodec.encode(
        RelayReceiptPayload(
          messageId: ByteUtils.canonicalUuid(original.messageId),
          hops: hops,
        ),
      ),
      signer: _identityService.sign,
    );
    await _enqueuePacket(
      packet,
      priority: MeshConstants.priorityReceipt,
      markSeen: true,
    );
  }

  Future<void> _enqueuePacket(
    MeshPacket packet, {
    required int priority,
    required bool markSeen,
  }) async {
    final now = _clock.now();
    if (markSeen) {
      await _meshRepository.markPacketSeen(
        packetId: packet.messageIdHex,
        now: now,
        expiresAt: now.add(MeshConstants.dedupRetention),
      );
    }
    await _meshRepository.enqueue(
      packetId: _idGenerator.nextString(),
      messageId: ByteUtils.canonicalUuid(packet.messageId),
      bytes: _codec.encode(packet),
      priority: priority,
      now: now,
      expiresAt: now.add(AppConstants.messageLifetime),
    );
  }

  static int _priorityFor(MeshPacketType type) {
    return switch (type) {
      MeshPacketType.alert => MeshConstants.priorityAlert,
      MeshPacketType.deliveryAck => MeshConstants.priorityAck,
      MeshPacketType.relayReceipt => MeshConstants.priorityReceipt,
      _ => MeshConstants.priorityChat,
    };
  }
}
