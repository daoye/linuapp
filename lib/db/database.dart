import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Conversations Table (Conversation List)
@DataClassName('Conversation')
class Conversations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get type => integer().withDefault(const Constant(0))(); // 0=Group, 1=Single
  TextColumn get groupId => text().withDefault(const Constant(''))();
  TextColumn get messageId => text().withDefault(const Constant(''))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
}

@DataClassName('Message')
class Messages extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get mediaType => text().withDefault(const Constant(''))();
  TextColumn get mediaUrl => text().withDefault(const Constant(''))();
  TextColumn get thumbnailUrl => text().withDefault(const Constant(''))();
  TextColumn get actions => text().withDefault(const Constant(''))();
  TextColumn get detailUrl => text().withDefault(const Constant(''))();
  TextColumn get sound => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isClientSent => boolean().withDefault(const Constant(false))();
  // 发送状态：0=成功/已发送, 1=发送中, 2=发送失败
  IntColumn get sendStatus => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Group')
class Groups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withDefault(const Constant(''))();
  TextColumn get iconUrl => text().withDefault(const Constant(''))();
  TextColumn get replyWebhook => text().withDefault(const Constant(''))();
  TextColumn get actions => text().withDefault(const Constant(''))();
  // 最后一条消息的时间，用于在 conversation list 中排序
  // 即使消息被删除，此字段也不会改变，避免排序跳跃
  DateTimeColumn get lastMessageAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

class EncryptedMessages extends Table {
  TextColumn get id => text()();
  TextColumn get encryptedPayload => text()();
  DateTimeColumn get receivedAt => dateTime()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastRetryAt => dateTime().nullable()();
  TextColumn get errorMessage => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Conversations, Messages, Groups, UserSettings, EncryptedMessages])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? db]) : super(db ?? _openConnection());

  @override
  int get schemaVersion => 1;

  Future<List<Message>> get allMessages => select(messages).get();

  Stream<List<Message>> watchAllMessages() => select(messages).watch();

  Future<List<Group>> get allGroups => select(groups).get();

  Stream<List<Group>> watchAllGroups() => select(groups).watch();

  Future<String?> getSetting(String key) async {
    final query = select(userSettings)..where((tbl) => tbl.key.equals(key));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(userSettings).insertOnConflictUpdate(
      UserSetting(key: key, value: value),
    );
  }

  // ============================================================
  // Encrypted Messages 辅助方法
  // ============================================================

  /// 获取所有待重试的加密消息
  Future<List<EncryptedMessage>> getPendingEncryptedMessages() async {
    return (select(encryptedMessages)
          ..orderBy([(t) => OrderingTerm.asc(t.receivedAt)]))
        .get();
  }

  /// 监听待解密消息数量
  Stream<int> watchPendingEncryptedMessagesCount() {
    return (selectOnly(encryptedMessages)..addColumns([encryptedMessages.id.count()]))
        .watchSingle()
        .map((row) => row.read(encryptedMessages.id.count()) ?? 0);
  }

  /// 更新重试信息
  Future<void> updateEncryptedMessageRetry(String id, String errorMsg) async {
    // 先获取当前的重试次数
    final current = await (select(encryptedMessages)..where((t) => t.id.equals(id))).getSingleOrNull();
    final newRetryCount = (current?.retryCount ?? 0) + 1;

    await (update(encryptedMessages)..where((t) => t.id.equals(id))).write(
      EncryptedMessagesCompanion(
        retryCount: Value(newRetryCount),
        lastRetryAt: Value(DateTime.now()),
        errorMessage: Value(errorMsg),
      ),
    );
  }

  /// 删除已成功解密的消息
  Future<void> deleteEncryptedMessage(String id) async {
    await (delete(encryptedMessages)..where((t) => t.id.equals(id))).go();
  }

  /// 删除所有已解密的消息
  Future<void> deleteAllEncryptedMessages() async {
    await delete(encryptedMessages).go();
  }

  /// 标记某个 group 的所有消息为已读
  Future<void> markGroupMessagesAsRead(String groupId) async {
    await (update(messages)..where((t) => t.groupId.equals(groupId))).write(
      const MessagesCompanion(isRead: Value(true)),
    );
  }

  /// 获取会话列表（Conversation List）
  /// 通过 JOIN Messages 和 Groups 获取显示信息
  /// 排序规则：
  /// - 置顶的在最前面
  /// - Group 会话使用 g.last_message_at 排序（即使消息被删除也不会跳跃）
  /// - 单条消息使用 m.created_at 排序
  Future<List<ConversationListItem>> getConversationList() async {
    final query = customSelect(
      '''
      SELECT
        c.id as conversation_id,
        c.type as conversation_type,
        c.group_id,
        c.message_id,
        c.is_pinned,
        m.id as message_id,
        m.content as message_content,
        m.title as message_title,
        m.media_type,
        m.media_url,
        m.thumbnail_url,
        m.actions as message_actions,
        m.detail_url,
        m.sound,
        m.created_at,
        m.is_read,
        m.is_client_sent,
        m.send_status,
        g.id as group_id,
        g.name as group_name,
        g.icon_url,
        g.reply_callback,
        g.actions as group_actions,
        g.last_message_at as group_last_message_at
      FROM conversations c
      LEFT JOIN messages m ON m.id = c.message_id
      LEFT JOIN groups g ON g.id = c.group_id
      ORDER BY
        c.is_pinned DESC,
        COALESCE(g.last_message_at, m.created_at) DESC
      ''',
      readsFrom: {conversations, messages, groups},
    );

    final result = await query.get();
    return result.map((row) {
      final groupId = row.readNullable<String>('group_id') ?? '';
      final messageId = row.readNullable<String>('message_id') ?? '';

      return ConversationListItem(
        conversation: Conversation(
          id: row.read<int>('conversation_id'),
          type: row.read<int>('conversation_type'),
          groupId: groupId,
          messageId: messageId,
          isPinned: row.read<bool>('is_pinned'),
        ),
        message: messageId.isNotEmpty
            ? Message(
                id: messageId,
                groupId: groupId,
                content: row.readNullable<String>('message_content') ?? '',
                title: row.readNullable<String>('message_title') ?? '',
                mediaType: row.readNullable<String>('media_type') ?? '',
                mediaUrl: row.readNullable<String>('media_url') ?? '',
                thumbnailUrl: row.readNullable<String>('thumbnail_url') ?? '',
                actions: row.readNullable<String>('message_actions') ?? '',
                detailUrl: row.readNullable<String>('detail_url') ?? '',
                sound: row.readNullable<String>('sound') ?? '',
                createdAt: row.read<DateTime>('created_at'),
                isRead: row.read<bool>('is_read'),
                isClientSent: row.read<bool>('is_client_sent'),
                sendStatus: row.readNullable<int>('send_status') ?? 0,
              )
            : null,
        group: groupId.isNotEmpty
            ? Group(
                id: groupId,
                name: row.readNullable<String>('group_name') ?? '',
                iconUrl: row.readNullable<String>('icon_url') ?? '',
                replyWebhook: row.readNullable<String>('reply_callback') ?? '',
                actions: row.readNullable<String>('group_actions') ?? '',
                lastMessageAt: row.readNullable<DateTime>('group_last_message_at'),
              )
            : null,
      );
    }).toList();
  }

  /// 响应式查询会话列表
  Stream<List<ConversationListItem>> watchConversationList() {
    final query = customSelect(
      '''
      SELECT
        c.id as conversation_id,
        c.type as conversation_type,
        c.group_id,
        c.message_id,
        c.is_pinned,
        m.id as message_id,
        m.content as message_content,
        m.title as message_title,
        m.media_type,
        m.media_url,
        m.thumbnail_url,
        m.actions as message_actions,
        m.detail_url,
        m.sound,
        m.created_at,
        m.is_read,
        m.is_client_sent,
        m.send_status,
        g.id as group_id,
        g.name as group_name,
        g.icon_url,
        g.reply_webhook,
        g.actions as group_actions,
        g.last_message_at as group_last_message_at
      FROM conversations c
      LEFT JOIN messages m ON m.id = c.message_id
      LEFT JOIN groups g ON g.id = c.group_id
      ORDER BY
        c.is_pinned DESC,
        COALESCE(g.last_message_at, m.created_at) DESC
      ''',
      readsFrom: {conversations, messages, groups},
    );

    return query.watch().map((rows) {
      return rows.map((row) {
        final groupId = row.readNullable<String>('group_id') ?? '';
        final messageId = row.readNullable<String>('message_id') ?? '';

        return ConversationListItem(
          conversation: Conversation(
            id: row.read<int>('conversation_id'),
            type: row.read<int>('conversation_type'),
            groupId: groupId,
            messageId: messageId,
            isPinned: row.read<bool>('is_pinned'),
          ),
          message: messageId.isNotEmpty
              ? Message(
                  id: messageId,
                  groupId: groupId,
                  content: row.readNullable<String>('message_content') ?? '',
                  title: row.readNullable<String>('message_title') ?? '',
                  mediaType: row.readNullable<String>('media_type') ?? '',
                  mediaUrl: row.readNullable<String>('media_url') ?? '',
                  thumbnailUrl: row.readNullable<String>('thumbnail_url') ?? '',
                  actions: row.readNullable<String>('message_actions') ?? '',
                  detailUrl: row.readNullable<String>('detail_url') ?? '',
                  sound: row.readNullable<String>('sound') ?? '',
                  createdAt: row.read<DateTime>('created_at'),
                  isRead: row.read<bool>('is_read'),
                  isClientSent: row.read<bool>('is_client_sent'),
                  sendStatus: row.readNullable<int>('send_status') ?? 0,
                )
              : null,
          group: groupId.isNotEmpty
              ? Group(
                  id: groupId,
                  name: row.readNullable<String>('group_name') ?? '',
                  iconUrl: row.readNullable<String>('icon_url') ?? '',
                  replyWebhook: row.readNullable<String>('reply_webhook') ?? '',
                  actions: row.readNullable<String>('group_actions') ?? '',
                  lastMessageAt: row.readNullable<DateTime>('group_last_message_at'),
                )
              : null,
        );
      }).toList();
    });
  }
}

/// 辅助类：Conversation List Item (Conversation + Message + Group)
class ConversationListItem {
  final Conversation conversation;
  final Message? message;
  final Group? group;

  ConversationListItem({
    required this.conversation,
    this.message,
    this.group,
  });
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'linu.db'));
    return NativeDatabase(file);
  });
}
