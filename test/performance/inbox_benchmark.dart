// Inbox 加载性能基准测试
// 
// 用于验证 N+1 查询优化的效果
// 
// 运行方式：flutter test test/performance/conversationList_benchmark.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:app/db/database.dart';

void main() {
  group('Inbox Loading Performance', () {
    late AppDatabase db;

    setUp(() async {
      // 创建内存数据库
      db = AppDatabase(NativeDatabase.memory());
      
      // 创建测试数据
      await _seedTestData(db, groupCount: 100);
    });

    tearDown(() async {
      await db.close();
    });

    test('Load 100 groups with last messages', () async {
      final stopwatch = Stopwatch()..start();
      
      // 这里需要调用实际的 conversationlist provider 查询逻辑
      // 当前只是占位符，需要在实现 T012-T014 后更新
      final groups = await db.select(db.groups).get();
      
      stopwatch.stop();
      
      // ignore: avoid_print
      print('Loaded ${groups.length} groups in ${stopwatch.elapsedMilliseconds}ms');
      
      // 性能目标：<100ms for 100 groups
      expect(stopwatch.elapsedMilliseconds, lessThan(100),
          reason: 'Inbox loading should be under 100ms for 100 groups');
    });

    test('Load 500 groups with last messages', () async {
      // 重新填充更多数据
      await db.delete(db.groups).go();
      await db.delete(db.messages).go();
      await _seedTestData(db, groupCount: 500);
      
      final stopwatch = Stopwatch()..start();
      
      final groups = await db.select(db.groups).get();
      
      stopwatch.stop();
      
      // ignore: avoid_print
      print('Loaded ${groups.length} groups in ${stopwatch.elapsedMilliseconds}ms');
      
      // 性能目标：<300ms for 500 groups
      expect(stopwatch.elapsedMilliseconds, lessThan(300),
          reason: 'Inbox loading should scale well with 500 groups');
    });
  });
}

/// 填充测试数据
Future<void> _seedTestData(AppDatabase db, {required int groupCount}) async {
  for (int i = 0; i < groupCount; i++) {
    final groupId = 'group-$i';

    // 创建群组
    await db.into(db.groups).insert(
      GroupsCompanion.insert(
        id: groupId,
        name: Value('Test Group $i'),
        iconUrl: const Value(''),
        replyWebhook: const Value(''),
        actions: const Value(''),
      ),
    );

    // 为每个群组创建几条消息
    for (int j = 0; j < 5; j++) {
      await db.into(db.messages).insert(
        MessagesCompanion.insert(
          id: 'msg-$i-$j',
          groupId: Value(groupId),
          content: Value('Test message body $j for group $i'),
          title: const Value(''),
          mediaType: const Value(''),
          mediaUrl: const Value(''),
          thumbnailUrl: const Value(''),
          actions: const Value(''),
          detailUrl: const Value(''),
          sound: const Value(''),
          createdAt: Value(DateTime.now().subtract(Duration(hours: j))),
        ),
      );
    }
  }
}
