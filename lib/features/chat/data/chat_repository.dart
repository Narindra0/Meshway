import 'package:drift/drift.dart';
import 'package:hafatra/core/constants/app_constants.dart';
import 'package:hafatra/core/constants/mesh_constants.dart';
import 'package:hafatra/core/database/app_database.dart';
import 'package:hafatra/core/errors/app_exception.dart';
import 'package:hafatra/core/utils/clock.dart';
import 'package:hafatra/features/chat/domain/chat_message.dart';

/// Accès typé aux messages persistés.
final class ChatRepository {
  ChatRepository({required AppDatabase database, required Clock clock})
    : _database = database,
      _clock = clock;

  final AppDatabase _database;
  final Clock _clock;

  Stream<List<ChatMessage>> watchMessages(String channelId) {
    return _database.watchMessages(channelId).map((rows) {
      final messages = rows.map(_mapRow).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return List<ChatMessage>.unmodifiable(messages);
    });
  }

  Future<List<ChatMessage>> getMessages(String channelId) async {
    final rows = await _database.getMessages(channelId);
    final messages = rows.map(_mapRow).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return messages;
  }

  Future<ChatMessage?> findById(String id) async {
    final row = await _database.getMessage(id);
    return row == null ? null : _mapRow(row);
  }

  Future<void> insertOutgoing(ChatMessage message) async {
    try {
      await _database.insertMessage(
        MessagesCompanion.insert(
          id: message.id,
          channelId: message.channelId,
          senderId: message.senderId,
          senderName: message.senderName,
          body: message.body,
          createdAt: message.createdAt,
          direction: message.direction.value,
          status: message.status.value,
          priority: message.priority,
          expiresAt: Value(message.expiresAt),
          isAlert: Value(message.isAlert),
          alertAuthority: Value(message.alertAuthority),
          relayCount: Value(message.relayCount),
          seenCount: Value(message.seenCount),
        ),
      );
    } on Object catch (error, stackTrace) {
      throw StorageException(
        'Impossible d’enregistrer le message.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<bool> insertIncoming(ChatMessage message) async {
    try {
      return await _database.insertMessage(
        MessagesCompanion.insert(
          id: message.id,
          channelId: message.channelId,
          senderId: message.senderId,
          senderName: message.senderName,
          body: message.body,
          createdAt: message.createdAt,
          direction: message.direction.value,
          status: message.status.value,
          priority: message.priority,
          expiresAt: Value(message.expiresAt),
          isAlert: Value(message.isAlert),
          alertAuthority: Value(message.alertAuthority),
          relayCount: Value(message.relayCount),
          seenCount: Value(message.seenCount),
        ),
      );
    } on Object catch (error, stackTrace) {
      throw StorageException(
        'Impossible d’enregistrer le message reçu.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> markSent(String messageId) async {
    await _database.markMessageSent(messageId);
  }

  Future<void> markFailed(String messageId) async {
    await _database.updateMessageStatus(
      messageId,
      ChatMessageStatus.failed.value,
    );
  }

  ChatMessage _mapRow(Message row) {
    return ChatMessage(
      id: row.id,
      channelId: row.channelId,
      senderId: row.senderId,
      senderName: row.senderName,
      body: row.body,
      createdAt: row.createdAt.toUtc(),
      direction: MessageDirection.fromValue(row.direction),
      status: ChatMessageStatus.fromValue(row.status),
      priority: row.priority,
      expiresAt: row.expiresAt?.toUtc(),
      isAlert: row.isAlert,
      alertAuthority: row.alertAuthority,
      relayCount: row.relayCount,
      seenCount: row.seenCount,
    );
  }

  ChatMessage queuedOutgoing({
    required String id,
    required String channelId,
    required String senderId,
    required String senderName,
    required String body,
  }) {
    return ChatMessage(
      id: id,
      channelId: channelId,
      senderId: senderId,
      senderName: senderName,
      body: body,
      createdAt: _clock.now().toUtc(),
      direction: MessageDirection.outgoing,
      status: ChatMessageStatus.queued,
      priority: MeshConstants.priorityChat,
      relayCount: 0,
      seenCount: 0,
      expiresAt: _clock.now().add(AppConstants.messageLifetime),
    );
  }
}
