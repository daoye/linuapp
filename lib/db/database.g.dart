// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    groupId,
    messageId,
    isPinned,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final int id;
  final int type;
  final String groupId;
  final String messageId;
  final bool isPinned;
  const Conversation({
    required this.id,
    required this.type,
    required this.groupId,
    required this.messageId,
    required this.isPinned,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<int>(type);
    map['group_id'] = Variable<String>(groupId);
    map['message_id'] = Variable<String>(messageId);
    map['is_pinned'] = Variable<bool>(isPinned);
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      type: Value(type),
      groupId: Value(groupId),
      messageId: Value(messageId),
      isPinned: Value(isPinned),
    );
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<int>(json['type']),
      groupId: serializer.fromJson<String>(json['groupId']),
      messageId: serializer.fromJson<String>(json['messageId']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<int>(type),
      'groupId': serializer.toJson<String>(groupId),
      'messageId': serializer.toJson<String>(messageId),
      'isPinned': serializer.toJson<bool>(isPinned),
    };
  }

  Conversation copyWith({
    int? id,
    int? type,
    String? groupId,
    String? messageId,
    bool? isPinned,
  }) => Conversation(
    id: id ?? this.id,
    type: type ?? this.type,
    groupId: groupId ?? this.groupId,
    messageId: messageId ?? this.messageId,
    isPinned: isPinned ?? this.isPinned,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('groupId: $groupId, ')
          ..write('messageId: $messageId, ')
          ..write('isPinned: $isPinned')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, groupId, messageId, isPinned);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.type == this.type &&
          other.groupId == this.groupId &&
          other.messageId == this.messageId &&
          other.isPinned == this.isPinned);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<int> id;
  final Value<int> type;
  final Value<String> groupId;
  final Value<String> messageId;
  final Value<bool> isPinned;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.groupId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.isPinned = const Value.absent(),
  });
  ConversationsCompanion.insert({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.groupId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.isPinned = const Value.absent(),
  });
  static Insertable<Conversation> custom({
    Expression<int>? id,
    Expression<int>? type,
    Expression<String>? groupId,
    Expression<String>? messageId,
    Expression<bool>? isPinned,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (groupId != null) 'group_id': groupId,
      if (messageId != null) 'message_id': messageId,
      if (isPinned != null) 'is_pinned': isPinned,
    });
  }

  ConversationsCompanion copyWith({
    Value<int>? id,
    Value<int>? type,
    Value<String>? groupId,
    Value<String>? messageId,
    Value<bool>? isPinned,
  }) {
    return ConversationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      groupId: groupId ?? this.groupId,
      messageId: messageId ?? this.messageId,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('groupId: $groupId, ')
          ..write('messageId: $messageId, ')
          ..write('isPinned: $isPinned')
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
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _mediaUrlMeta = const VerificationMeta(
    'mediaUrl',
  );
  @override
  late final GeneratedColumn<String> mediaUrl = GeneratedColumn<String>(
    'media_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _thumbnailUrlMeta = const VerificationMeta(
    'thumbnailUrl',
  );
  @override
  late final GeneratedColumn<String> thumbnailUrl = GeneratedColumn<String>(
    'thumbnail_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _actionsMeta = const VerificationMeta(
    'actions',
  );
  @override
  late final GeneratedColumn<String> actions = GeneratedColumn<String>(
    'actions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _detailUrlMeta = const VerificationMeta(
    'detailUrl',
  );
  @override
  late final GeneratedColumn<String> detailUrl = GeneratedColumn<String>(
    'detail_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _soundMeta = const VerificationMeta('sound');
  @override
  late final GeneratedColumn<String> sound = GeneratedColumn<String>(
    'sound',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
    'is_read',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_read" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isClientSentMeta = const VerificationMeta(
    'isClientSent',
  );
  @override
  late final GeneratedColumn<bool> isClientSent = GeneratedColumn<bool>(
    'is_client_sent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_client_sent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sendStatusMeta = const VerificationMeta(
    'sendStatus',
  );
  @override
  late final GeneratedColumn<int> sendStatus = GeneratedColumn<int>(
    'send_status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    groupId,
    content,
    title,
    mediaType,
    mediaUrl,
    thumbnailUrl,
    actions,
    detailUrl,
    sound,
    createdAt,
    isRead,
    isClientSent,
    sendStatus,
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
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    }
    if (data.containsKey('media_url')) {
      context.handle(
        _mediaUrlMeta,
        mediaUrl.isAcceptableOrUnknown(data['media_url']!, _mediaUrlMeta),
      );
    }
    if (data.containsKey('thumbnail_url')) {
      context.handle(
        _thumbnailUrlMeta,
        thumbnailUrl.isAcceptableOrUnknown(
          data['thumbnail_url']!,
          _thumbnailUrlMeta,
        ),
      );
    }
    if (data.containsKey('actions')) {
      context.handle(
        _actionsMeta,
        actions.isAcceptableOrUnknown(data['actions']!, _actionsMeta),
      );
    }
    if (data.containsKey('detail_url')) {
      context.handle(
        _detailUrlMeta,
        detailUrl.isAcceptableOrUnknown(data['detail_url']!, _detailUrlMeta),
      );
    }
    if (data.containsKey('sound')) {
      context.handle(
        _soundMeta,
        sound.isAcceptableOrUnknown(data['sound']!, _soundMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_read')) {
      context.handle(
        _isReadMeta,
        isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta),
      );
    }
    if (data.containsKey('is_client_sent')) {
      context.handle(
        _isClientSentMeta,
        isClientSent.isAcceptableOrUnknown(
          data['is_client_sent']!,
          _isClientSentMeta,
        ),
      );
    }
    if (data.containsKey('send_status')) {
      context.handle(
        _sendStatusMeta,
        sendStatus.isAcceptableOrUnknown(data['send_status']!, _sendStatusMeta),
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
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      mediaUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_url'],
      )!,
      thumbnailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_url'],
      )!,
      actions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actions'],
      )!,
      detailUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detail_url'],
      )!,
      sound: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sound'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isRead: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_read'],
      )!,
      isClientSent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_client_sent'],
      )!,
      sendStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}send_status'],
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
  final String groupId;
  final String content;
  final String title;
  final String mediaType;
  final String mediaUrl;
  final String thumbnailUrl;
  final String actions;
  final String detailUrl;
  final String sound;
  final DateTime createdAt;
  final bool isRead;
  final bool isClientSent;
  final int sendStatus;
  const Message({
    required this.id,
    required this.groupId,
    required this.content,
    required this.title,
    required this.mediaType,
    required this.mediaUrl,
    required this.thumbnailUrl,
    required this.actions,
    required this.detailUrl,
    required this.sound,
    required this.createdAt,
    required this.isRead,
    required this.isClientSent,
    required this.sendStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['content'] = Variable<String>(content);
    map['title'] = Variable<String>(title);
    map['media_type'] = Variable<String>(mediaType);
    map['media_url'] = Variable<String>(mediaUrl);
    map['thumbnail_url'] = Variable<String>(thumbnailUrl);
    map['actions'] = Variable<String>(actions);
    map['detail_url'] = Variable<String>(detailUrl);
    map['sound'] = Variable<String>(sound);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_read'] = Variable<bool>(isRead);
    map['is_client_sent'] = Variable<bool>(isClientSent);
    map['send_status'] = Variable<int>(sendStatus);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      groupId: Value(groupId),
      content: Value(content),
      title: Value(title),
      mediaType: Value(mediaType),
      mediaUrl: Value(mediaUrl),
      thumbnailUrl: Value(thumbnailUrl),
      actions: Value(actions),
      detailUrl: Value(detailUrl),
      sound: Value(sound),
      createdAt: Value(createdAt),
      isRead: Value(isRead),
      isClientSent: Value(isClientSent),
      sendStatus: Value(sendStatus),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      content: serializer.fromJson<String>(json['content']),
      title: serializer.fromJson<String>(json['title']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      mediaUrl: serializer.fromJson<String>(json['mediaUrl']),
      thumbnailUrl: serializer.fromJson<String>(json['thumbnailUrl']),
      actions: serializer.fromJson<String>(json['actions']),
      detailUrl: serializer.fromJson<String>(json['detailUrl']),
      sound: serializer.fromJson<String>(json['sound']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      isClientSent: serializer.fromJson<bool>(json['isClientSent']),
      sendStatus: serializer.fromJson<int>(json['sendStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'content': serializer.toJson<String>(content),
      'title': serializer.toJson<String>(title),
      'mediaType': serializer.toJson<String>(mediaType),
      'mediaUrl': serializer.toJson<String>(mediaUrl),
      'thumbnailUrl': serializer.toJson<String>(thumbnailUrl),
      'actions': serializer.toJson<String>(actions),
      'detailUrl': serializer.toJson<String>(detailUrl),
      'sound': serializer.toJson<String>(sound),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isRead': serializer.toJson<bool>(isRead),
      'isClientSent': serializer.toJson<bool>(isClientSent),
      'sendStatus': serializer.toJson<int>(sendStatus),
    };
  }

  Message copyWith({
    String? id,
    String? groupId,
    String? content,
    String? title,
    String? mediaType,
    String? mediaUrl,
    String? thumbnailUrl,
    String? actions,
    String? detailUrl,
    String? sound,
    DateTime? createdAt,
    bool? isRead,
    bool? isClientSent,
    int? sendStatus,
  }) => Message(
    id: id ?? this.id,
    groupId: groupId ?? this.groupId,
    content: content ?? this.content,
    title: title ?? this.title,
    mediaType: mediaType ?? this.mediaType,
    mediaUrl: mediaUrl ?? this.mediaUrl,
    thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
    actions: actions ?? this.actions,
    detailUrl: detailUrl ?? this.detailUrl,
    sound: sound ?? this.sound,
    createdAt: createdAt ?? this.createdAt,
    isRead: isRead ?? this.isRead,
    isClientSent: isClientSent ?? this.isClientSent,
    sendStatus: sendStatus ?? this.sendStatus,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      content: data.content.present ? data.content.value : this.content,
      title: data.title.present ? data.title.value : this.title,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      mediaUrl: data.mediaUrl.present ? data.mediaUrl.value : this.mediaUrl,
      thumbnailUrl: data.thumbnailUrl.present
          ? data.thumbnailUrl.value
          : this.thumbnailUrl,
      actions: data.actions.present ? data.actions.value : this.actions,
      detailUrl: data.detailUrl.present ? data.detailUrl.value : this.detailUrl,
      sound: data.sound.present ? data.sound.value : this.sound,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      isClientSent: data.isClientSent.present
          ? data.isClientSent.value
          : this.isClientSent,
      sendStatus: data.sendStatus.present
          ? data.sendStatus.value
          : this.sendStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('content: $content, ')
          ..write('title: $title, ')
          ..write('mediaType: $mediaType, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('actions: $actions, ')
          ..write('detailUrl: $detailUrl, ')
          ..write('sound: $sound, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead, ')
          ..write('isClientSent: $isClientSent, ')
          ..write('sendStatus: $sendStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    groupId,
    content,
    title,
    mediaType,
    mediaUrl,
    thumbnailUrl,
    actions,
    detailUrl,
    sound,
    createdAt,
    isRead,
    isClientSent,
    sendStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.content == this.content &&
          other.title == this.title &&
          other.mediaType == this.mediaType &&
          other.mediaUrl == this.mediaUrl &&
          other.thumbnailUrl == this.thumbnailUrl &&
          other.actions == this.actions &&
          other.detailUrl == this.detailUrl &&
          other.sound == this.sound &&
          other.createdAt == this.createdAt &&
          other.isRead == this.isRead &&
          other.isClientSent == this.isClientSent &&
          other.sendStatus == this.sendStatus);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> content;
  final Value<String> title;
  final Value<String> mediaType;
  final Value<String> mediaUrl;
  final Value<String> thumbnailUrl;
  final Value<String> actions;
  final Value<String> detailUrl;
  final Value<String> sound;
  final Value<DateTime> createdAt;
  final Value<bool> isRead;
  final Value<bool> isClientSent;
  final Value<int> sendStatus;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.content = const Value.absent(),
    this.title = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.actions = const Value.absent(),
    this.detailUrl = const Value.absent(),
    this.sound = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isClientSent = const Value.absent(),
    this.sendStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    this.groupId = const Value.absent(),
    this.content = const Value.absent(),
    this.title = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.mediaUrl = const Value.absent(),
    this.thumbnailUrl = const Value.absent(),
    this.actions = const Value.absent(),
    this.detailUrl = const Value.absent(),
    this.sound = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isRead = const Value.absent(),
    this.isClientSent = const Value.absent(),
    this.sendStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? content,
    Expression<String>? title,
    Expression<String>? mediaType,
    Expression<String>? mediaUrl,
    Expression<String>? thumbnailUrl,
    Expression<String>? actions,
    Expression<String>? detailUrl,
    Expression<String>? sound,
    Expression<DateTime>? createdAt,
    Expression<bool>? isRead,
    Expression<bool>? isClientSent,
    Expression<int>? sendStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (content != null) 'content': content,
      if (title != null) 'title': title,
      if (mediaType != null) 'media_type': mediaType,
      if (mediaUrl != null) 'media_url': mediaUrl,
      if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      if (actions != null) 'actions': actions,
      if (detailUrl != null) 'detail_url': detailUrl,
      if (sound != null) 'sound': sound,
      if (createdAt != null) 'created_at': createdAt,
      if (isRead != null) 'is_read': isRead,
      if (isClientSent != null) 'is_client_sent': isClientSent,
      if (sendStatus != null) 'send_status': sendStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? groupId,
    Value<String>? content,
    Value<String>? title,
    Value<String>? mediaType,
    Value<String>? mediaUrl,
    Value<String>? thumbnailUrl,
    Value<String>? actions,
    Value<String>? detailUrl,
    Value<String>? sound,
    Value<DateTime>? createdAt,
    Value<bool>? isRead,
    Value<bool>? isClientSent,
    Value<int>? sendStatus,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      content: content ?? this.content,
      title: title ?? this.title,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      actions: actions ?? this.actions,
      detailUrl: detailUrl ?? this.detailUrl,
      sound: sound ?? this.sound,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      isClientSent: isClientSent ?? this.isClientSent,
      sendStatus: sendStatus ?? this.sendStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (mediaUrl.present) {
      map['media_url'] = Variable<String>(mediaUrl.value);
    }
    if (thumbnailUrl.present) {
      map['thumbnail_url'] = Variable<String>(thumbnailUrl.value);
    }
    if (actions.present) {
      map['actions'] = Variable<String>(actions.value);
    }
    if (detailUrl.present) {
      map['detail_url'] = Variable<String>(detailUrl.value);
    }
    if (sound.present) {
      map['sound'] = Variable<String>(sound.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (isClientSent.present) {
      map['is_client_sent'] = Variable<bool>(isClientSent.value);
    }
    if (sendStatus.present) {
      map['send_status'] = Variable<int>(sendStatus.value);
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
          ..write('groupId: $groupId, ')
          ..write('content: $content, ')
          ..write('title: $title, ')
          ..write('mediaType: $mediaType, ')
          ..write('mediaUrl: $mediaUrl, ')
          ..write('thumbnailUrl: $thumbnailUrl, ')
          ..write('actions: $actions, ')
          ..write('detailUrl: $detailUrl, ')
          ..write('sound: $sound, ')
          ..write('createdAt: $createdAt, ')
          ..write('isRead: $isRead, ')
          ..write('isClientSent: $isClientSent, ')
          ..write('sendStatus: $sendStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GroupsTable extends Groups with TableInfo<$GroupsTable, Group> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _iconUrlMeta = const VerificationMeta(
    'iconUrl',
  );
  @override
  late final GeneratedColumn<String> iconUrl = GeneratedColumn<String>(
    'icon_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _replyWebhookMeta = const VerificationMeta(
    'replyWebhook',
  );
  @override
  late final GeneratedColumn<String> replyWebhook = GeneratedColumn<String>(
    'reply_callback',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _actionsMeta = const VerificationMeta(
    'actions',
  );
  @override
  late final GeneratedColumn<String> actions = GeneratedColumn<String>(
    'actions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _lastMessageAtMeta = const VerificationMeta(
    'lastMessageAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastMessageAt =
      GeneratedColumn<DateTime>(
        'last_message_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconUrl,
    replyWebhook,
    actions,
    lastMessageAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(
    Insertable<Group> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('icon_url')) {
      context.handle(
        _iconUrlMeta,
        iconUrl.isAcceptableOrUnknown(data['icon_url']!, _iconUrlMeta),
      );
    }
    if (data.containsKey('reply_callback')) {
      context.handle(
        _replyWebhookMeta,
        replyWebhook.isAcceptableOrUnknown(
          data['reply_callback']!,
          _replyWebhookMeta,
        ),
      );
    }
    if (data.containsKey('actions')) {
      context.handle(
        _actionsMeta,
        actions.isAcceptableOrUnknown(data['actions']!, _actionsMeta),
      );
    }
    if (data.containsKey('last_message_at')) {
      context.handle(
        _lastMessageAtMeta,
        lastMessageAt.isAcceptableOrUnknown(
          data['last_message_at']!,
          _lastMessageAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Group map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Group(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_url'],
      )!,
      replyWebhook: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reply_callback'],
      )!,
      actions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actions'],
      )!,
      lastMessageAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_message_at'],
      ),
    );
  }

  @override
  $GroupsTable createAlias(String alias) {
    return $GroupsTable(attachedDatabase, alias);
  }
}

class Group extends DataClass implements Insertable<Group> {
  final String id;
  final String name;
  final String iconUrl;
  final String replyWebhook;
  final String actions;
  final DateTime? lastMessageAt;
  const Group({
    required this.id,
    required this.name,
    required this.iconUrl,
    required this.replyWebhook,
    required this.actions,
    this.lastMessageAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon_url'] = Variable<String>(iconUrl);
    map['reply_callback'] = Variable<String>(replyWebhook);
    map['actions'] = Variable<String>(actions);
    if (!nullToAbsent || lastMessageAt != null) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt);
    }
    return map;
  }

  GroupsCompanion toCompanion(bool nullToAbsent) {
    return GroupsCompanion(
      id: Value(id),
      name: Value(name),
      iconUrl: Value(iconUrl),
      replyWebhook: Value(replyWebhook),
      actions: Value(actions),
      lastMessageAt: lastMessageAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageAt),
    );
  }

  factory Group.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Group(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconUrl: serializer.fromJson<String>(json['iconUrl']),
      replyWebhook: serializer.fromJson<String>(json['replyWebhook']),
      actions: serializer.fromJson<String>(json['actions']),
      lastMessageAt: serializer.fromJson<DateTime?>(json['lastMessageAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'iconUrl': serializer.toJson<String>(iconUrl),
      'replyWebhook': serializer.toJson<String>(replyWebhook),
      'actions': serializer.toJson<String>(actions),
      'lastMessageAt': serializer.toJson<DateTime?>(lastMessageAt),
    };
  }

  Group copyWith({
    String? id,
    String? name,
    String? iconUrl,
    String? replyWebhook,
    String? actions,
    Value<DateTime?> lastMessageAt = const Value.absent(),
  }) => Group(
    id: id ?? this.id,
    name: name ?? this.name,
    iconUrl: iconUrl ?? this.iconUrl,
    replyWebhook: replyWebhook ?? this.replyWebhook,
    actions: actions ?? this.actions,
    lastMessageAt: lastMessageAt.present
        ? lastMessageAt.value
        : this.lastMessageAt,
  );
  Group copyWithCompanion(GroupsCompanion data) {
    return Group(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconUrl: data.iconUrl.present ? data.iconUrl.value : this.iconUrl,
      replyWebhook: data.replyWebhook.present
          ? data.replyWebhook.value
          : this.replyWebhook,
      actions: data.actions.present ? data.actions.value : this.actions,
      lastMessageAt: data.lastMessageAt.present
          ? data.lastMessageAt.value
          : this.lastMessageAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Group(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('replyWebhook: $replyWebhook, ')
          ..write('actions: $actions, ')
          ..write('lastMessageAt: $lastMessageAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, iconUrl, replyWebhook, actions, lastMessageAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Group &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconUrl == this.iconUrl &&
          other.replyWebhook == this.replyWebhook &&
          other.actions == this.actions &&
          other.lastMessageAt == this.lastMessageAt);
}

class GroupsCompanion extends UpdateCompanion<Group> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> iconUrl;
  final Value<String> replyWebhook;
  final Value<String> actions;
  final Value<DateTime?> lastMessageAt;
  final Value<int> rowid;
  const GroupsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.replyWebhook = const Value.absent(),
    this.actions = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GroupsCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    this.iconUrl = const Value.absent(),
    this.replyWebhook = const Value.absent(),
    this.actions = const Value.absent(),
    this.lastMessageAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Group> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? iconUrl,
    Expression<String>? replyWebhook,
    Expression<String>? actions,
    Expression<DateTime>? lastMessageAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (replyWebhook != null) 'reply_callback': replyWebhook,
      if (actions != null) 'actions': actions,
      if (lastMessageAt != null) 'last_message_at': lastMessageAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GroupsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? iconUrl,
    Value<String>? replyWebhook,
    Value<String>? actions,
    Value<DateTime?>? lastMessageAt,
    Value<int>? rowid,
  }) {
    return GroupsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      replyWebhook: replyWebhook ?? this.replyWebhook,
      actions: actions ?? this.actions,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconUrl.present) {
      map['icon_url'] = Variable<String>(iconUrl.value);
    }
    if (replyWebhook.present) {
      map['reply_callback'] = Variable<String>(replyWebhook.value);
    }
    if (actions.present) {
      map['actions'] = Variable<String>(actions.value);
    }
    if (lastMessageAt.present) {
      map['last_message_at'] = Variable<DateTime>(lastMessageAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconUrl: $iconUrl, ')
          ..write('replyWebhook: $replyWebhook, ')
          ..write('actions: $actions, ')
          ..write('lastMessageAt: $lastMessageAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserSettingsTable extends UserSettings
    with TableInfo<$UserSettingsTable, UserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserSetting> instance, {
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
  UserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSetting(
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
  $UserSettingsTable createAlias(String alias) {
    return $UserSettingsTable(attachedDatabase, alias);
  }
}

class UserSetting extends DataClass implements Insertable<UserSetting> {
  final String key;
  final String value;
  const UserSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  UserSettingsCompanion toCompanion(bool nullToAbsent) {
    return UserSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory UserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSetting(
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

  UserSetting copyWith({String? key, String? value}) =>
      UserSetting(key: key ?? this.key, value: value ?? this.value);
  UserSetting copyWithCompanion(UserSettingsCompanion data) {
    return UserSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSetting(')
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
      (other is UserSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class UserSettingsCompanion extends UpdateCompanion<UserSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const UserSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<UserSetting> custom({
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

  UserSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return UserSettingsCompanion(
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
    return (StringBuffer('UserSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EncryptedMessagesTable extends EncryptedMessages
    with TableInfo<$EncryptedMessagesTable, EncryptedMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EncryptedMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedPayloadMeta = const VerificationMeta(
    'encryptedPayload',
  );
  @override
  late final GeneratedColumn<String> encryptedPayload = GeneratedColumn<String>(
    'encrypted_payload',
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
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastRetryAtMeta = const VerificationMeta(
    'lastRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastRetryAt = GeneratedColumn<DateTime>(
    'last_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  @override
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    encryptedPayload,
    receivedAt,
    retryCount,
    lastRetryAt,
    errorMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'encrypted_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<EncryptedMessage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('encrypted_payload')) {
      context.handle(
        _encryptedPayloadMeta,
        encryptedPayload.isAcceptableOrUnknown(
          data['encrypted_payload']!,
          _encryptedPayloadMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedPayloadMeta);
    }
    if (data.containsKey('received_at')) {
      context.handle(
        _receivedAtMeta,
        receivedAt.isAcceptableOrUnknown(data['received_at']!, _receivedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_receivedAtMeta);
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_retry_at')) {
      context.handle(
        _lastRetryAtMeta,
        lastRetryAt.isAcceptableOrUnknown(
          data['last_retry_at']!,
          _lastRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EncryptedMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EncryptedMessage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      encryptedPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}encrypted_payload'],
      )!,
      receivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}received_at'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_retry_at'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      )!,
    );
  }

  @override
  $EncryptedMessagesTable createAlias(String alias) {
    return $EncryptedMessagesTable(attachedDatabase, alias);
  }
}

class EncryptedMessage extends DataClass
    implements Insertable<EncryptedMessage> {
  final String id;
  final String encryptedPayload;
  final DateTime receivedAt;
  final int retryCount;
  final DateTime? lastRetryAt;
  final String errorMessage;
  const EncryptedMessage({
    required this.id,
    required this.encryptedPayload,
    required this.receivedAt,
    required this.retryCount,
    this.lastRetryAt,
    required this.errorMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['encrypted_payload'] = Variable<String>(encryptedPayload);
    map['received_at'] = Variable<DateTime>(receivedAt);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastRetryAt != null) {
      map['last_retry_at'] = Variable<DateTime>(lastRetryAt);
    }
    map['error_message'] = Variable<String>(errorMessage);
    return map;
  }

  EncryptedMessagesCompanion toCompanion(bool nullToAbsent) {
    return EncryptedMessagesCompanion(
      id: Value(id),
      encryptedPayload: Value(encryptedPayload),
      receivedAt: Value(receivedAt),
      retryCount: Value(retryCount),
      lastRetryAt: lastRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRetryAt),
      errorMessage: Value(errorMessage),
    );
  }

  factory EncryptedMessage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EncryptedMessage(
      id: serializer.fromJson<String>(json['id']),
      encryptedPayload: serializer.fromJson<String>(json['encryptedPayload']),
      receivedAt: serializer.fromJson<DateTime>(json['receivedAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastRetryAt: serializer.fromJson<DateTime?>(json['lastRetryAt']),
      errorMessage: serializer.fromJson<String>(json['errorMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'encryptedPayload': serializer.toJson<String>(encryptedPayload),
      'receivedAt': serializer.toJson<DateTime>(receivedAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastRetryAt': serializer.toJson<DateTime?>(lastRetryAt),
      'errorMessage': serializer.toJson<String>(errorMessage),
    };
  }

  EncryptedMessage copyWith({
    String? id,
    String? encryptedPayload,
    DateTime? receivedAt,
    int? retryCount,
    Value<DateTime?> lastRetryAt = const Value.absent(),
    String? errorMessage,
  }) => EncryptedMessage(
    id: id ?? this.id,
    encryptedPayload: encryptedPayload ?? this.encryptedPayload,
    receivedAt: receivedAt ?? this.receivedAt,
    retryCount: retryCount ?? this.retryCount,
    lastRetryAt: lastRetryAt.present ? lastRetryAt.value : this.lastRetryAt,
    errorMessage: errorMessage ?? this.errorMessage,
  );
  EncryptedMessage copyWithCompanion(EncryptedMessagesCompanion data) {
    return EncryptedMessage(
      id: data.id.present ? data.id.value : this.id,
      encryptedPayload: data.encryptedPayload.present
          ? data.encryptedPayload.value
          : this.encryptedPayload,
      receivedAt: data.receivedAt.present
          ? data.receivedAt.value
          : this.receivedAt,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastRetryAt: data.lastRetryAt.present
          ? data.lastRetryAt.value
          : this.lastRetryAt,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EncryptedMessage(')
          ..write('id: $id, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastRetryAt: $lastRetryAt, ')
          ..write('errorMessage: $errorMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    encryptedPayload,
    receivedAt,
    retryCount,
    lastRetryAt,
    errorMessage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EncryptedMessage &&
          other.id == this.id &&
          other.encryptedPayload == this.encryptedPayload &&
          other.receivedAt == this.receivedAt &&
          other.retryCount == this.retryCount &&
          other.lastRetryAt == this.lastRetryAt &&
          other.errorMessage == this.errorMessage);
}

class EncryptedMessagesCompanion extends UpdateCompanion<EncryptedMessage> {
  final Value<String> id;
  final Value<String> encryptedPayload;
  final Value<DateTime> receivedAt;
  final Value<int> retryCount;
  final Value<DateTime?> lastRetryAt;
  final Value<String> errorMessage;
  final Value<int> rowid;
  const EncryptedMessagesCompanion({
    this.id = const Value.absent(),
    this.encryptedPayload = const Value.absent(),
    this.receivedAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastRetryAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EncryptedMessagesCompanion.insert({
    required String id,
    required String encryptedPayload,
    required DateTime receivedAt,
    this.retryCount = const Value.absent(),
    this.lastRetryAt = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       encryptedPayload = Value(encryptedPayload),
       receivedAt = Value(receivedAt);
  static Insertable<EncryptedMessage> custom({
    Expression<String>? id,
    Expression<String>? encryptedPayload,
    Expression<DateTime>? receivedAt,
    Expression<int>? retryCount,
    Expression<DateTime>? lastRetryAt,
    Expression<String>? errorMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (encryptedPayload != null) 'encrypted_payload': encryptedPayload,
      if (receivedAt != null) 'received_at': receivedAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastRetryAt != null) 'last_retry_at': lastRetryAt,
      if (errorMessage != null) 'error_message': errorMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EncryptedMessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? encryptedPayload,
    Value<DateTime>? receivedAt,
    Value<int>? retryCount,
    Value<DateTime?>? lastRetryAt,
    Value<String>? errorMessage,
    Value<int>? rowid,
  }) {
    return EncryptedMessagesCompanion(
      id: id ?? this.id,
      encryptedPayload: encryptedPayload ?? this.encryptedPayload,
      receivedAt: receivedAt ?? this.receivedAt,
      retryCount: retryCount ?? this.retryCount,
      lastRetryAt: lastRetryAt ?? this.lastRetryAt,
      errorMessage: errorMessage ?? this.errorMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (encryptedPayload.present) {
      map['encrypted_payload'] = Variable<String>(encryptedPayload.value);
    }
    if (receivedAt.present) {
      map['received_at'] = Variable<DateTime>(receivedAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastRetryAt.present) {
      map['last_retry_at'] = Variable<DateTime>(lastRetryAt.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EncryptedMessagesCompanion(')
          ..write('id: $id, ')
          ..write('encryptedPayload: $encryptedPayload, ')
          ..write('receivedAt: $receivedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastRetryAt: $lastRetryAt, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $GroupsTable groups = $GroupsTable(this);
  late final $UserSettingsTable userSettings = $UserSettingsTable(this);
  late final $EncryptedMessagesTable encryptedMessages =
      $EncryptedMessagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    conversations,
    messages,
    groups,
    userSettings,
    encryptedMessages,
  ];
}

typedef $$ConversationsTableCreateCompanionBuilder =
    ConversationsCompanion Function({
      Value<int> id,
      Value<int> type,
      Value<String> groupId,
      Value<String> messageId,
      Value<bool> isPinned,
    });
typedef $$ConversationsTableUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<int> id,
      Value<int> type,
      Value<String> groupId,
      Value<String> messageId,
      Value<bool> isPinned,
    });

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
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

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
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

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);
}

class $$ConversationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConversationsTable,
          Conversation,
          $$ConversationsTableFilterComposer,
          $$ConversationsTableOrderingComposer,
          $$ConversationsTableAnnotationComposer,
          $$ConversationsTableCreateCompanionBuilder,
          $$ConversationsTableUpdateCompanionBuilder,
          (
            Conversation,
            BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>,
          ),
          Conversation,
          PrefetchHooks Function()
        > {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
              }) => ConversationsCompanion(
                id: id,
                type: type,
                groupId: groupId,
                messageId: messageId,
                isPinned: isPinned,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<String> groupId = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
              }) => ConversationsCompanion.insert(
                id: id,
                type: type,
                groupId: groupId,
                messageId: messageId,
                isPinned: isPinned,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConversationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConversationsTable,
      Conversation,
      $$ConversationsTableFilterComposer,
      $$ConversationsTableOrderingComposer,
      $$ConversationsTableAnnotationComposer,
      $$ConversationsTableCreateCompanionBuilder,
      $$ConversationsTableUpdateCompanionBuilder,
      (
        Conversation,
        BaseReferences<_$AppDatabase, $ConversationsTable, Conversation>,
      ),
      Conversation,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      Value<String> groupId,
      Value<String> content,
      Value<String> title,
      Value<String> mediaType,
      Value<String> mediaUrl,
      Value<String> thumbnailUrl,
      Value<String> actions,
      Value<String> detailUrl,
      Value<String> sound,
      Value<DateTime> createdAt,
      Value<bool> isRead,
      Value<bool> isClientSent,
      Value<int> sendStatus,
      Value<int> rowid,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> groupId,
      Value<String> content,
      Value<String> title,
      Value<String> mediaType,
      Value<String> mediaUrl,
      Value<String> thumbnailUrl,
      Value<String> actions,
      Value<String> detailUrl,
      Value<String> sound,
      Value<DateTime> createdAt,
      Value<bool> isRead,
      Value<bool> isClientSent,
      Value<int> sendStatus,
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

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaUrl => $composableBuilder(
    column: $table.mediaUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actions => $composableBuilder(
    column: $table.actions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detailUrl => $composableBuilder(
    column: $table.detailUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isClientSent => $composableBuilder(
    column: $table.isClientSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sendStatus => $composableBuilder(
    column: $table.sendStatus,
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

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaUrl => $composableBuilder(
    column: $table.mediaUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actions => $composableBuilder(
    column: $table.actions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detailUrl => $composableBuilder(
    column: $table.detailUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sound => $composableBuilder(
    column: $table.sound,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isRead => $composableBuilder(
    column: $table.isRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isClientSent => $composableBuilder(
    column: $table.isClientSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sendStatus => $composableBuilder(
    column: $table.sendStatus,
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

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get mediaUrl =>
      $composableBuilder(column: $table.mediaUrl, builder: (column) => column);

  GeneratedColumn<String> get thumbnailUrl => $composableBuilder(
    column: $table.thumbnailUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actions =>
      $composableBuilder(column: $table.actions, builder: (column) => column);

  GeneratedColumn<String> get detailUrl =>
      $composableBuilder(column: $table.detailUrl, builder: (column) => column);

  GeneratedColumn<String> get sound =>
      $composableBuilder(column: $table.sound, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<bool> get isClientSent => $composableBuilder(
    column: $table.isClientSent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sendStatus => $composableBuilder(
    column: $table.sendStatus,
    builder: (column) => column,
  );
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
                Value<String> groupId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> mediaUrl = const Value.absent(),
                Value<String> thumbnailUrl = const Value.absent(),
                Value<String> actions = const Value.absent(),
                Value<String> detailUrl = const Value.absent(),
                Value<String> sound = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isClientSent = const Value.absent(),
                Value<int> sendStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                groupId: groupId,
                content: content,
                title: title,
                mediaType: mediaType,
                mediaUrl: mediaUrl,
                thumbnailUrl: thumbnailUrl,
                actions: actions,
                detailUrl: detailUrl,
                sound: sound,
                createdAt: createdAt,
                isRead: isRead,
                isClientSent: isClientSent,
                sendStatus: sendStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> groupId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> mediaUrl = const Value.absent(),
                Value<String> thumbnailUrl = const Value.absent(),
                Value<String> actions = const Value.absent(),
                Value<String> detailUrl = const Value.absent(),
                Value<String> sound = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isRead = const Value.absent(),
                Value<bool> isClientSent = const Value.absent(),
                Value<int> sendStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                groupId: groupId,
                content: content,
                title: title,
                mediaType: mediaType,
                mediaUrl: mediaUrl,
                thumbnailUrl: thumbnailUrl,
                actions: actions,
                detailUrl: detailUrl,
                sound: sound,
                createdAt: createdAt,
                isRead: isRead,
                isClientSent: isClientSent,
                sendStatus: sendStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
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
typedef $$GroupsTableCreateCompanionBuilder =
    GroupsCompanion Function({
      required String id,
      Value<String> name,
      Value<String> iconUrl,
      Value<String> replyWebhook,
      Value<String> actions,
      Value<DateTime?> lastMessageAt,
      Value<int> rowid,
    });
typedef $$GroupsTableUpdateCompanionBuilder =
    GroupsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> iconUrl,
      Value<String> replyWebhook,
      Value<String> actions,
      Value<DateTime?> lastMessageAt,
      Value<int> rowid,
    });

class $$GroupsTableFilterComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconUrl => $composableBuilder(
    column: $table.iconUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get replyWebhook => $composableBuilder(
    column: $table.replyWebhook,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actions => $composableBuilder(
    column: $table.actions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GroupsTableOrderingComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconUrl => $composableBuilder(
    column: $table.iconUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get replyWebhook => $composableBuilder(
    column: $table.replyWebhook,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actions => $composableBuilder(
    column: $table.actions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GroupsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GroupsTable> {
  $$GroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconUrl =>
      $composableBuilder(column: $table.iconUrl, builder: (column) => column);

  GeneratedColumn<String> get replyWebhook => $composableBuilder(
    column: $table.replyWebhook,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actions =>
      $composableBuilder(column: $table.actions, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMessageAt => $composableBuilder(
    column: $table.lastMessageAt,
    builder: (column) => column,
  );
}

class $$GroupsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GroupsTable,
          Group,
          $$GroupsTableFilterComposer,
          $$GroupsTableOrderingComposer,
          $$GroupsTableAnnotationComposer,
          $$GroupsTableCreateCompanionBuilder,
          $$GroupsTableUpdateCompanionBuilder,
          (Group, BaseReferences<_$AppDatabase, $GroupsTable, Group>),
          Group,
          PrefetchHooks Function()
        > {
  $$GroupsTableTableManager(_$AppDatabase db, $GroupsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconUrl = const Value.absent(),
                Value<String> replyWebhook = const Value.absent(),
                Value<String> actions = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion(
                id: id,
                name: name,
                iconUrl: iconUrl,
                replyWebhook: replyWebhook,
                actions: actions,
                lastMessageAt: lastMessageAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> name = const Value.absent(),
                Value<String> iconUrl = const Value.absent(),
                Value<String> replyWebhook = const Value.absent(),
                Value<String> actions = const Value.absent(),
                Value<DateTime?> lastMessageAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GroupsCompanion.insert(
                id: id,
                name: name,
                iconUrl: iconUrl,
                replyWebhook: replyWebhook,
                actions: actions,
                lastMessageAt: lastMessageAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GroupsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GroupsTable,
      Group,
      $$GroupsTableFilterComposer,
      $$GroupsTableOrderingComposer,
      $$GroupsTableAnnotationComposer,
      $$GroupsTableCreateCompanionBuilder,
      $$GroupsTableUpdateCompanionBuilder,
      (Group, BaseReferences<_$AppDatabase, $GroupsTable, Group>),
      Group,
      PrefetchHooks Function()
    >;
typedef $$UserSettingsTableCreateCompanionBuilder =
    UserSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$UserSettingsTableUpdateCompanionBuilder =
    UserSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$UserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableFilterComposer({
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

class $$UserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableOrderingComposer({
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

class $$UserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSettingsTable> {
  $$UserSettingsTableAnnotationComposer({
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

class $$UserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserSettingsTable,
          UserSetting,
          $$UserSettingsTableFilterComposer,
          $$UserSettingsTableOrderingComposer,
          $$UserSettingsTableAnnotationComposer,
          $$UserSettingsTableCreateCompanionBuilder,
          $$UserSettingsTableUpdateCompanionBuilder,
          (
            UserSetting,
            BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
          ),
          UserSetting,
          PrefetchHooks Function()
        > {
  $$UserSettingsTableTableManager(_$AppDatabase db, $UserSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => UserSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserSettingsTable,
      UserSetting,
      $$UserSettingsTableFilterComposer,
      $$UserSettingsTableOrderingComposer,
      $$UserSettingsTableAnnotationComposer,
      $$UserSettingsTableCreateCompanionBuilder,
      $$UserSettingsTableUpdateCompanionBuilder,
      (
        UserSetting,
        BaseReferences<_$AppDatabase, $UserSettingsTable, UserSetting>,
      ),
      UserSetting,
      PrefetchHooks Function()
    >;
typedef $$EncryptedMessagesTableCreateCompanionBuilder =
    EncryptedMessagesCompanion Function({
      required String id,
      required String encryptedPayload,
      required DateTime receivedAt,
      Value<int> retryCount,
      Value<DateTime?> lastRetryAt,
      Value<String> errorMessage,
      Value<int> rowid,
    });
typedef $$EncryptedMessagesTableUpdateCompanionBuilder =
    EncryptedMessagesCompanion Function({
      Value<String> id,
      Value<String> encryptedPayload,
      Value<DateTime> receivedAt,
      Value<int> retryCount,
      Value<DateTime?> lastRetryAt,
      Value<String> errorMessage,
      Value<int> rowid,
    });

class $$EncryptedMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $EncryptedMessagesTable> {
  $$EncryptedMessagesTableFilterComposer({
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

  ColumnFilters<String> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRetryAt => $composableBuilder(
    column: $table.lastRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EncryptedMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $EncryptedMessagesTable> {
  $$EncryptedMessagesTableOrderingComposer({
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

  ColumnOrderings<String> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRetryAt => $composableBuilder(
    column: $table.lastRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EncryptedMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EncryptedMessagesTable> {
  $$EncryptedMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get encryptedPayload => $composableBuilder(
    column: $table.encryptedPayload,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get receivedAt => $composableBuilder(
    column: $table.receivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastRetryAt => $composableBuilder(
    column: $table.lastRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );
}

class $$EncryptedMessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EncryptedMessagesTable,
          EncryptedMessage,
          $$EncryptedMessagesTableFilterComposer,
          $$EncryptedMessagesTableOrderingComposer,
          $$EncryptedMessagesTableAnnotationComposer,
          $$EncryptedMessagesTableCreateCompanionBuilder,
          $$EncryptedMessagesTableUpdateCompanionBuilder,
          (
            EncryptedMessage,
            BaseReferences<
              _$AppDatabase,
              $EncryptedMessagesTable,
              EncryptedMessage
            >,
          ),
          EncryptedMessage,
          PrefetchHooks Function()
        > {
  $$EncryptedMessagesTableTableManager(
    _$AppDatabase db,
    $EncryptedMessagesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EncryptedMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EncryptedMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EncryptedMessagesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> encryptedPayload = const Value.absent(),
                Value<DateTime> receivedAt = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastRetryAt = const Value.absent(),
                Value<String> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EncryptedMessagesCompanion(
                id: id,
                encryptedPayload: encryptedPayload,
                receivedAt: receivedAt,
                retryCount: retryCount,
                lastRetryAt: lastRetryAt,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String encryptedPayload,
                required DateTime receivedAt,
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastRetryAt = const Value.absent(),
                Value<String> errorMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EncryptedMessagesCompanion.insert(
                id: id,
                encryptedPayload: encryptedPayload,
                receivedAt: receivedAt,
                retryCount: retryCount,
                lastRetryAt: lastRetryAt,
                errorMessage: errorMessage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EncryptedMessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EncryptedMessagesTable,
      EncryptedMessage,
      $$EncryptedMessagesTableFilterComposer,
      $$EncryptedMessagesTableOrderingComposer,
      $$EncryptedMessagesTableAnnotationComposer,
      $$EncryptedMessagesTableCreateCompanionBuilder,
      $$EncryptedMessagesTableUpdateCompanionBuilder,
      (
        EncryptedMessage,
        BaseReferences<
          _$AppDatabase,
          $EncryptedMessagesTable,
          EncryptedMessage
        >,
      ),
      EncryptedMessage,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$GroupsTableTableManager get groups =>
      $$GroupsTableTableManager(_db, _db.groups);
  $$UserSettingsTableTableManager get userSettings =>
      $$UserSettingsTableTableManager(_db, _db.userSettings);
  $$EncryptedMessagesTableTableManager get encryptedMessages =>
      $$EncryptedMessagesTableTableManager(_db, _db.encryptedMessages);
}
