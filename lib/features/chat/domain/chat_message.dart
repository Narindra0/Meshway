enum MessageDirection {
  incoming(0),
  outgoing(1);

  MessageDirection(this.value);

  final int value;

  static MessageDirection fromValue(int value) =>
      value == MessageDirection.outgoing.value
      ? MessageDirection.outgoing
      : MessageDirection.incoming;
}

enum ChatMessageStatus {
  queued(0, 'statusQueued'),
  sent(1, 'statusSent'),
  relayed(2, 'statusRelayed'),
  seen(3, 'statusSeen'),
  failed(4, 'statusFailed');

  ChatMessageStatus(this.value, this.labelKey);

  final int value;
  final String labelKey;

  static ChatMessageStatus fromValue(int value) {
    for (final status in values) {
      if (status.value == value) {
        return status;
      }
    }
    return ChatMessageStatus.queued;
  }
}

final class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
    required this.direction,
    required this.status,
    required this.priority,
    required this.relayCount,
    required this.seenCount,
    this.expiresAt,
    this.isAlert = false,
    this.alertAuthority,
  });

  final String id;
  final String channelId;
  final String senderId;
  final String senderName;
  final String body;
  final DateTime createdAt;
  final MessageDirection direction;
  final ChatMessageStatus status;
  final int priority;
  final int relayCount;
  final int seenCount;
  final DateTime? expiresAt;
  final bool isAlert;
  final String? alertAuthority;

  bool get isOutgoing => direction == MessageDirection.outgoing;

  ChatMessage copyWith({
    ChatMessageStatus? status,
    int? relayCount,
    int? seenCount,
    String? senderName,
  }) {
    return ChatMessage(
      id: id,
      channelId: channelId,
      senderId: senderId,
      senderName: senderName ?? this.senderName,
      body: body,
      createdAt: createdAt,
      direction: direction,
      status: status ?? this.status,
      priority: priority,
      relayCount: relayCount ?? this.relayCount,
      seenCount: seenCount ?? this.seenCount,
      expiresAt: expiresAt,
      isAlert: isAlert,
      alertAuthority: alertAuthority,
    );
  }
}
