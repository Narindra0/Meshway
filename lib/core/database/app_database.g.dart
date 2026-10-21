// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $IdentitiesTable extends Identities
    with TableInfo<$IdentitiesTable, IdentityRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdentitiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<Uint8List> publicKey = GeneratedColumn<Uint8List>(
    'public_key',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, publicKey, displayName, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'identities';
  @override
  VerificationContext validateIntegrity(
    Insertable<IdentityRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_publicKeyMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IdentityRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IdentityRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}public_key'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IdentitiesTable createAlias(String alias) {
    return $IdentitiesTable(attachedDatabase, alias);
  }
}

class IdentityRecord extends DataClass implements Insertable<IdentityRecord> {
  final String id;
  final Uint8List publicKey;
  final String displayName;
  final DateTime createdAt;
  const IdentityRecord({
    required this.id,
    required this.publicKey,
    required this.displayName,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['public_key'] = Variable<Uint8List>(publicKey);
    map['display_name'] = Variable<String>(displayName);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  IdentitiesCompanion toCompanion(bool nullToAbsent) {
    return IdentitiesCompanion(
      id: Value(id),
      publicKey: Value(publicKey),
      displayName: Value(displayName),
      createdAt: Value(createdAt),
    );
  }

  factory IdentityRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IdentityRecord(
      id: serializer.fromJson<String>(json['id']),
      publicKey: serializer.fromJson<Uint8List>(json['publicKey']),
      displayName: serializer.fromJson<String>(json['displayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'publicKey': serializer.toJson<Uint8List>(publicKey),
      'displayName': serializer.toJson<String>(displayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  IdentityRecord copyWith({
    String? id,
    Uint8List? publicKey,
    String? displayName,
    DateTime? createdAt,
  }) => IdentityRecord(
    id: id ?? this.id,
    publicKey: publicKey ?? this.publicKey,
    displayName: displayName ?? this.displayName,
    createdAt: createdAt ?? this.createdAt,
  );
  IdentityRecord copyWithCompanion(IdentitiesCompanion data) {
    return IdentityRecord(
      id: data.id.present ? data.id.value : this.id,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IdentityRecord(')
          ..write('id: $id, ')
          ..write('publicKey: $publicKey, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    $driftBlobEquality.hash(publicKey),
    displayName,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IdentityRecord &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.publicKey, this.publicKey) &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt);
}

class IdentitiesCompanion extends UpdateCompanion<IdentityRecord> {
  final Value<String> id;
  final Value<Uint8List> publicKey;
  final Value<String> displayName;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const IdentitiesCompanion({
    this.id = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdentitiesCompanion.insert({
    required String id,
    required Uint8List publicKey,
    required String displayName,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       publicKey = Value(publicKey),
       displayName = Value(displayName),
       createdAt = Value(createdAt);
  static Insertable<IdentityRecord> custom({
    Expression<String>? id,
    Expression<Uint8List>? publicKey,
    Expression<String>? displayName,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (publicKey != null) 'public_key': publicKey,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdentitiesCompanion copyWith({
    Value<String>? id,
    Value<Uint8List>? publicKey,
    Value<String>? displayName,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return IdentitiesCompanion(
      id: id ?? this.id,
      publicKey: publicKey ?? this.publicKey,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<Uint8List>(publicKey.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdentitiesCompanion(')
          ..write('id: $id, ')
          ..write('publicKey: $publicKey, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChannelsTable extends Channels with TableInfo<$ChannelsTable, Channel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeHashMeta = const VerificationMeta(
    'codeHash',
  );
  @override
  late final GeneratedColumn<Uint8List> codeHash = GeneratedColumn<Uint8List>(
    'code_hash',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, code, codeHash, name, joinedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channels';
  @override
  VerificationContext validateIntegrity(
    Insertable<Channel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('code_hash')) {
      context.handle(
        _codeHashMeta,
        codeHash.isAcceptableOrUnknown(data['code_hash']!, _codeHashMeta),
      );
    } else if (isInserting) {
      context.missing(_codeHashMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_joinedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Channel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Channel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      codeHash: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}code_hash'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      )!,
    );
  }

  @override
  $ChannelsTable createAlias(String alias) {
    return $ChannelsTable(attachedDatabase, alias);
  }
}

class Channel extends DataClass implements Insertable<Channel> {
  final String id;
  final String code;
  final Uint8List codeHash;
  final String name;
  final DateTime joinedAt;
  const Channel({
    required this.id,
    required this.code,
    required this.codeHash,
    required this.name,
    required this.joinedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['code_hash'] = Variable<Uint8List>(codeHash);
    map['name'] = Variable<String>(name);
    map['joined_at'] = Variable<DateTime>(joinedAt);
    return map;
  }

  ChannelsCompanion toCompanion(bool nullToAbsent) {
    return ChannelsCompanion(
      id: Value(id),
      code: Value(code),
      codeHash: Value(codeHash),
      name: Value(name),
      joinedAt: Value(joinedAt),
    );
  }

  factory Channel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Channel(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      codeHash: serializer.fromJson<Uint8List>(json['codeHash']),
      name: serializer.fromJson<String>(json['name']),
      joinedAt: serializer.fromJson<DateTime>(json['joinedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'codeHash': serializer.toJson<Uint8List>(codeHash),
      'name': serializer.toJson<String>(name),
      'joinedAt': serializer.toJson<DateTime>(joinedAt),
    };
  }

  Channel copyWith({
    String? id,
    String? code,
    Uint8List? codeHash,
    String? name,
    DateTime? joinedAt,
  }) => Channel(
    id: id ?? this.id,
    code: code ?? this.code,
    codeHash: codeHash ?? this.codeHash,
    name: name ?? this.name,
    joinedAt: joinedAt ?? this.joinedAt,
  );
  Channel copyWithCompanion(ChannelsCompanion data) {
    return Channel(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      codeHash: data.codeHash.present ? data.codeHash.value : this.codeHash,
      name: data.name.present ? data.name.value : this.name,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Channel(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('codeHash: $codeHash, ')
          ..write('name: $name, ')
          ..write('joinedAt: $joinedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, $driftBlobEquality.hash(codeHash), name, joinedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Channel &&
          other.id == this.id &&
          other.code == this.code &&
          $driftBlobEquality.equals(other.codeHash, this.codeHash) &&
          other.name == this.name &&
          other.joinedAt == this.joinedAt);
}

class ChannelsCompanion extends UpdateCompanion<Channel> {
  final Value<String> id;
  final Value<String> code;
  final Value<Uint8List> codeHash;
  final Value<String> name;
  final Value<DateTime> joinedAt;
  final Value<int> rowid;
  const ChannelsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.codeHash = const Value.absent(),
    this.name = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChannelsCompanion.insert({
    required String id,
    required String code,
    required Uint8List codeHash,
    required String name,
    required DateTime joinedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       codeHash = Value(codeHash),
       name = Value(name),
       joinedAt = Value(joinedAt);
  static Insertable<Channel> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<Uint8List>? codeHash,
    Expression<String>? name,
    Expression<DateTime>? joinedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (codeHash != null) 'code_hash': codeHash,
      if (name != null) 'name': name,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChannelsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<Uint8List>? codeHash,
    Value<String>? name,
    Value<DateTime>? joinedAt,
    Value<int>? rowid,
  }) {
    return ChannelsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      codeHash: codeHash ?? this.codeHash,
      name: name ?? this.name,
      joinedAt: joinedAt ?? this.joinedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (codeHash.present) {
      map['code_hash'] = Variable<Uint8List>(codeHash.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('codeHash: $codeHash, ')
          ..write('name: $name, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelIdMeta = const VerificationMeta(
    'channelId',
  );
  @override
  late final GeneratedColumn<String> channelId = GeneratedColumn<String>(
    'channel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderIdMeta = const VerificationMeta(
    'senderId',
  );
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
    'sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _senderNameMeta = const VerificationMeta(
    'senderName',
  );
  @override
  late final GeneratedColumn<String> senderName = GeneratedColumn<String>(
    'sender_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionMeta = const VerificationMeta(
    'direction',
  );
  @override
  late final GeneratedColumn<int> direction = GeneratedColumn<int>(
    'direction',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAlertMeta = const VerificationMeta(
    'isAlert',
  );
  @override
  late final GeneratedColumn<bool> isAlert = GeneratedColumn<bool>(
    'is_alert',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_alert" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _alertAuthorityMeta = const VerificationMeta(
    'alertAuthority',
  );
  @override
  late final GeneratedColumn<String> alertAuthority = GeneratedColumn<String>(
    'alert_authority',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relayCountMeta = const VerificationMeta(
    'relayCount',
  );
  @override
  late final GeneratedColumn<int> relayCount = GeneratedColumn<int>(
    'relay_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _seenCountMeta = const VerificationMeta(
    'seenCount',
  );
  @override
  late final GeneratedColumn<int> seenCount = GeneratedColumn<int>(
    'seen_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    channelId,
    senderId,
    senderName,
    body,
    createdAt,
    direction,
    status,
    priority,
    expiresAt,
    isAlert,
    alertAuthority,
    relayCount,
    seenCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('channel_id')) {
      context.handle(
        _channelIdMeta,
        channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_channelIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(
        _senderIdMeta,
        senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('sender_name')) {
      context.handle(
        _senderNameMeta,
        senderName.isAcceptableOrUnknown(data['sender_name']!, _senderNameMeta),
      );
    } else if (isInserting) {
      context.missing(_senderNameMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(
        _directionMeta,
        direction.isAcceptableOrUnknown(data['direction']!, _directionMeta),
      );
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    if (data.containsKey('is_alert')) {
      context.handle(
        _isAlertMeta,
        isAlert.isAcceptableOrUnknown(data['is_alert']!, _isAlertMeta),
      );
    }
    if (data.containsKey('alert_authority')) {
      context.handle(
        _alertAuthorityMeta,
        alertAuthority.isAcceptableOrUnknown(
          data['alert_authority']!,
          _alertAuthorityMeta,
        ),
      );
    }
    if (data.containsKey('relay_count')) {
      context.handle(
        _relayCountMeta,
        relayCount.isAcceptableOrUnknown(data['relay_count']!, _relayCountMeta),
      );
    }
    if (data.containsKey('seen_count')) {
      context.handle(
        _seenCountMeta,
        seenCount.isAcceptableOrUnknown(data['seen_count']!, _seenCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      channelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_id'],
      )!,
      senderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_id'],
      )!,
      senderName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sender_name'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      direction: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}direction'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
      isAlert: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_alert'],
      )!,
      alertAuthority: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_authority'],
      ),
      relayCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}relay_count'],
      )!,
      seenCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seen_count'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String channelId;
  final String senderId;
  final String senderName;
  final String body;
  final DateTime createdAt;
  final int direction;
  final int status;
  final int priority;
  final DateTime? expiresAt;
  final bool isAlert;
  final String? alertAuthority;
  final int relayCount;
  final int seenCount;
  const Message({
    required this.id,
    required this.channelId,
    required this.senderId,
    required this.senderName,
    required this.body,
    required this.createdAt,
    required this.direction,
    required this.status,
    required this.priority,
    this.expiresAt,
    required this.isAlert,
    this.alertAuthority,
    required this.relayCount,
    required this.seenCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['channel_id'] = Variable<String>(channelId);
    map['sender_id'] = Variable<String>(senderId);
    map['sender_name'] = Variable<String>(senderName);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['direction'] = Variable<int>(direction);
    map['status'] = Variable<int>(status);
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    map['is_alert'] = Variable<bool>(isAlert);
    if (!nullToAbsent || alertAuthority != null) {
      map['alert_authority'] = Variable<String>(alertAuthority);
    }
    map['relay_count'] = Variable<int>(relayCount);
    map['seen_count'] = Variable<int>(seenCount);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      channelId: Value(channelId),
      senderId: Value(senderId),
      senderName: Value(senderName),
      body: Value(body),
      createdAt: Value(createdAt),
      direction: Value(direction),
      status: Value(status),
      priority: Value(priority),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      isAlert: Value(isAlert),
      alertAuthority: alertAuthority == null && nullToAbsent
          ? const Value.absent()
          : Value(alertAuthority),
      relayCount: Value(relayCount),
      seenCount: Value(seenCount),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      channelId: serializer.fromJson<String>(json['channelId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      senderName: serializer.fromJson<String>(json['senderName']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      direction: serializer.fromJson<int>(json['direction']),
      status: serializer.fromJson<int>(json['status']),
      priority: serializer.fromJson<int>(json['priority']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
      isAlert: serializer.fromJson<bool>(json['isAlert']),
      alertAuthority: serializer.fromJson<String?>(json['alertAuthority']),
      relayCount: serializer.fromJson<int>(json['relayCount']),
      seenCount: serializer.fromJson<int>(json['seenCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'channelId': serializer.toJson<String>(channelId),
      'senderId': serializer.toJson<String>(senderId),
      'senderName': serializer.toJson<String>(senderName),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'direction': serializer.toJson<int>(direction),
      'status': serializer.toJson<int>(status),
      'priority': serializer.toJson<int>(priority),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
      'isAlert': serializer.toJson<bool>(isAlert),
      'alertAuthority': serializer.toJson<String?>(alertAuthority),
      'relayCount': serializer.toJson<int>(relayCount),
      'seenCount': serializer.toJson<int>(seenCount),
    };
  }

  Message copyWith({
    String? id,
    String? channelId,
    String? senderId,
    String? senderName,
    String? body,
    DateTime? createdAt,
    int? direction,
    int? status,
    int? priority,
    Value<DateTime?> expiresAt = const Value.absent(),
    bool? isAlert,
    Value<String?> alertAuthority = const Value.absent(),
    int? relayCount,
    int? seenCount,
  }) => Message(
    id: id ?? this.id,
    channelId: channelId ?? this.channelId,
    senderId: senderId ?? this.senderId,
    senderName: senderName ?? this.senderName,
    body: body ?? this.body,
    createdAt: createdAt ?? this.createdAt,
    direction: direction ?? this.direction,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
    isAlert: isAlert ?? this.isAlert,
    alertAuthority: alertAuthority.present
        ? alertAuthority.value
        : this.alertAuthority,
    relayCount: relayCount ?? this.relayCount,
    seenCount: seenCount ?? this.seenCount,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      senderName: data.senderName.present
          ? data.senderName.value
          : this.senderName,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      direction: data.direction.present ? data.direction.value : this.direction,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      isAlert: data.isAlert.present ? data.isAlert.value : this.isAlert,
      alertAuthority: data.alertAuthority.present
          ? data.alertAuthority.value
          : this.alertAuthority,
      relayCount: data.relayCount.present
          ? data.relayCount.value
          : this.relayCount,
      seenCount: data.seenCount.present ? data.seenCount.value : this.seenCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isAlert: $isAlert, ')
          ..write('alertAuthority: $alertAuthority, ')
          ..write('relayCount: $relayCount, ')
          ..write('seenCount: $seenCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    channelId,
    senderId,
    senderName,
    body,
    createdAt,
    direction,
    status,
    priority,
    expiresAt,
    isAlert,
    alertAuthority,
    relayCount,
    seenCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.channelId == this.channelId &&
          other.senderId == this.senderId &&
          other.senderName == this.senderName &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.direction == this.direction &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.expiresAt == this.expiresAt &&
          other.isAlert == this.isAlert &&
          other.alertAuthority == this.alertAuthority &&
          other.relayCount == this.relayCount &&
          other.seenCount == this.seenCount);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> channelId;
  final Value<String> senderId;
  final Value<String> senderName;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<int> direction;
  final Value<int> status;
  final Value<int> priority;
  final Value<DateTime?> expiresAt;
  final Value<bool> isAlert;
  final Value<String?> alertAuthority;
  final Value<int> relayCount;
  final Value<int> seenCount;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.channelId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.senderName = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.direction = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.isAlert = const Value.absent(),
    this.alertAuthority = const Value.absent(),
    this.relayCount = const Value.absent(),
    this.seenCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String channelId,
    required String senderId,
    required String senderName,
    required String body,
    required DateTime createdAt,
    required int direction,
    required int status,
    required int priority,
    this.expiresAt = const Value.absent(),
    this.isAlert = const Value.absent(),
    this.alertAuthority = const Value.absent(),
    this.relayCount = const Value.absent(),
    this.seenCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       channelId = Value(channelId),
       senderId = Value(senderId),
       senderName = Value(senderName),
       body = Value(body),
       createdAt = Value(createdAt),
       direction = Value(direction),
       status = Value(status),
       priority = Value(priority);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? channelId,
    Expression<String>? senderId,
    Expression<String>? senderName,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<int>? direction,
    Expression<int>? status,
    Expression<int>? priority,
    Expression<DateTime>? expiresAt,
    Expression<bool>? isAlert,
    Expression<String>? alertAuthority,
    Expression<int>? relayCount,
    Expression<int>? seenCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (channelId != null) 'channel_id': channelId,
      if (senderId != null) 'sender_id': senderId,
      if (senderName != null) 'sender_name': senderName,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (direction != null) 'direction': direction,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (isAlert != null) 'is_alert': isAlert,
      if (alertAuthority != null) 'alert_authority': alertAuthority,
      if (relayCount != null) 'relay_count': relayCount,
      if (seenCount != null) 'seen_count': seenCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? channelId,
    Value<String>? senderId,
    Value<String>? senderName,
    Value<String>? body,
    Value<DateTime>? createdAt,
    Value<int>? direction,
    Value<int>? status,
    Value<int>? priority,
    Value<DateTime?>? expiresAt,
    Value<bool>? isAlert,
    Value<String?>? alertAuthority,
    Value<int>? relayCount,
    Value<int>? seenCount,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      expiresAt: expiresAt ?? this.expiresAt,
      isAlert: isAlert ?? this.isAlert,
      alertAuthority: alertAuthority ?? this.alertAuthority,
      relayCount: relayCount ?? this.relayCount,
      seenCount: seenCount ?? this.seenCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<String>(channelId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (senderName.present) {
      map['sender_name'] = Variable<String>(senderName.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (direction.present) {
      map['direction'] = Variable<int>(direction.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (isAlert.present) {
      map['is_alert'] = Variable<bool>(isAlert.value);
    }
    if (alertAuthority.present) {
      map['alert_authority'] = Variable<String>(alertAuthority.value);
    }
    if (relayCount.present) {
      map['relay_count'] = Variable<int>(relayCount.value);
    }
    if (seenCount.present) {
      map['seen_count'] = Variable<int>(seenCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('channelId: $channelId, ')
          ..write('senderId: $senderId, ')
          ..write('senderName: $senderName, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('direction: $direction, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('isAlert: $isAlert, ')
          ..write('alertAuthority: $alertAuthority, ')
          ..write('relayCount: $relayCount, ')
          ..write('seenCount: $seenCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PacketsOutboxTable extends PacketsOutbox
    with TableInfo<$PacketsOutboxTable, OutboxEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PacketsOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packetIdMeta = const VerificationMeta(
    'packetId',
  );
  @override
  late final GeneratedColumn<String> packetId = GeneratedColumn<String>(
    'packet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    packetId,
    messageId,
    bytes,
    priority,
    createdAt,
    nextAttemptAt,
    attempts,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'packets_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('packet_id')) {
      context.handle(
        _packetIdMeta,
        packetId.isAcceptableOrUnknown(data['packet_id']!, _packetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packetIdMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    } else if (isInserting) {
      context.missing(_priorityMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextAttemptAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packetId};
  @override
  OutboxEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEntry(
      packetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}packet_id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $PacketsOutboxTable createAlias(String alias) {
    return $PacketsOutboxTable(attachedDatabase, alias);
  }
}

class OutboxEntry extends DataClass implements Insertable<OutboxEntry> {
  final String packetId;
  final String messageId;
  final Uint8List bytes;
  final int priority;
  final DateTime createdAt;
  final DateTime nextAttemptAt;
  final int attempts;
  final DateTime expiresAt;
  const OutboxEntry({
    required this.packetId,
    required this.messageId,
    required this.bytes,
    required this.priority,
    required this.createdAt,
    required this.nextAttemptAt,
    required this.attempts,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['packet_id'] = Variable<String>(packetId);
    map['message_id'] = Variable<String>(messageId);
    map['bytes'] = Variable<Uint8List>(bytes);
    map['priority'] = Variable<int>(priority);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    map['attempts'] = Variable<int>(attempts);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  PacketsOutboxCompanion toCompanion(bool nullToAbsent) {
    return PacketsOutboxCompanion(
      packetId: Value(packetId),
      messageId: Value(messageId),
      bytes: Value(bytes),
      priority: Value(priority),
      createdAt: Value(createdAt),
      nextAttemptAt: Value(nextAttemptAt),
      attempts: Value(attempts),
      expiresAt: Value(expiresAt),
    );
  }

  factory OutboxEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEntry(
      packetId: serializer.fromJson<String>(json['packetId']),
      messageId: serializer.fromJson<String>(json['messageId']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
      priority: serializer.fromJson<int>(json['priority']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      nextAttemptAt: serializer.fromJson<DateTime>(json['nextAttemptAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packetId': serializer.toJson<String>(packetId),
      'messageId': serializer.toJson<String>(messageId),
      'bytes': serializer.toJson<Uint8List>(bytes),
      'priority': serializer.toJson<int>(priority),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'nextAttemptAt': serializer.toJson<DateTime>(nextAttemptAt),
      'attempts': serializer.toJson<int>(attempts),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  OutboxEntry copyWith({
    String? packetId,
    String? messageId,
    Uint8List? bytes,
    int? priority,
    DateTime? createdAt,
    DateTime? nextAttemptAt,
    int? attempts,
    DateTime? expiresAt,
  }) => OutboxEntry(
    packetId: packetId ?? this.packetId,
    messageId: messageId ?? this.messageId,
    bytes: bytes ?? this.bytes,
    priority: priority ?? this.priority,
    createdAt: createdAt ?? this.createdAt,
    nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    attempts: attempts ?? this.attempts,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  OutboxEntry copyWithCompanion(PacketsOutboxCompanion data) {
    return OutboxEntry(
      packetId: data.packetId.present ? data.packetId.value : this.packetId,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      priority: data.priority.present ? data.priority.value : this.priority,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEntry(')
          ..write('packetId: $packetId, ')
          ..write('messageId: $messageId, ')
          ..write('bytes: $bytes, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('attempts: $attempts, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    packetId,
    messageId,
    $driftBlobEquality.hash(bytes),
    priority,
    createdAt,
    nextAttemptAt,
    attempts,
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEntry &&
          other.packetId == this.packetId &&
          other.messageId == this.messageId &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.priority == this.priority &&
          other.createdAt == this.createdAt &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.attempts == this.attempts &&
          other.expiresAt == this.expiresAt);
}

class PacketsOutboxCompanion extends UpdateCompanion<OutboxEntry> {
  final Value<String> packetId;
  final Value<String> messageId;
  final Value<Uint8List> bytes;
  final Value<int> priority;
  final Value<DateTime> createdAt;
  final Value<DateTime> nextAttemptAt;
  final Value<int> attempts;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const PacketsOutboxCompanion({
    this.packetId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.bytes = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PacketsOutboxCompanion.insert({
    required String packetId,
    required String messageId,
    required Uint8List bytes,
    required int priority,
    required DateTime createdAt,
    required DateTime nextAttemptAt,
    this.attempts = const Value.absent(),
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  }) : packetId = Value(packetId),
       messageId = Value(messageId),
       bytes = Value(bytes),
       priority = Value(priority),
       createdAt = Value(createdAt),
       nextAttemptAt = Value(nextAttemptAt),
       expiresAt = Value(expiresAt);
  static Insertable<OutboxEntry> custom({
    Expression<String>? packetId,
    Expression<String>? messageId,
    Expression<Uint8List>? bytes,
    Expression<int>? priority,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? nextAttemptAt,
    Expression<int>? attempts,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packetId != null) 'packet_id': packetId,
      if (messageId != null) 'message_id': messageId,
      if (bytes != null) 'bytes': bytes,
      if (priority != null) 'priority': priority,
      if (createdAt != null) 'created_at': createdAt,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (attempts != null) 'attempts': attempts,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PacketsOutboxCompanion copyWith({
    Value<String>? packetId,
    Value<String>? messageId,
    Value<Uint8List>? bytes,
    Value<int>? priority,
    Value<DateTime>? createdAt,
    Value<DateTime>? nextAttemptAt,
    Value<int>? attempts,
    Value<DateTime>? expiresAt,
    Value<int>? rowid,
  }) {
    return PacketsOutboxCompanion(
      packetId: packetId ?? this.packetId,
      messageId: messageId ?? this.messageId,
      bytes: bytes ?? this.bytes,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      attempts: attempts ?? this.attempts,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packetId.present) {
      map['packet_id'] = Variable<String>(packetId.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PacketsOutboxCompanion(')
          ..write('packetId: $packetId, ')
          ..write('messageId: $messageId, ')
          ..write('bytes: $bytes, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('attempts: $attempts, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SeenPacketsTable extends SeenPackets
    with TableInfo<$SeenPacketsTable, SeenPacket> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeenPacketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packetIdMeta = const VerificationMeta(
    'packetId',
  );
  @override
  late final GeneratedColumn<String> packetId = GeneratedColumn<String>(
    'packet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstSeenAtMeta = const VerificationMeta(
    'firstSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> firstSeenAt = GeneratedColumn<DateTime>(
    'first_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [packetId, firstSeenAt, expiresAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'seen_packets';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeenPacket> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('packet_id')) {
      context.handle(
        _packetIdMeta,
        packetId.isAcceptableOrUnknown(data['packet_id']!, _packetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packetIdMeta);
    }
    if (data.containsKey('first_seen_at')) {
      context.handle(
        _firstSeenAtMeta,
        firstSeenAt.isAcceptableOrUnknown(
          data['first_seen_at']!,
          _firstSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSeenAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packetId};
  @override
  SeenPacket map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeenPacket(
      packetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}packet_id'],
      )!,
      firstSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}first_seen_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $SeenPacketsTable createAlias(String alias) {
    return $SeenPacketsTable(attachedDatabase, alias);
  }
}

class SeenPacket extends DataClass implements Insertable<SeenPacket> {
  final String packetId;
  final DateTime firstSeenAt;
  final DateTime expiresAt;
  const SeenPacket({
    required this.packetId,
    required this.firstSeenAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['packet_id'] = Variable<String>(packetId);
    map['first_seen_at'] = Variable<DateTime>(firstSeenAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  SeenPacketsCompanion toCompanion(bool nullToAbsent) {
    return SeenPacketsCompanion(
      packetId: Value(packetId),
      firstSeenAt: Value(firstSeenAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory SeenPacket.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeenPacket(
      packetId: serializer.fromJson<String>(json['packetId']),
      firstSeenAt: serializer.fromJson<DateTime>(json['firstSeenAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packetId': serializer.toJson<String>(packetId),
      'firstSeenAt': serializer.toJson<DateTime>(firstSeenAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  SeenPacket copyWith({
    String? packetId,
    DateTime? firstSeenAt,
    DateTime? expiresAt,
  }) => SeenPacket(
    packetId: packetId ?? this.packetId,
    firstSeenAt: firstSeenAt ?? this.firstSeenAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  SeenPacket copyWithCompanion(SeenPacketsCompanion data) {
    return SeenPacket(
      packetId: data.packetId.present ? data.packetId.value : this.packetId,
      firstSeenAt: data.firstSeenAt.present
          ? data.firstSeenAt.value
          : this.firstSeenAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeenPacket(')
          ..write('packetId: $packetId, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(packetId, firstSeenAt, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeenPacket &&
          other.packetId == this.packetId &&
          other.firstSeenAt == this.firstSeenAt &&
          other.expiresAt == this.expiresAt);
}

class SeenPacketsCompanion extends UpdateCompanion<SeenPacket> {
  final Value<String> packetId;
  final Value<DateTime> firstSeenAt;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const SeenPacketsCompanion({
    this.packetId = const Value.absent(),
    this.firstSeenAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeenPacketsCompanion.insert({
    required String packetId,
    required DateTime firstSeenAt,
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  }) : packetId = Value(packetId),
       firstSeenAt = Value(firstSeenAt),
       expiresAt = Value(expiresAt);
  static Insertable<SeenPacket> custom({
    Expression<String>? packetId,
    Expression<DateTime>? firstSeenAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packetId != null) 'packet_id': packetId,
      if (firstSeenAt != null) 'first_seen_at': firstSeenAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeenPacketsCompanion copyWith({
    Value<String>? packetId,
    Value<DateTime>? firstSeenAt,
    Value<DateTime>? expiresAt,
    Value<int>? rowid,
  }) {
    return SeenPacketsCompanion(
      packetId: packetId ?? this.packetId,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packetId.present) {
      map['packet_id'] = Variable<String>(packetId.value);
    }
    if (firstSeenAt.present) {
      map['first_seen_at'] = Variable<DateTime>(firstSeenAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeenPacketsCompanion(')
          ..write('packetId: $packetId, ')
          ..write('firstSeenAt: $firstSeenAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RelayReceiptsTable extends RelayReceipts
    with TableInfo<$RelayReceiptsTable, RelayReceipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RelayReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relayIdMeta = const VerificationMeta(
    'relayId',
  );
  @override
  late final GeneratedColumn<String> relayId = GeneratedColumn<String>(
    'relay_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hopsMeta = const VerificationMeta('hops');
  @override
  late final GeneratedColumn<int> hops = GeneratedColumn<int>(
    'hops',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    relayId,
    hops,
    receivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'relay_receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<RelayReceipt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('relay_id')) {
      context.handle(
        _relayIdMeta,
        relayId.isAcceptableOrUnknown(data['relay_id']!, _relayIdMeta),
      );
    } else if (isInserting) {
      context.missing(_relayIdMeta);
    }
    if (data.containsKey('hops')) {
      context.handle(
        _hopsMeta,
        hops.isAcceptableOrUnknown(data['hops']!, _hopsMeta),
      );
    } else if (isInserting) {
      context.missing(_hopsMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {messageId, relayId},
  ];
  @override
  RelayReceipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RelayReceipt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      relayId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relay_id'],
      )!,
      hops: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hops'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
    );
  }

  @override
  $RelayReceiptsTable createAlias(String alias) {
    return $RelayReceiptsTable(attachedDatabase, alias);
  }
}

class RelayReceipt extends DataClass implements Insertable<RelayReceipt> {
  final int id;
  final String messageId;
  final String relayId;
  final int hops;
  final DateTime receivedAt;
  const RelayReceipt({
    required this.id,
    required this.messageId,
    required this.relayId,
    required this.hops,
    required this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['relay_id'] = Variable<String>(relayId);
    map['hops'] = Variable<int>(hops);
    map['received_at'] = Variable<DateTime>(receivedAt);
    return map;
  }

  RelayReceiptsCompanion toCompanion(bool nullToAbsent) {
    return RelayReceiptsCompanion(
      id: Value(id),
      messageId: Value(messageId),
      relayId: Value(relayId),
      hops: Value(hops),
      receivedAt: Value(receivedAt),
    );
  }

  factory RelayReceipt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RelayReceipt(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      relayId: serializer.fromJson<String>(json['relayId']),
      hops: serializer.fromJson<int>(json['hops']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<String>(messageId),
      'relayId': serializer.toJson<String>(relayId),
      'hops': serializer.toJson<int>(hops),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
    };
  }

  RelayReceipt copyWith({
    int? id,
    String? messageId,
    String? relayId,
    int? hops,
    DateTime? receivedAt,
  }) => RelayReceipt(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    relayId: relayId ?? this.relayId,
    hops: hops ?? this.hops,
    receivedAt: receivedAt ?? this.receivedAt,
  );
  RelayReceipt copyWithCompanion(RelayReceiptsCompanion data) {
    return RelayReceipt(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      relayId: data.relayId.present ? data.relayId.value : this.relayId,
      hops: data.hops.present ? data.hops.value : this.hops,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RelayReceipt(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('relayId: $relayId, ')
          ..write('hops: $hops, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, messageId, relayId, hops, receivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RelayReceipt &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.relayId == this.relayId &&
          other.hops == this.hops &&
          other.receivedAt == this.receivedAt);
}

class RelayReceiptsCompanion extends UpdateCompanion<RelayReceipt> {
  final Value<int> id;
  final Value<String> messageId;
  final Value<String> relayId;
  final Value<int> hops;
  final Value<DateTime> receivedAt;
  const RelayReceiptsCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.relayId = const Value.absent(),
    this.hops = const Value.absent(),
    this.receivedAt = const Value.absent(),
  });
  RelayReceiptsCompanion.insert({
    this.id = const Value.absent(),
    required String messageId,
    required String relayId,
    required int hops,
    required DateTime receivedAt,
  }) : messageId = Value(messageId),
       relayId = Value(relayId),
       hops = Value(hops),
       receivedAt = Value(receivedAt);
  static Insertable<RelayReceipt> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<String>? relayId,
    Expression<int>? hops,
    Expression<DateTime>? receivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (relayId != null) 'relay_id': relayId,
      if (hops != null) 'hops': hops,
      if (receivedAt != null) 'received_at': receivedAt,
    });
  }

  RelayReceiptsCompanion copyWith({
    Value<int>? id,
    Value<String>? messageId,
    Value<String>? relayId,
    Value<int>? hops,
    Value<DateTime>? receivedAt,
  }) {
    return RelayReceiptsCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      relayId: relayId ?? this.relayId,
      hops: hops ?? this.hops,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (relayId.present) {
      map['relay_id'] = Variable<String>(relayId.value);
    }
    if (hops.present) {
      map['hops'] = Variable<int>(hops.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RelayReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('relayId: $relayId, ')
          ..write('hops: $hops, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }
}

class $DeliveryAcksTable extends DeliveryAcks
    with TableInfo<$DeliveryAcksTable, DeliveryAck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveryAcksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  @override
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ackSenderIdMeta = const VerificationMeta(
    'ackSenderId',
  );
  @override
  late final GeneratedColumn<String> ackSenderId = GeneratedColumn<String>(
    'ack_sender_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    messageId,
    ackSenderId,
    status,
    receivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'delivery_acks';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeliveryAck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('ack_sender_id')) {
      context.handle(
        _ackSenderIdMeta,
        ackSenderId.isAcceptableOrUnknown(
          data['ack_sender_id']!,
          _ackSenderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ackSenderIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {messageId, ackSenderId},
  ];
  @override
  DeliveryAck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveryAck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      ackSenderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ack_sender_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
    );
  }

  @override
  $DeliveryAcksTable createAlias(String alias) {
    return $DeliveryAcksTable(attachedDatabase, alias);
  }
}

class DeliveryAck extends DataClass implements Insertable<DeliveryAck> {
  final int id;
  final String messageId;
  final String ackSenderId;
  final int status;
  final DateTime receivedAt;
  const DeliveryAck({
    required this.id,
    required this.messageId,
    required this.ackSenderId,
    required this.status,
    required this.receivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_id'] = Variable<String>(messageId);
    map['ack_sender_id'] = Variable<String>(ackSenderId);
    map['status'] = Variable<int>(status);
    map['received_at'] = Variable<DateTime>(receivedAt);
    return map;
  }

  DeliveryAcksCompanion toCompanion(bool nullToAbsent) {
    return DeliveryAcksCompanion(
      id: Value(id),
      messageId: Value(messageId),
      ackSenderId: Value(ackSenderId),
      status: Value(status),
      receivedAt: Value(receivedAt),
    );
  }

  factory DeliveryAck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveryAck(
      id: serializer.fromJson<int>(json['id']),
      messageId: serializer.fromJson<String>(json['messageId']),
      ackSenderId: serializer.fromJson<String>(json['ackSenderId']),
      status: serializer.fromJson<int>(json['status']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageId': serializer.toJson<String>(messageId),
      'ackSenderId': serializer.toJson<String>(ackSenderId),
      'status': serializer.toJson<int>(status),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
    };
  }

  DeliveryAck copyWith({
    int? id,
    String? messageId,
    String? ackSenderId,
    int? status,
    DateTime? receivedAt,
  }) => DeliveryAck(
    id: id ?? this.id,
    messageId: messageId ?? this.messageId,
    ackSenderId: ackSenderId ?? this.ackSenderId,
    status: status ?? this.status,
    receivedAt: receivedAt ?? this.receivedAt,
  );
  DeliveryAck copyWithCompanion(DeliveryAcksCompanion data) {
    return DeliveryAck(
      id: data.id.present ? data.id.value : this.id,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      ackSenderId: data.ackSenderId.present
          ? data.ackSenderId.value
          : this.ackSenderId,
      status: data.status.present ? data.status.value : this.status,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryAck(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('ackSenderId: $ackSenderId, ')
          ..write('status: $status, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, messageId, ackSenderId, status, receivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveryAck &&
          other.id == this.id &&
          other.messageId == this.messageId &&
          other.ackSenderId == this.ackSenderId &&
          other.status == this.status &&
          other.receivedAt == this.receivedAt);
}

class DeliveryAcksCompanion extends UpdateCompanion<DeliveryAck> {
  final Value<int> id;
  final Value<String> messageId;
  final Value<String> ackSenderId;
  final Value<int> status;
  final Value<DateTime> receivedAt;
  const DeliveryAcksCompanion({
    this.id = const Value.absent(),
    this.messageId = const Value.absent(),
    this.ackSenderId = const Value.absent(),
    this.status = const Value.absent(),
    this.receivedAt = const Value.absent(),
  });
  DeliveryAcksCompanion.insert({
    this.id = const Value.absent(),
    required String messageId,
    required String ackSenderId,
    required int status,
    required DateTime receivedAt,
  }) : messageId = Value(messageId),
       ackSenderId = Value(ackSenderId),
       status = Value(status),
       receivedAt = Value(receivedAt);
  static Insertable<DeliveryAck> custom({
    Expression<int>? id,
    Expression<String>? messageId,
    Expression<String>? ackSenderId,
    Expression<int>? status,
    Expression<DateTime>? receivedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageId != null) 'message_id': messageId,
      if (ackSenderId != null) 'ack_sender_id': ackSenderId,
      if (status != null) 'status': status,
      if (receivedAt != null) 'received_at': receivedAt,
    });
  }

  DeliveryAcksCompanion copyWith({
    Value<int>? id,
    Value<String>? messageId,
    Value<String>? ackSenderId,
    Value<int>? status,
    Value<DateTime>? receivedAt,
  }) {
    return DeliveryAcksCompanion(
      id: id ?? this.id,
      messageId: messageId ?? this.messageId,
      ackSenderId: ackSenderId ?? this.ackSenderId,
      status: status ?? this.status,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (ackSenderId.present) {
      map['ack_sender_id'] = Variable<String>(ackSenderId.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveryAcksCompanion(')
          ..write('id: $id, ')
          ..write('messageId: $messageId, ')
          ..write('ackSenderId: $ackSenderId, ')
          ..write('status: $status, ')
          ..write('receivedAt: $receivedAt')
          ..write(')'))
        .toString();
  }
}

class $TrustedAlertsTable extends TrustedAlerts
    with TableInfo<$TrustedAlertsTable, TrustedAlert> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrustedAlertsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _alertIdMeta = const VerificationMeta(
    'alertId',
  );
  @override
  late final GeneratedColumn<String> alertId = GeneratedColumn<String>(
    'alert_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorityIdMeta = const VerificationMeta(
    'authorityId',
  );
  @override
  late final GeneratedColumn<String> authorityId = GeneratedColumn<String>(
    'authority_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _severityMeta = const VerificationMeta(
    'severity',
  );
  @override
  late final GeneratedColumn<int> severity = GeneratedColumn<int>(
    'severity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _receivedAtMeta = const VerificationMeta(
    'receivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> receivedAt = GeneratedColumn<DateTime>(
    'received_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    alertId,
    authorityId,
    payload,
    severity,
    title,
    body,
    receivedAt,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trusted_alerts';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrustedAlert> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('alert_id')) {
      context.handle(
        _alertIdMeta,
        alertId.isAcceptableOrUnknown(data['alert_id']!, _alertIdMeta),
      );
    } else if (isInserting) {
      context.missing(_alertIdMeta);
    }
    if (data.containsKey('authority_id')) {
      context.handle(
        _authorityIdMeta,
        authorityId.isAcceptableOrUnknown(
          data['authority_id']!,
          _authorityIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_authorityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('severity')) {
      context.handle(
        _severityMeta,
        severity.isAcceptableOrUnknown(data['severity']!, _severityMeta),
      );
    } else if (isInserting) {
      context.missing(_severityMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {alertId};
  @override
  TrustedAlert map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrustedAlert(
      alertId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alert_id'],
      )!,
      authorityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authority_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      severity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}severity'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $TrustedAlertsTable createAlias(String alias) {
    return $TrustedAlertsTable(attachedDatabase, alias);
  }
}

class TrustedAlert extends DataClass implements Insertable<TrustedAlert> {
  final String alertId;
  final String authorityId;
  final String payload;
  final int severity;
  final String title;
  final String body;
  final DateTime receivedAt;
  final DateTime expiresAt;
  const TrustedAlert({
    required this.alertId,
    required this.authorityId,
    required this.payload,
    required this.severity,
    required this.title,
    required this.body,
    required this.receivedAt,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['alert_id'] = Variable<String>(alertId);
    map['authority_id'] = Variable<String>(authorityId);
    map['payload'] = Variable<String>(payload);
    map['severity'] = Variable<int>(severity);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  TrustedAlertsCompanion toCompanion(bool nullToAbsent) {
    return TrustedAlertsCompanion(
      alertId: Value(alertId),
      authorityId: Value(authorityId),
      payload: Value(payload),
      severity: Value(severity),
      title: Value(title),
      body: Value(body),
      receivedAt: Value(receivedAt),
      expiresAt: Value(expiresAt),
    );
  }

  factory TrustedAlert.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrustedAlert(
      alertId: serializer.fromJson<String>(json['alertId']),
      authorityId: serializer.fromJson<String>(json['authorityId']),
      payload: serializer.fromJson<String>(json['payload']),
      severity: serializer.fromJson<int>(json['severity']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'alertId': serializer.toJson<String>(alertId),
      'authorityId': serializer.toJson<String>(authorityId),
      'payload': serializer.toJson<String>(payload),
      'severity': serializer.toJson<int>(severity),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  TrustedAlert copyWith({
    String? alertId,
    String? authorityId,
    String? payload,
    int? severity,
    String? title,
    String? body,
    DateTime? receivedAt,
    DateTime? expiresAt,
  }) => TrustedAlert(
    alertId: alertId ?? this.alertId,
    authorityId: authorityId ?? this.authorityId,
    payload: payload ?? this.payload,
    severity: severity ?? this.severity,
    title: title ?? this.title,
    body: body ?? this.body,
    receivedAt: receivedAt ?? this.receivedAt,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  TrustedAlert copyWithCompanion(TrustedAlertsCompanion data) {
    return TrustedAlert(
      alertId: data.alertId.present ? data.alertId.value : this.alertId,
      authorityId: data.authorityId.present
          ? data.authorityId.value
          : this.authorityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      severity: data.severity.present ? data.severity.value : this.severity,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrustedAlert(')
          ..write('alertId: $alertId, ')
          ..write('authorityId: $authorityId, ')
          ..write('payload: $payload, ')
          ..write('severity: $severity, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    alertId,
    authorityId,
    payload,
    severity,
    title,
    body,
    receivedAt,
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrustedAlert &&
          other.alertId == this.alertId &&
          other.authorityId == this.authorityId &&
          other.payload == this.payload &&
          other.severity == this.severity &&
          other.title == this.title &&
          other.body == this.body &&
          other.receivedAt == this.receivedAt &&
          other.expiresAt == this.expiresAt);
}

class TrustedAlertsCompanion extends UpdateCompanion<TrustedAlert> {
  final Value<String> alertId;
  final Value<String> authorityId;
  final Value<String> payload;
  final Value<int> severity;
  final Value<String> title;
  final Value<String> body;
  final Value<DateTime> receivedAt;
  final Value<DateTime> expiresAt;
  final Value<int> rowid;
  const TrustedAlertsCompanion({
    this.alertId = const Value.absent(),
    this.authorityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.severity = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TrustedAlertsCompanion.insert({
    required String alertId,
    required String authorityId,
    required String payload,
    required int severity,
    required String title,
    required String body,
    required DateTime receivedAt,
    required DateTime expiresAt,
    this.rowid = const Value.absent(),
  }) : alertId = Value(alertId),
       authorityId = Value(authorityId),
       payload = Value(payload),
       severity = Value(severity),
       title = Value(title),
       body = Value(body),
       receivedAt = Value(receivedAt),
       expiresAt = Value(expiresAt);
  static Insertable<TrustedAlert> custom({
    Expression<String>? alertId,
    Expression<String>? authorityId,
    Expression<String>? payload,
    Expression<int>? severity,
    Expression<String>? title,
    Expression<String>? body,
    Expression<DateTime>? receivedAt,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (alertId != null) 'alert_id': alertId,
      if (authorityId != null) 'authority_id': authorityId,
      if (payload != null) 'payload': payload,
      if (severity != null) 'severity': severity,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (receivedAt != null) 'received_at': receivedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TrustedAlertsCompanion copyWith({
    Value<String>? alertId,
    Value<String>? authorityId,
    Value<String>? payload,
    Value<int>? severity,
    Value<String>? title,
    Value<String>? body,
    Value<DateTime>? receivedAt,
    Value<DateTime>? expiresAt,
    Value<int>? rowid,
  }) {
    return TrustedAlertsCompanion(
      alertId: alertId ?? this.alertId,
      authorityId: authorityId ?? this.authorityId,
      payload: payload ?? this.payload,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (alertId.present) {
      map['alert_id'] = Variable<String>(alertId.value);
    }
    if (authorityId.present) {
      map['authority_id'] = Variable<String>(authorityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (severity.present) {
      map['severity'] = Variable<int>(severity.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrustedAlertsCompanion(')
          ..write('alertId: $alertId, ')
          ..write('authorityId: $authorityId, ')
          ..write('payload: $payload, ')
          ..write('severity: $severity, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsEntriesTable extends SettingsEntries
    with TableInfo<$SettingsEntriesTable, SettingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntry(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsEntriesTable createAlias(String alias) {
    return $SettingsEntriesTable(attachedDatabase, alias);
  }
}

class SettingEntry extends DataClass implements Insertable<SettingEntry> {
  final String key;
  final String value;
  const SettingEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingsEntriesCompanion(key: Value(key), value: Value(value));
  }

  factory SettingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingEntry copyWith({String? key, String? value}) =>
      SettingEntry(key: key ?? this.key, value: value ?? this.value);
  SettingEntry copyWithCompanion(SettingsEntriesCompanion data) {
    return SettingEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsEntriesCompanion extends UpdateCompanion<SettingEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsEntriesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PeersTable extends Peers with TableInfo<$PeersTable, Peer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transportMeta = const VerificationMeta(
    'transport',
  );
  @override
  late final GeneratedColumn<String> transport = GeneratedColumn<String>(
    'transport',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rssiMeta = const VerificationMeta('rssi');
  @override
  late final GeneratedColumn<int> rssi = GeneratedColumn<int>(
    'rssi',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transport,
    displayName,
    rssi,
    lastSeenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'peers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Peer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transport')) {
      context.handle(
        _transportMeta,
        transport.isAcceptableOrUnknown(data['transport']!, _transportMeta),
      );
    } else if (isInserting) {
      context.missing(_transportMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('rssi')) {
      context.handle(
        _rssiMeta,
        rssi.isAcceptableOrUnknown(data['rssi']!, _rssiMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Peer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Peer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transport: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transport'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      rssi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rssi'],
      ),
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
    );
  }

  @override
  $PeersTable createAlias(String alias) {
    return $PeersTable(attachedDatabase, alias);
  }
}

class Peer extends DataClass implements Insertable<Peer> {
  final String id;
  final String transport;
  final String? displayName;
  final int? rssi;
  final DateTime lastSeenAt;
  const Peer({
    required this.id,
    required this.transport,
    this.displayName,
    this.rssi,
    required this.lastSeenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transport'] = Variable<String>(transport);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    if (!nullToAbsent || rssi != null) {
      map['rssi'] = Variable<int>(rssi);
    }
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    return map;
  }

  PeersCompanion toCompanion(bool nullToAbsent) {
    return PeersCompanion(
      id: Value(id),
      transport: Value(transport),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      rssi: rssi == null && nullToAbsent ? const Value.absent() : Value(rssi),
      lastSeenAt: Value(lastSeenAt),
    );
  }

  factory Peer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Peer(
      id: serializer.fromJson<String>(json['id']),
      transport: serializer.fromJson<String>(json['transport']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      rssi: serializer.fromJson<int?>(json['rssi']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transport': serializer.toJson<String>(transport),
      'displayName': serializer.toJson<String?>(displayName),
      'rssi': serializer.toJson<int?>(rssi),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
    };
  }

  Peer copyWith({
    String? id,
    String? transport,
    Value<String?> displayName = const Value.absent(),
    Value<int?> rssi = const Value.absent(),
    DateTime? lastSeenAt,
  }) => Peer(
    id: id ?? this.id,
    transport: transport ?? this.transport,
    displayName: displayName.present ? displayName.value : this.displayName,
    rssi: rssi.present ? rssi.value : this.rssi,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
  Peer copyWithCompanion(PeersCompanion data) {
    return Peer(
      id: data.id.present ? data.id.value : this.id,
      transport: data.transport.present ? data.transport.value : this.transport,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      rssi: data.rssi.present ? data.rssi.value : this.rssi,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Peer(')
          ..write('id: $id, ')
          ..write('transport: $transport, ')
          ..write('displayName: $displayName, ')
          ..write('rssi: $rssi, ')
          ..write('lastSeenAt: $lastSeenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, transport, displayName, rssi, lastSeenAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Peer &&
          other.id == this.id &&
          other.transport == this.transport &&
          other.displayName == this.displayName &&
          other.rssi == this.rssi &&
          other.lastSeenAt == this.lastSeenAt);
}

class PeersCompanion extends UpdateCompanion<Peer> {
  final Value<String> id;
  final Value<String> transport;
  final Value<String?> displayName;
  final Value<int?> rssi;
  final Value<DateTime> lastSeenAt;
  final Value<int> rowid;
  const PeersCompanion({
    this.id = const Value.absent(),
    this.transport = const Value.absent(),
    this.displayName = const Value.absent(),
    this.rssi = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeersCompanion.insert({
    required String id,
    required String transport,
    this.displayName = const Value.absent(),
    this.rssi = const Value.absent(),
    required DateTime lastSeenAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transport = Value(transport),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<Peer> custom({
    Expression<String>? id,
    Expression<String>? transport,
    Expression<String>? displayName,
    Expression<int>? rssi,
    Expression<DateTime>? lastSeenAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transport != null) 'transport': transport,
      if (displayName != null) 'display_name': displayName,
      if (rssi != null) 'rssi': rssi,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeersCompanion copyWith({
    Value<String>? id,
    Value<String>? transport,
    Value<String?>? displayName,
    Value<int?>? rssi,
    Value<DateTime>? lastSeenAt,
    Value<int>? rowid,
  }) {
    return PeersCompanion(
      id: id ?? this.id,
      transport: transport ?? this.transport,
      displayName: displayName ?? this.displayName,
      rssi: rssi ?? this.rssi,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transport.present) {
      map['transport'] = Variable<String>(transport.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (rssi.present) {
      map['rssi'] = Variable<int>(rssi.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeersCompanion(')
          ..write('id: $id, ')
          ..write('transport: $transport, ')
          ..write('displayName: $displayName, ')
          ..write('rssi: $rssi, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $IdentitiesTable identities = $IdentitiesTable(this);
  late final $ChannelsTable channels = $ChannelsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $PacketsOutboxTable packetsOutbox = $PacketsOutboxTable(this);
  late final $SeenPacketsTable seenPackets = $SeenPacketsTable(this);
  late final $RelayReceiptsTable relayReceipts = $RelayReceiptsTable(this);
  late final $DeliveryAcksTable deliveryAcks = $DeliveryAcksTable(this);
  late final $TrustedAlertsTable trustedAlerts = $TrustedAlertsTable(this);
  late final $SettingsEntriesTable settingsEntries = $SettingsEntriesTable(
    this,
  );
  late final $PeersTable peers = $PeersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    identities,
    channels,
    messages,
    packetsOutbox,
    seenPackets,
    relayReceipts,
    deliveryAcks,
    trustedAlerts,
    settingsEntries,
    peers,
  ];
}

typedef $$IdentitiesTableCreateCompanionBuilder = IdentitiesCompanion Function({
  required String id,
  required Uint8List publicKey,
  required String displayName,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$IdentitiesTableUpdateCompanionBuilder = IdentitiesCompanion Function({
  Value<String> id,
  Value<Uint8List> publicKey,
  Value<String> displayName,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$IdentitiesTableFilterComposer
    extends Composer<_$AppDatabase, $IdentitiesTable> {
  $$IdentitiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IdentitiesTableOrderingComposer
    extends Composer<_$AppDatabase, $IdentitiesTable> {
  $$IdentitiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IdentitiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdentitiesTable> {
  $$IdentitiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<Uint8List> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$IdentitiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IdentitiesTable,
          IdentityRecord,
          $$IdentitiesTableFilterComposer,
          $$IdentitiesTableOrderingComposer,
          $$IdentitiesTableAnnotationComposer,
          $$IdentitiesTableCreateCompanionBuilder,
          $$IdentitiesTableUpdateCompanionBuilder,
          (
            IdentityRecord,
            BaseReferences<_$AppDatabase, $IdentitiesTable, IdentityRecord>,
          ),
          IdentityRecord,
          PrefetchHooks Function()
        > {
  $$IdentitiesTableTableManager(_$AppDatabase db, $IdentitiesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdentitiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdentitiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdentitiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uint8List> publicKey = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => IdentitiesCompanion(
                id: id,
                publicKey: publicKey,
                displayName: displayName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uint8List publicKey,
                required String displayName,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => IdentitiesCompanion.insert(
                id: id,
                publicKey: publicKey,
                displayName: displayName,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IdentitiesTable, IdentityRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $IdentitiesTable,
                    IdentityRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IdentitiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IdentitiesTable,
      IdentityRecord,
      $$IdentitiesTableFilterComposer,
      $$IdentitiesTableOrderingComposer,
      $$IdentitiesTableAnnotationComposer,
      $$IdentitiesTableCreateCompanionBuilder,
      $$IdentitiesTableUpdateCompanionBuilder,
      (
        IdentityRecord,
        BaseReferences<_$AppDatabase, $IdentitiesTable, IdentityRecord>,
      ),
      IdentityRecord,
      PrefetchHooks Function()
    >;
typedef $$ChannelsTableCreateCompanionBuilder = ChannelsCompanion Function({
  required String id,
  required String code,
  required Uint8List codeHash,
  required String name,
  required DateTime joinedAt,
  Value<int> rowid,
});
typedef $$ChannelsTableUpdateCompanionBuilder = ChannelsCompanion Function({
  Value<String> id,
  Value<String> code,
  Value<Uint8List> codeHash,
  Value<String> name,
  Value<DateTime> joinedAt,
  Value<int> rowid,
});

class $$ChannelsTableFilterComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get codeHash => $composableBuilder(
    column: $table.codeHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChannelsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get codeHash => $composableBuilder(
    column: $table.codeHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChannelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<Uint8List> get codeHash =>
      $composableBuilder(column: $table.codeHash, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);
}

class $$ChannelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChannelsTable,
          Channel,
          $$ChannelsTableFilterComposer,
          $$ChannelsTableOrderingComposer,
          $$ChannelsTableAnnotationComposer,
          $$ChannelsTableCreateCompanionBuilder,
          $$ChannelsTableUpdateCompanionBuilder,
          (Channel, BaseReferences<_$AppDatabase, $ChannelsTable, Channel>),
          Channel,
          PrefetchHooks Function()
        > {
  $$ChannelsTableTableManager(_$AppDatabase db, $ChannelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<Uint8List> codeHash = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> joinedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChannelsCompanion(
                id: id,
                code: code,
                codeHash: codeHash,
                name: name,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required Uint8List codeHash,
                required String name,
                required DateTime joinedAt,
                Value<int> rowid = const Value.absent(),
              }) => ChannelsCompanion.insert(
                id: id,
                code: code,
                codeHash: codeHash,
                name: name,
                joinedAt: joinedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChannelsTable, Channel>(table),
                  BaseReferences<_$AppDatabase, $ChannelsTable, Channel>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChannelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChannelsTable,
      Channel,
      $$ChannelsTableFilterComposer,
      $$ChannelsTableOrderingComposer,
      $$ChannelsTableAnnotationComposer,
      $$ChannelsTableCreateCompanionBuilder,
      $$ChannelsTableUpdateCompanionBuilder,
      (Channel, BaseReferences<_$AppDatabase, $ChannelsTable, Channel>),
      Channel,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  required String id,
  required String channelId,
  required String senderId,
  required String senderName,
  required String body,
  required DateTime createdAt,
  required int direction,
  required int status,
  required int priority,
  Value<DateTime?> expiresAt,
  Value<bool> isAlert,
  Value<String?> alertAuthority,
  Value<int> relayCount,
  Value<int> seenCount,
  Value<int> rowid,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<String> id,
  Value<String> channelId,
  Value<String> senderId,
  Value<String> senderName,
  Value<String> body,
  Value<DateTime> createdAt,
  Value<int> direction,
  Value<int> status,
  Value<int> priority,
  Value<DateTime?> expiresAt,
  Value<bool> isAlert,
  Value<String?> alertAuthority,
  Value<int> relayCount,
  Value<int> seenCount,
  Value<int> rowid,
});

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAlert => $composableBuilder(
    column: $table.isAlert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alertAuthority => $composableBuilder(
    column: $table.alertAuthority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relayCount => $composableBuilder(
    column: $table.relayCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seenCount => $composableBuilder(
    column: $table.seenCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelId => $composableBuilder(
    column: $table.channelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderId => $composableBuilder(
    column: $table.senderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAlert => $composableBuilder(
    column: $table.isAlert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alertAuthority => $composableBuilder(
    column: $table.alertAuthority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relayCount => $composableBuilder(
    column: $table.relayCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seenCount => $composableBuilder(
    column: $table.seenCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get senderName => $composableBuilder(
    column: $table.senderName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<bool> get isAlert =>
      $composableBuilder(column: $table.isAlert, builder: (column) => column);

  GeneratedColumn<String> get alertAuthority => $composableBuilder(
    column: $table.alertAuthority,
    builder: (column) => column,
  );

  GeneratedColumn<int> get relayCount => $composableBuilder(
    column: $table.relayCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seenCount =>
      $composableBuilder(column: $table.seenCount, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> channelId = const Value.absent(),
                Value<String> senderId = const Value.absent(),
                Value<String> senderName = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> direction = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<bool> isAlert = const Value.absent(),
                Value<String?> alertAuthority = const Value.absent(),
                Value<int> relayCount = const Value.absent(),
                Value<int> seenCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                channelId: channelId,
                senderId: senderId,
                senderName: senderName,
                body: body,
                createdAt: createdAt,
                direction: direction,
                status: status,
                priority: priority,
                expiresAt: expiresAt,
                isAlert: isAlert,
                alertAuthority: alertAuthority,
                relayCount: relayCount,
                seenCount: seenCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String channelId,
                required String senderId,
                required String senderName,
                required String body,
                required DateTime createdAt,
                required int direction,
                required int status,
                required int priority,
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<bool> isAlert = const Value.absent(),
                Value<String?> alertAuthority = const Value.absent(),
                Value<int> relayCount = const Value.absent(),
                Value<int> seenCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                channelId: channelId,
                senderId: senderId,
                senderName: senderName,
                body: body,
                createdAt: createdAt,
                direction: direction,
                status: status,
                priority: priority,
                expiresAt: expiresAt,
                isAlert: isAlert,
                alertAuthority: alertAuthority,
                relayCount: relayCount,
                seenCount: seenCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessagesTable, Message>(table),
                  BaseReferences<_$AppDatabase, $MessagesTable, Message>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;
typedef $$PacketsOutboxTableCreateCompanionBuilder =
    PacketsOutboxCompanion Function({
      required String packetId,
      required String messageId,
      required Uint8List bytes,
      required int priority,
      required DateTime createdAt,
      required DateTime nextAttemptAt,
      Value<int> attempts,
      required DateTime expiresAt,
      Value<int> rowid,
    });
typedef $$PacketsOutboxTableUpdateCompanionBuilder =
    PacketsOutboxCompanion Function({
      Value<String> packetId,
      Value<String> messageId,
      Value<Uint8List> bytes,
      Value<int> priority,
      Value<DateTime> createdAt,
      Value<DateTime> nextAttemptAt,
      Value<int> attempts,
      Value<DateTime> expiresAt,
      Value<int> rowid,
    });

class $$PacketsOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $PacketsOutboxTable> {
  $$PacketsOutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packetId => $composableBuilder(
    column: $table.packetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PacketsOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $PacketsOutboxTable> {
  $$PacketsOutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packetId => $composableBuilder(
    column: $table.packetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PacketsOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $PacketsOutboxTable> {
  $$PacketsOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packetId =>
      $composableBuilder(column: $table.packetId, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$PacketsOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PacketsOutboxTable,
          OutboxEntry,
          $$PacketsOutboxTableFilterComposer,
          $$PacketsOutboxTableOrderingComposer,
          $$PacketsOutboxTableAnnotationComposer,
          $$PacketsOutboxTableCreateCompanionBuilder,
          $$PacketsOutboxTableUpdateCompanionBuilder,
          (
            OutboxEntry,
            BaseReferences<_$AppDatabase, $PacketsOutboxTable, OutboxEntry>,
          ),
          OutboxEntry,
          PrefetchHooks Function()
        > {
  $$PacketsOutboxTableTableManager(_$AppDatabase db, $PacketsOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PacketsOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PacketsOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PacketsOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> packetId = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> nextAttemptAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PacketsOutboxCompanion(
                packetId: packetId,
                messageId: messageId,
                bytes: bytes,
                priority: priority,
                createdAt: createdAt,
                nextAttemptAt: nextAttemptAt,
                attempts: attempts,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packetId,
                required String messageId,
                required Uint8List bytes,
                required int priority,
                required DateTime createdAt,
                required DateTime nextAttemptAt,
                Value<int> attempts = const Value.absent(),
                required DateTime expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => PacketsOutboxCompanion.insert(
                packetId: packetId,
                messageId: messageId,
                bytes: bytes,
                priority: priority,
                createdAt: createdAt,
                nextAttemptAt: nextAttemptAt,
                attempts: attempts,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PacketsOutboxTable, OutboxEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PacketsOutboxTable,
                    OutboxEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PacketsOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PacketsOutboxTable,
      OutboxEntry,
      $$PacketsOutboxTableFilterComposer,
      $$PacketsOutboxTableOrderingComposer,
      $$PacketsOutboxTableAnnotationComposer,
      $$PacketsOutboxTableCreateCompanionBuilder,
      $$PacketsOutboxTableUpdateCompanionBuilder,
      (
        OutboxEntry,
        BaseReferences<_$AppDatabase, $PacketsOutboxTable, OutboxEntry>,
      ),
      OutboxEntry,
      PrefetchHooks Function()
    >;
typedef $$SeenPacketsTableCreateCompanionBuilder =
    SeenPacketsCompanion Function({
      required String packetId,
      required DateTime firstSeenAt,
      required DateTime expiresAt,
      Value<int> rowid,
    });
typedef $$SeenPacketsTableUpdateCompanionBuilder =
    SeenPacketsCompanion Function({
      Value<String> packetId,
      Value<DateTime> firstSeenAt,
      Value<DateTime> expiresAt,
      Value<int> rowid,
    });

class $$SeenPacketsTableFilterComposer
    extends Composer<_$AppDatabase, $SeenPacketsTable> {
  $$SeenPacketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packetId => $composableBuilder(
    column: $table.packetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeenPacketsTableOrderingComposer
    extends Composer<_$AppDatabase, $SeenPacketsTable> {
  $$SeenPacketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packetId => $composableBuilder(
    column: $table.packetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeenPacketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeenPacketsTable> {
  $$SeenPacketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packetId =>
      $composableBuilder(column: $table.packetId, builder: (column) => column);

  GeneratedColumn<DateTime> get firstSeenAt => $composableBuilder(
    column: $table.firstSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$SeenPacketsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeenPacketsTable,
          SeenPacket,
          $$SeenPacketsTableFilterComposer,
          $$SeenPacketsTableOrderingComposer,
          $$SeenPacketsTableAnnotationComposer,
          $$SeenPacketsTableCreateCompanionBuilder,
          $$SeenPacketsTableUpdateCompanionBuilder,
          (
            SeenPacket,
            BaseReferences<_$AppDatabase, $SeenPacketsTable, SeenPacket>,
          ),
          SeenPacket,
          PrefetchHooks Function()
        > {
  $$SeenPacketsTableTableManager(_$AppDatabase db, $SeenPacketsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeenPacketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeenPacketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeenPacketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> packetId = const Value.absent(),
                Value<DateTime> firstSeenAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeenPacketsCompanion(
                packetId: packetId,
                firstSeenAt: firstSeenAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packetId,
                required DateTime firstSeenAt,
                required DateTime expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => SeenPacketsCompanion.insert(
                packetId: packetId,
                firstSeenAt: firstSeenAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SeenPacketsTable, SeenPacket>(table),
                  BaseReferences<_$AppDatabase, $SeenPacketsTable, SeenPacket>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeenPacketsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeenPacketsTable,
      SeenPacket,
      $$SeenPacketsTableFilterComposer,
      $$SeenPacketsTableOrderingComposer,
      $$SeenPacketsTableAnnotationComposer,
      $$SeenPacketsTableCreateCompanionBuilder,
      $$SeenPacketsTableUpdateCompanionBuilder,
      (
        SeenPacket,
        BaseReferences<_$AppDatabase, $SeenPacketsTable, SeenPacket>,
      ),
      SeenPacket,
      PrefetchHooks Function()
    >;
typedef $$RelayReceiptsTableCreateCompanionBuilder =
    RelayReceiptsCompanion Function({
      Value<int> id,
      required String messageId,
      required String relayId,
      required int hops,
      required DateTime receivedAt,
    });
typedef $$RelayReceiptsTableUpdateCompanionBuilder =
    RelayReceiptsCompanion Function({
      Value<int> id,
      Value<String> messageId,
      Value<String> relayId,
      Value<int> hops,
      Value<DateTime> receivedAt,
    });

class $$RelayReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $RelayReceiptsTable> {
  $$RelayReceiptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relayId => $composableBuilder(
    column: $table.relayId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hops => $composableBuilder(
    column: $table.hops,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RelayReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $RelayReceiptsTable> {
  $$RelayReceiptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relayId => $composableBuilder(
    column: $table.relayId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hops => $composableBuilder(
    column: $table.hops,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RelayReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RelayReceiptsTable> {
  $$RelayReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get relayId =>
      $composableBuilder(column: $table.relayId, builder: (column) => column);

  GeneratedColumn<int> get hops =>
      $composableBuilder(column: $table.hops, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );
}

class $$RelayReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RelayReceiptsTable,
          RelayReceipt,
          $$RelayReceiptsTableFilterComposer,
          $$RelayReceiptsTableOrderingComposer,
          $$RelayReceiptsTableAnnotationComposer,
          $$RelayReceiptsTableCreateCompanionBuilder,
          $$RelayReceiptsTableUpdateCompanionBuilder,
          (
            RelayReceipt,
            BaseReferences<_$AppDatabase, $RelayReceiptsTable, RelayReceipt>,
          ),
          RelayReceipt,
          PrefetchHooks Function()
        > {
  $$RelayReceiptsTableTableManager(_$AppDatabase db, $RelayReceiptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RelayReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RelayReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RelayReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> relayId = const Value.absent(),
                Value<int> hops = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
              }) => RelayReceiptsCompanion(
                id: id,
                messageId: messageId,
                relayId: relayId,
                hops: hops,
                receivedAt: receivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageId,
                required String relayId,
                required int hops,
                required DateTime receivedAt,
              }) => RelayReceiptsCompanion.insert(
                id: id,
                messageId: messageId,
                relayId: relayId,
                hops: hops,
                receivedAt: receivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RelayReceiptsTable, RelayReceipt>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RelayReceiptsTable,
                    RelayReceipt
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RelayReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RelayReceiptsTable,
      RelayReceipt,
      $$RelayReceiptsTableFilterComposer,
      $$RelayReceiptsTableOrderingComposer,
      $$RelayReceiptsTableAnnotationComposer,
      $$RelayReceiptsTableCreateCompanionBuilder,
      $$RelayReceiptsTableUpdateCompanionBuilder,
      (
        RelayReceipt,
        BaseReferences<_$AppDatabase, $RelayReceiptsTable, RelayReceipt>,
      ),
      RelayReceipt,
      PrefetchHooks Function()
    >;
typedef $$DeliveryAcksTableCreateCompanionBuilder =
    DeliveryAcksCompanion Function({
      Value<int> id,
      required String messageId,
      required String ackSenderId,
      required int status,
      required DateTime receivedAt,
    });
typedef $$DeliveryAcksTableUpdateCompanionBuilder =
    DeliveryAcksCompanion Function({
      Value<int> id,
      Value<String> messageId,
      Value<String> ackSenderId,
      Value<int> status,
      Value<DateTime> receivedAt,
    });

class $$DeliveryAcksTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveryAcksTable> {
  $$DeliveryAcksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ackSenderId => $composableBuilder(
    column: $table.ackSenderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeliveryAcksTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveryAcksTable> {
  $$DeliveryAcksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ackSenderId => $composableBuilder(
    column: $table.ackSenderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeliveryAcksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveryAcksTable> {
  $$DeliveryAcksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get ackSenderId => $composableBuilder(
    column: $table.ackSenderId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );
}

class $$DeliveryAcksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeliveryAcksTable,
          DeliveryAck,
          $$DeliveryAcksTableFilterComposer,
          $$DeliveryAcksTableOrderingComposer,
          $$DeliveryAcksTableAnnotationComposer,
          $$DeliveryAcksTableCreateCompanionBuilder,
          $$DeliveryAcksTableUpdateCompanionBuilder,
          (
            DeliveryAck,
            BaseReferences<_$AppDatabase, $DeliveryAcksTable, DeliveryAck>,
          ),
          DeliveryAck,
          PrefetchHooks Function()
        > {
  $$DeliveryAcksTableTableManager(_$AppDatabase db, $DeliveryAcksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveryAcksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveryAcksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveryAcksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> ackSenderId = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
              }) => DeliveryAcksCompanion(
                id: id,
                messageId: messageId,
                ackSenderId: ackSenderId,
                status: status,
                receivedAt: receivedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String messageId,
                required String ackSenderId,
                required int status,
                required DateTime receivedAt,
              }) => DeliveryAcksCompanion.insert(
                id: id,
                messageId: messageId,
                ackSenderId: ackSenderId,
                status: status,
                receivedAt: receivedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DeliveryAcksTable, DeliveryAck>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $DeliveryAcksTable,
                    DeliveryAck
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeliveryAcksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeliveryAcksTable,
      DeliveryAck,
      $$DeliveryAcksTableFilterComposer,
      $$DeliveryAcksTableOrderingComposer,
      $$DeliveryAcksTableAnnotationComposer,
      $$DeliveryAcksTableCreateCompanionBuilder,
      $$DeliveryAcksTableUpdateCompanionBuilder,
      (
        DeliveryAck,
        BaseReferences<_$AppDatabase, $DeliveryAcksTable, DeliveryAck>,
      ),
      DeliveryAck,
      PrefetchHooks Function()
    >;
typedef $$TrustedAlertsTableCreateCompanionBuilder =
    TrustedAlertsCompanion Function({
      required String alertId,
      required String authorityId,
      required String payload,
      required int severity,
      required String title,
      required String body,
      required DateTime receivedAt,
      required DateTime expiresAt,
      Value<int> rowid,
    });
typedef $$TrustedAlertsTableUpdateCompanionBuilder =
    TrustedAlertsCompanion Function({
      Value<String> alertId,
      Value<String> authorityId,
      Value<String> payload,
      Value<int> severity,
      Value<String> title,
      Value<String> body,
      Value<DateTime> receivedAt,
      Value<DateTime> expiresAt,
      Value<int> rowid,
    });

class $$TrustedAlertsTableFilterComposer
    extends Composer<_$AppDatabase, $TrustedAlertsTable> {
  $$TrustedAlertsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get alertId => $composableBuilder(
    column: $table.alertId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorityId => $composableBuilder(
    column: $table.authorityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrustedAlertsTableOrderingComposer
    extends Composer<_$AppDatabase, $TrustedAlertsTable> {
  $$TrustedAlertsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get alertId => $composableBuilder(
    column: $table.alertId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorityId => $composableBuilder(
    column: $table.authorityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get severity => $composableBuilder(
    column: $table.severity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrustedAlertsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrustedAlertsTable> {
  $$TrustedAlertsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get alertId =>
      $composableBuilder(column: $table.alertId, builder: (column) => column);

  GeneratedColumn<String> get authorityId => $composableBuilder(
    column: $table.authorityId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get severity =>
      $composableBuilder(column: $table.severity, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$TrustedAlertsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrustedAlertsTable,
          TrustedAlert,
          $$TrustedAlertsTableFilterComposer,
          $$TrustedAlertsTableOrderingComposer,
          $$TrustedAlertsTableAnnotationComposer,
          $$TrustedAlertsTableCreateCompanionBuilder,
          $$TrustedAlertsTableUpdateCompanionBuilder,
          (
            TrustedAlert,
            BaseReferences<_$AppDatabase, $TrustedAlertsTable, TrustedAlert>,
          ),
          TrustedAlert,
          PrefetchHooks Function()
        > {
  $$TrustedAlertsTableTableManager(_$AppDatabase db, $TrustedAlertsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrustedAlertsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrustedAlertsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrustedAlertsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> alertId = const Value.absent(),
                Value<String> authorityId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> severity = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TrustedAlertsCompanion(
                alertId: alertId,
                authorityId: authorityId,
                payload: payload,
                severity: severity,
                title: title,
                body: body,
                receivedAt: receivedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String alertId,
                required String authorityId,
                required String payload,
                required int severity,
                required String title,
                required String body,
                required DateTime receivedAt,
                required DateTime expiresAt,
                Value<int> rowid = const Value.absent(),
              }) => TrustedAlertsCompanion.insert(
                alertId: alertId,
                authorityId: authorityId,
                payload: payload,
                severity: severity,
                title: title,
                body: body,
                receivedAt: receivedAt,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrustedAlertsTable, TrustedAlert>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TrustedAlertsTable,
                    TrustedAlert
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrustedAlertsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrustedAlertsTable,
      TrustedAlert,
      $$TrustedAlertsTableFilterComposer,
      $$TrustedAlertsTableOrderingComposer,
      $$TrustedAlertsTableAnnotationComposer,
      $$TrustedAlertsTableCreateCompanionBuilder,
      $$TrustedAlertsTableUpdateCompanionBuilder,
      (
        TrustedAlert,
        BaseReferences<_$AppDatabase, $TrustedAlertsTable, TrustedAlert>,
      ),
      TrustedAlert,
      PrefetchHooks Function()
    >;
typedef $$SettingsEntriesTableCreateCompanionBuilder =
    SettingsEntriesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsEntriesTableUpdateCompanionBuilder =
    SettingsEntriesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsEntriesTable> {
  $$SettingsEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsEntriesTable,
          SettingEntry,
          $$SettingsEntriesTableFilterComposer,
          $$SettingsEntriesTableOrderingComposer,
          $$SettingsEntriesTableAnnotationComposer,
          $$SettingsEntriesTableCreateCompanionBuilder,
          $$SettingsEntriesTableUpdateCompanionBuilder,
          (
            SettingEntry,
            BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingEntry>,
          ),
          SettingEntry,
          PrefetchHooks Function()
        > {
  $$SettingsEntriesTableTableManager(
    _$AppDatabase db,
    $SettingsEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsEntriesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsEntriesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsEntriesTable, SettingEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingsEntriesTable,
                    SettingEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsEntriesTable,
      SettingEntry,
      $$SettingsEntriesTableFilterComposer,
      $$SettingsEntriesTableOrderingComposer,
      $$SettingsEntriesTableAnnotationComposer,
      $$SettingsEntriesTableCreateCompanionBuilder,
      $$SettingsEntriesTableUpdateCompanionBuilder,
      (
        SettingEntry,
        BaseReferences<_$AppDatabase, $SettingsEntriesTable, SettingEntry>,
      ),
      SettingEntry,
      PrefetchHooks Function()
    >;
typedef $$PeersTableCreateCompanionBuilder = PeersCompanion Function({
  required String id,
  required String transport,
  Value<String?> displayName,
  Value<int?> rssi,
  required DateTime lastSeenAt,
  Value<int> rowid,
});
typedef $$PeersTableUpdateCompanionBuilder = PeersCompanion Function({
  Value<String> id,
  Value<String> transport,
  Value<String?> displayName,
  Value<int?> rssi,
  Value<DateTime> lastSeenAt,
  Value<int> rowid,
});

class $$PeersTableFilterComposer extends Composer<_$AppDatabase, $PeersTable> {
  $$PeersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transport => $composableBuilder(
    column: $table.transport,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rssi => $composableBuilder(
    column: $table.rssi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeersTableOrderingComposer
    extends Composer<_$AppDatabase, $PeersTable> {
  $$PeersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transport => $composableBuilder(
    column: $table.transport,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rssi => $composableBuilder(
    column: $table.rssi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeersTable> {
  $$PeersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transport =>
      $composableBuilder(column: $table.transport, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rssi =>
      $composableBuilder(column: $table.rssi, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );
}

class $$PeersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeersTable,
          Peer,
          $$PeersTableFilterComposer,
          $$PeersTableOrderingComposer,
          $$PeersTableAnnotationComposer,
          $$PeersTableCreateCompanionBuilder,
          $$PeersTableUpdateCompanionBuilder,
          (Peer, BaseReferences<_$AppDatabase, $PeersTable, Peer>),
          Peer,
          PrefetchHooks Function()
        > {
  $$PeersTableTableManager(_$AppDatabase db, $PeersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transport = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<int?> rssi = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeersCompanion(
                id: id,
                transport: transport,
                displayName: displayName,
                rssi: rssi,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transport,
                Value<String?> displayName = const Value.absent(),
                Value<int?> rssi = const Value.absent(),
                required DateTime lastSeenAt,
                Value<int> rowid = const Value.absent(),
              }) => PeersCompanion.insert(
                id: id,
                transport: transport,
                displayName: displayName,
                rssi: rssi,
                lastSeenAt: lastSeenAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PeersTable, Peer>(table),
                  BaseReferences<_$AppDatabase, $PeersTable, Peer>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeersTable,
      Peer,
      $$PeersTableFilterComposer,
      $$PeersTableOrderingComposer,
      $$PeersTableAnnotationComposer,
      $$PeersTableCreateCompanionBuilder,
      $$PeersTableUpdateCompanionBuilder,
      (Peer, BaseReferences<_$AppDatabase, $PeersTable, Peer>),
      Peer,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$IdentitiesTableTableManager get identities =>
      $$IdentitiesTableTableManager(_db, _db.identities);
  $$ChannelsTableTableManager get channels =>
      $$ChannelsTableTableManager(_db, _db.channels);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$PacketsOutboxTableTableManager get packetsOutbox =>
      $$PacketsOutboxTableTableManager(_db, _db.packetsOutbox);
  $$SeenPacketsTableTableManager get seenPackets =>
      $$SeenPacketsTableTableManager(_db, _db.seenPackets);
  $$RelayReceiptsTableTableManager get relayReceipts =>
      $$RelayReceiptsTableTableManager(_db, _db.relayReceipts);
  $$DeliveryAcksTableTableManager get deliveryAcks =>
      $$DeliveryAcksTableTableManager(_db, _db.deliveryAcks);
  $$TrustedAlertsTableTableManager get trustedAlerts =>
      $$TrustedAlertsTableTableManager(_db, _db.trustedAlerts);
  $$SettingsEntriesTableTableManager get settingsEntries =>
      $$SettingsEntriesTableTableManager(_db, _db.settingsEntries);
  $$PeersTableTableManager get peers =>
      $$PeersTableTableManager(_db, _db.peers);
}
