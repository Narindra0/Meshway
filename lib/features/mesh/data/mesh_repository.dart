import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:hafatra/core/database/app_database.dart';
import 'package:hafatra/core/errors/app_exception.dart';
import 'package:hafatra/features/mesh/domain/outbox_packet.dart';

/// Persistance du maillage : outbox, déduplication et accusés.
final class MeshRepository {
  MeshRepository(this._database);

  final AppDatabase _database;

  Future<bool> markPacketSeen({
    required String packetId,
    required DateTime now,
    required DateTime expiresAt,
  }) {
    return _database.markPacketSeen(
      packetId: packetId,
      now: now,
      expiresAt: expiresAt,
    );
  }

  Future<void> enqueue({
    required String packetId,
    required String messageId,
    required Uint8List bytes,
    required int priority,
    required DateTime now,
    required DateTime expiresAt,
  }) async {
    await _database.insertOutbox(
      PacketsOutboxCompanion.insert(
        packetId: packetId,
        messageId: messageId,
        bytes: bytes,
        priority: priority,
        createdAt: now,
        nextAttemptAt: now,
        expiresAt: expiresAt,
      ),
    );
  }

  Future<List<OutboxPacket>> due(DateTime now) async {
    final rows = await _database.dueOutbox(now);
    return rows
        .map(
          (row) => OutboxPacket(
            packetId: row.packetId,
            messageId: row.messageId,
            bytes: row.bytes,
            priority: row.priority,
            attempts: row.attempts,
            createdAt: row.createdAt,
            expiresAt: row.expiresAt,
          ),
        )
        .toList(growable: false);
  }

  Future<void> remove(String packetId) => _database.deleteOutbox(packetId);

  Future<void> retryLater(String packetId, DateTime nextAttemptAt) {
    return _database.markOutboxAttempt(packetId, nextAttemptAt: nextAttemptAt);
  }

  Future<void> recordRelayReceipt({
    required String messageId,
    required String relayId,
    required int hops,
    required DateTime receivedAt,
  }) async {
    await _database.recordRelayReceipt(
      messageId: messageId,
      relayId: relayId,
      hops: hops,
      receivedAt: receivedAt,
    );
  }

  Future<void> recordDeliveryAck({
    required String messageId,
    required String ackSenderId,
    required int status,
    required DateTime receivedAt,
  }) async {
    await _database.recordDeliveryAck(
      messageId: messageId,
      ackSenderId: ackSenderId,
      status: status,
      receivedAt: receivedAt,
    );
  }

  Future<void> markMessageSent(String messageId) {
    return _database.markMessageSent(messageId);
  }

  Future<int> countOutbox() => _database.countOutbox();

  Future<int> countSeenPackets() => _database.countSeenPackets();

  Future<void> purge(DateTime now) => _database.purgeExpired(now);

  Future<void> recordPeer({
    required String id,
    required String transport,
    required DateTime lastSeenAt,
  }) async {
    try {
      await _database.upsertPeer(
        id: id,
        transport: transport,
        lastSeenAt: lastSeenAt,
      );
    } on Object catch (error, stackTrace) {
      throw StorageException(
        'Impossible de mettre à jour les pairs.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
