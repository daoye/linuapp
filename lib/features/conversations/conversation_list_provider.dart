import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:app/db/database.dart';
import 'package:app/db/database_provider.dart';

final conversationListProvider = StreamProvider<List<ConversationListItem>>((ref) {
  final db = ref.watch(databaseProvider);

  // 直接使用数据库的响应式查询
  // Drift 会自动监听相关表的变化并触发更新
  return db.watchConversationList();
});

Future<void> togglePin(WidgetRef ref, int conversationId) async {
  final db = ref.read(databaseProvider);
  final conversation = await (db.select(db.conversations)
        ..where((t) => t.id.equals(conversationId)))
      .getSingle();

  await (db.update(db.conversations)
        ..where((t) => t.id.equals(conversationId)))
      .write(ConversationsCompanion(isPinned: Value(!conversation.isPinned)));
}

final visibleConversationItemsProvider = Provider<List<ConversationListItem>>((ref) {
  final conversationListAsync = ref.watch(conversationListProvider);

  return conversationListAsync.when(
    data: (items) => items,
    loading: () => [],
    error: (err, stack) => [],
  );
});

final messagesInGroupProvider = StreamProvider.family<List<Message>, String>((ref, groupId) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.messages)
        ..where((t) => t.groupId.equals(groupId))
        ..orderBy([
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]))
      .watch();
});
