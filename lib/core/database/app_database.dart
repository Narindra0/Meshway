import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

@DataClassName('IdentityRecord')
class Identities extends Table {
  TextColumn get id => text()();
  BlobColumn get publicKey => blob()();
  TextColumn get displayName => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('Channel')
class Channels extends Table {
  TextColumn get id => text()();
  TextColumn get code => text()();
  BlobColumn get codeHash => blob()();
  TextColumn get name => text()();
  DateTimeColumn get joinedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('Message')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get channelId => text()();
  TextColumn get senderId => text()();
  TextColumn get senderName => text()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get direction => integer()();
  IntColumn get status => integer()();
  IntColumn get priority => integer()();
  DateTimeColumn get expiresAt => dateTime().nullable()();
  BoolColumn get isAlert => boolean().withDefault(const Constant(false))();
  TextColumn get alertAuthority => text().nullable()();
  IntColumn get relayCount => integer().withDefault(const Constant(0))();
  IntColumn get seenCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('OutboxEntry')
class PacketsOutbox extends Table {
  TextColumn get packetId => text()();
  TextColumn get messageId => text()();
  BlobColumn get bytes => blob()();
  IntColumn get priority => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get nextAttemptAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {packetId};
}

@DataClassName('SeenPacket')
class SeenPackets extends Table {
  TextColumn get packetId => text()();
  DateTimeColumn get firstSeenAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {packetId};
}

@DataClassName('RelayReceipt')
class RelayReceipts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text()();
  TextColumn get relayId => text()();
  IntColumn get hops => integer()();
  DateTimeColumn get receivedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {messageId, relayId},
  ];
}

@DataClassName('DeliveryAck')
class DeliveryAcks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get messageId => text()();
  TextColumn get ackSenderId => text()();
  IntColumn get status => integer()();
  DateTimeColumn get receivedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {messageId, ackSenderId},
  ];
}

@DataClassName('TrustedAlert')
class TrustedAlerts extends Table {
  TextColumn get alertId => text()();
  TextColumn get authorityId => text()();
  TextColumn get payload => text()();
  IntColumn get severity => integer()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  DateTimeColumn get receivedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {alertId};
}

@DataClassName('SettingEntry')
class SettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('Peer')
class Peers extends Table {
  TextColumn get id => text()();
  TextColumn get transport => text()();
  TextColumn get displayName => text().nullable()();
  IntColumn get rssi => integer().nullable()();
  DateTimeColumn get lastSeenAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Identities,
    Channels,
    Messages,
    PacketsOutbox,
    SeenPackets,
    RelayReceipts,
    DeliveryAcks,
    TrustedAlerts,
    SettingsEntries,
    Peers,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'hafatra',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
    );
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_messages_channel_created '
        'ON messages(channel_id, created_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_outbox_due '
        'ON packets_outbox(next_attempt_at, expires_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_seen_expiry '
        'ON seen_packets(expires_at)',
      );
      await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_alerts_expiry '
        'ON trusted_alerts(expires_at)',
      );
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA journal_mode=WAL');
      await customStatement('PRAGMA foreign_keys=ON');
    },
  );

  // ---------------------------------------------------------------------------
  // Identité et canaux
  // ---------------------------------------------------------------------------

  Future<void> saveIdentity({
    required String id,
    required Uint8List publicKey,
    required String displayName,
    required DateTime createdAt,
  }) async {
    await into(identities).insertOnConflictUpdate(
      IdentitiesCompanion.insert(
        id: id,
        publicKey: publicKey,
        displayName: displayName,
        createdAt: createdAt,
      ),
    );
  }

  Future<IdentityRecord?> getIdentity() {
    return (select(identities)..limit(1)).getSingleOrNull();
  }

  Future<void> saveChannel({
    required String id,
    required String code,
    required Uint8List codeHash,
    required String name,
    required DateTime joinedAt,
  }) async {
    await into(channels).insertOnConflictUpdate(
      ChannelsCompanion.insert(
        id: id,
        code: code,
        codeHash: codeHash,
        name: name,
        joinedAt: joinedAt,
      ),
    );
  }

  Future<Channel?> getChannel() {
    return (select(channels)..limit(1)).getSingleOrNull();
  }

  // ---------------------------------------------------------------------------
  // Messages
  // ---------------------------------------------------------------------------

  Future<bool> insertMessage(MessagesCompanion message) async {
    final inserted = await into(messages)
        .insertReturningOrNull(message, mode: InsertMode.insertOrIgnore);
    return inserted != null;
  }

  Future<Message?> getMessage(String id) {
    return (select(messages)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Message>> watchMessages(String channelId, {int limit = 250}) {
    final query = select(messages)
      ..where((t) => t.channelId.equals(channelId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return query.watch();
  }

  Future<List<Message>> getMessages(String channelId, {int limit = 250}) {
    final query = select(messages)
      ..where((t) => t.channelId.equals(channelId))
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.id, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return query.get();
  }

  Future<void> updateMessageStatus(String id, int status) async {
    await (update(messages)..where((t) => t.id.equals(id))).write(
      MessagesCompanion(status: Value(status)),
    );
  }

  Future<void> markMessageSent(String id) async {
    await customUpdate(
      'UPDATE messages SET status = MAX(status, 1) WHERE id = ?',
      variables: [Variable<String>(id)],
      updates: {messages},
    );
  }

  Future<int> countMessages() async {
    final count = messages.id.count();
    final query = selectOnly(messages)..addColumns([count]);
    final row = await query.getSingle();
    final value = row.read(count) ?? 0;
    return value;
  }

  // ---------------------------------------------------------------------------
  // Outbox, déduplication, accusés
  // ---------------------------------------------------------------------------

  Future<void> insertOutbox(PacketsOutboxCompanion entry) async {
    await into(packetsOutbox).insert(entry, mode: InsertMode.insertOrIgnore);
  }

  Future<List<OutboxEntry>> dueOutbox(DateTime now, {int limit = 50}) {
    final query = select(packetsOutbox)
      ..where(
        (t) =>
            t.nextAttemptAt.isSmallerOrEqualValue(now) &
            t.expiresAt.isBiggerThanValue(now),
      )
      ..orderBy([
        (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.desc),
        (t) => OrderingTerm(expression: t.createdAt),
      ])
      ..limit(limit);
    return query.get();
  }

  Future<void> deleteOutbox(String packetId) async {
    await (delete(
      packetsOutbox,
    )..where((t) => t.packetId.equals(packetId))).go();
  }

  Future<void> markOutboxAttempt(
    String packetId, {
    required DateTime nextAttemptAt,
  }) async {
    final row = await (select(
      packetsOutbox,
    )..where((t) => t.packetId.equals(packetId))).getSingleOrNull();
    if (row == null) {
      return;
    }
    await (update(
      packetsOutbox,
    )..where((t) => t.packetId.equals(packetId))).write(
      PacketsOutboxCompanion(
        attempts: Value(row.attempts + 1),
        nextAttemptAt: Value(nextAttemptAt),
      ),
    );
  }

  Future<bool> markPacketSeen({
    required String packetId,
    required DateTime now,
    required DateTime expiresAt,
  }) async {
    return await transaction(() async {
      final existing = await (select(
        seenPackets,
      )..where((t) => t.packetId.equals(packetId))).getSingleOrNull();
      if (existing != null) {
        if (existing.expiresAt.isBefore(now)) {
          await (delete(
            seenPackets,
          )..where((t) => t.packetId.equals(packetId))).go();
        } else {
          return false;
        }
      }
      await into(seenPackets).insert(
        SeenPacketsCompanion.insert(
          packetId: packetId,
          firstSeenAt: now,
          expiresAt: expiresAt,
        ),
        mode: InsertMode.insertOrIgnore,
      );
      return true;
    });
  }

  Future<bool> recordRelayReceipt({
    required String messageId,
    required String relayId,
    required int hops,
    required DateTime receivedAt,
  }) async {
    final inserted = await into(relayReceipts).insertReturningOrNull(
      RelayReceiptsCompanion.insert(
        messageId: messageId,
        relayId: relayId,
        hops: hops,
        receivedAt: receivedAt,
      ),
      mode: InsertMode.insertOrIgnore,
    );
    if (inserted == null) {
      return false;
    }
    await customUpdate(
      'UPDATE messages SET relay_count = relay_count + 1, '
      'status = MAX(status, 2) WHERE id = ?',
      variables: [Variable<String>(messageId)],
      updates: {messages},
    );
    return true;
  }

  Future<int> countRelayReceipts(String messageId) async {
    final count = relayReceipts.id.count();
    final query = selectOnly(relayReceipts)
      ..addColumns([count])
      ..where(relayReceipts.messageId.equals(messageId));
    final row = await query.getSingle();
    final value = row.read(count) ?? 0;
    return value;
  }

  Future<bool> recordDeliveryAck({
    required String messageId,
    required String ackSenderId,
    required int status,
    required DateTime receivedAt,
  }) async {
    final inserted = await into(deliveryAcks).insertReturningOrNull(
      DeliveryAcksCompanion.insert(
        messageId: messageId,
        ackSenderId: ackSenderId,
        status: status,
        receivedAt: receivedAt,
      ),
      mode: InsertMode.insertOrIgnore,
    );
    if (inserted == null) {
      return false;
    }
    await customUpdate(
      'UPDATE messages SET seen_count = seen_count + 1, '
      'status = MAX(status, 3) WHERE id = ?',
      variables: [Variable<String>(messageId)],
      updates: {messages},
    );
    return true;
  }

  Future<int> countDeliveryAcks(String messageId) async {
    final count = deliveryAcks.id.count();
    final query = selectOnly(deliveryAcks)
      ..addColumns([count])
      ..where(deliveryAcks.messageId.equals(messageId));
    final row = await query.getSingle();
    final value = row.read(count) ?? 0;
    return value;
  }

  Future<int> countSeenPackets() async {
    final count = seenPackets.packetId.count();
    final query = selectOnly(seenPackets)..addColumns([count]);
    final row = await query.getSingle();
    final value = row.read(count) ?? 0;
    return value;
  }

  Future<int> countOutbox() async {
    final count = packetsOutbox.packetId.count();
    final query = selectOnly(packetsOutbox)..addColumns([count]);
    final row = await query.getSingle();
    final value = row.read(count) ?? 0;
    return value;
  }

  // ---------------------------------------------------------------------------
  // Alertes
  // ---------------------------------------------------------------------------

  Future<void> saveAlert(TrustedAlertsCompanion alert) async {
    await into(trustedAlerts).insertOnConflictUpdate(alert);
  }

  Future<TrustedAlert?> getAlert(String alertId) {
    return (select(
      trustedAlerts,
    )..where((t) => t.alertId.equals(alertId))).getSingleOrNull();
  }

  Future<List<TrustedAlert>> activeAlerts(DateTime now, {int limit = 50}) {
    final query = select(trustedAlerts)
      ..where((t) => t.expiresAt.isBiggerThanValue(now))
      ..orderBy([
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return query.get();
  }

  Future<List<TrustedAlert>> allAlerts({int limit = 50}) {
    final query = select(trustedAlerts)
      ..orderBy([
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return query.get();
  }

  Stream<List<TrustedAlert>> watchActiveAlerts(DateTime now, {int limit = 50}) {
    final query = select(trustedAlerts)
      ..where((t) => t.expiresAt.isBiggerThanValue(now))
      ..orderBy([
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return query.watch();
  }

  Stream<List<TrustedAlert>> watchAllAlerts({int limit = 50}) {
    final query = select(trustedAlerts)
      ..orderBy([
        (t) => OrderingTerm(expression: t.receivedAt, mode: OrderingMode.desc),
      ])
      ..limit(limit);
    return query.watch();
  }

  // ---------------------------------------------------------------------------
  // Réglages et pairs
  // ---------------------------------------------------------------------------

  Future<void> putSetting(String key, String value) async {
    await into(settingsEntries).insertOnConflictUpdate(
      SettingsEntriesCompanion.insert(key: key, value: value),
    );
  }

  Future<String?> getSetting(String key) async {
    final row = await (select(
      settingsEntries,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<Map<String, String>> getSettings() async {
    final rows = await select(settingsEntries).get();
    return {for (final row in rows) row.key: row.value};
  }

  Future<void> upsertPeer({
    required String id,
    required String transport,
    required DateTime lastSeenAt,
    String? displayName,
    int? rssi,
  }) async {
    await into(peers).insertOnConflictUpdate(
      PeersCompanion.insert(
        id: id,
        transport: transport,
        displayName: Value(displayName),
        rssi: Value(rssi),
        lastSeenAt: lastSeenAt,
      ),
    );
  }

  Future<List<Peer>> recentPeers(DateTime since) {
    return (select(peers)
          ..where((t) => t.lastSeenAt.isBiggerThanValue(since))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.lastSeenAt, mode: OrderingMode.desc),
          ]))
        .get();
  }

  // ---------------------------------------------------------------------------
  // Purge
  // ---------------------------------------------------------------------------

  Future<void> purgeExpired(
    DateTime now, {
    Duration retainMessages = const Duration(days: 30),
  }) async {
    final messageCutoff = now.subtract(retainMessages);
    await transaction(() async {
      await (delete(
        seenPackets,
      )..where((t) => t.expiresAt.isSmallerThanValue(now))).go();
      await (delete(
        packetsOutbox,
      )..where((t) => t.expiresAt.isSmallerThanValue(now))).go();
      await (delete(
        messages,
      )..where((t) => t.createdAt.isSmallerThanValue(messageCutoff))).go();
      await customStatement(
        'DELETE FROM relay_receipts WHERE message_id NOT IN '
        '(SELECT id FROM messages)',
      );
      await customStatement(
        'DELETE FROM delivery_acks WHERE message_id NOT IN '
        '(SELECT id FROM messages)',
      );
    });
  }
}
