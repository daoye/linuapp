import 'package:drift/drift.dart';
import 'package:app/db/database.dart';
import 'package:app/features/push/push_models.dart';

/// 推送消息数据库操作
class PushRepository {
  final AppDatabase db;

  PushRepository(this.db);

  Future<Message?> getMessageById(String id) async {
    return (db.select(db.messages)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> saveMessage(String id, ParsedMessage msg) async {
    final now = DateTime.now();

    if (msg.groupId.isNotEmpty) {
      if (msg.groupConfig != null) {
        final gc = msg.groupConfig!;
        // 先检查是否存在该 group
        final existing = await (db.select(db.groups)
              ..where((t) => t.id.equals(msg.groupId)))
            .getSingleOrNull();

        if (existing == null) {
          // 新建 group，使用所有提供的值，同时设置 lastMessageAt
          await db.into(db.groups).insert(
            GroupsCompanion.insert(
              id: msg.groupId,
              name: Value(gc.name ?? ''),
              replyWebhook: Value(gc.replyWebhook?.toJson() ?? ''),
              iconUrl: Value(gc.iconUrl ?? ''),
              actions: Value(gc.actionsJson ?? ''),
              lastMessageAt: Value(now),
            ),
          );
        } else {
          // 更新 group，只更新消息中明确包含的字段，保留已有值
          // 使用 hasXxx 标志位判断字段是否在消息中存在
          // 同时更新 lastMessageAt
          final companion = GroupsCompanion(
            id: Value(msg.groupId),
            name: gc.hasName ? Value(gc.name ?? '') : const Value.absent(),
            replyWebhook: gc.hasReplyWebhook ? Value(gc.replyWebhook?.toJson() ?? '') : const Value.absent(),
            iconUrl: gc.hasIconUrl ? Value(gc.iconUrl ?? '') : const Value.absent(),
            actions: gc.hasActions ? Value(gc.actionsJson ?? '') : const Value.absent(),
            lastMessageAt: Value(now),
          );
          await (db.update(db.groups)..where((t) => t.id.equals(msg.groupId)))
              .write(companion);
        }
      } else {
        final existing = await (db.select(db.groups)
              ..where((t) => t.id.equals(msg.groupId)))
            .getSingleOrNull();
        if (existing == null) {
          // 新建 group，同时设置 lastMessageAt
          await db.into(db.groups).insert(
            GroupsCompanion.insert(
              id: msg.groupId,
              lastMessageAt: Value(now),
            ),
          );
        } else {
          // 更新 lastMessageAt
          await (db.update(db.groups)..where((t) => t.id.equals(msg.groupId)))
              .write(GroupsCompanion(lastMessageAt: Value(now)));
        }
      }
    }

    await db.into(db.messages).insertOnConflictUpdate(
      MessagesCompanion.insert(
        id: id,
        groupId: Value(msg.groupId),
        content: Value(msg.text),
        title: Value(msg.title),
        mediaType: Value(msg.mediaType),
        mediaUrl: Value(msg.mediaUrl),
        thumbnailUrl: Value(msg.thumbnailUrl),
        actions: Value(msg.actionsJson),
        detailUrl: Value(msg.detailUrl),
        sound: Value(msg.sound),
        createdAt: Value(now),
        isRead: const Value(false),
      ),
    );

    await updateConversation(id, msg.groupId);
  }

  Future<void> updateGroupConfig(String groupId, GroupConfig groupConfig) async {
    // 先检查是否存在该 group
    final existing = await (db.select(db.groups)
          ..where((t) => t.id.equals(groupId)))
        .getSingleOrNull();

    if (existing == null) {
      // 新建 group，使用所有提供的值
      await db.into(db.groups).insert(
        GroupsCompanion.insert(
          id: groupId,
          name: Value(groupConfig.name ?? ''),
          replyWebhook: Value(groupConfig.replyWebhook?.toJson() ?? ''),
          iconUrl: Value(groupConfig.iconUrl ?? ''),
          actions: Value(groupConfig.actionsJson ?? ''),
        ),
      );
    } else {
      // 更新 group，只更新消息中明确包含的字段，保留已有值
      // 使用 hasXxx 标志位判断字段是否在消息中存在
      final companion = GroupsCompanion(
        id: Value(groupId),
        name: groupConfig.hasName ? Value(groupConfig.name ?? '') : const Value.absent(),
        replyWebhook: groupConfig.hasReplyWebhook ? Value(groupConfig.replyWebhook?.toJson() ?? '') : const Value.absent(),
        iconUrl: groupConfig.hasIconUrl ? Value(groupConfig.iconUrl ?? '') : const Value.absent(),
        actions: groupConfig.hasActions ? Value(groupConfig.actionsJson ?? '') : const Value.absent(),
      );
      await (db.update(db.groups)..where((t) => t.id.equals(groupId)))
          .write(companion);
    }
  }

  Future<void> updateConversation(String messageId, String groupId) async {
    if (groupId.isNotEmpty) {
      final existing = await (db.select(db.conversations)
            ..where((t) => t.groupId.equals(groupId)))
          .getSingleOrNull();

      if (existing != null) {
        await (db.update(db.conversations)..where((t) => t.id.equals(existing.id)))
            .write(ConversationsCompanion(messageId: Value(messageId)));
      } else {
        await db.into(db.conversations).insert(
          ConversationsCompanion.insert(
            type: const Value(0),
            groupId: Value(groupId),
            messageId: Value(messageId),
          ),
        );
      }
    } else {
      final existing = await (db.select(db.conversations)
            ..where((t) => t.messageId.equals(messageId)))
          .getSingleOrNull();

      if (existing == null) {
        await db.into(db.conversations).insert(
          ConversationsCompanion.insert(
            type: const Value(1),
            messageId: Value(messageId),
          ),
        );
      }
    }
  }
}
