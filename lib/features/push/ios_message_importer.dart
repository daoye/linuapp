import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:app/app.dart';
import 'package:app/db/database.dart';
import 'package:app/db/database_provider.dart';
import 'package:app/shared/encryption_service.dart';
import 'package:app/features/push/push_models.dart';
import 'package:app/features/push/push_pipeline.dart';
import 'package:app/features/push/push_repository.dart';
import 'package:app/shared/services/message_highlight_service.dart';

/// iOS 消息导入服务
/// 
/// 从 App Group (UserDefaults) 导入 LinuNotificationService Extension 保存的消息
final iosMessageImporterProvider = Provider((ref) => IosMessageImporter(ref));

class IosMessageImporter {
  final Ref ref;
  static const _channel = MethodChannel('com.aprilzz.linu/messages');
  static const _appGroupId = 'group.com.aprilzz.linu';
  static const _pendingMessagesKey = 'pending_messages';
  static bool _listenerRegistered = false;

  IosMessageImporter(this.ref) {
    // 注册 MethodChannel 监听器，接收来自 AppDelegate 的导入触发
    if (!_listenerRegistered && Platform.isIOS) {
      _channel.setMethodCallHandler(_handleMethodCall);
      _listenerRegistered = true;
    }
  }

  PushRepository get _repo => PushRepository(ref.read(databaseProvider));

  PushMessagePipeline _getPipeline() {
    final db = ref.read(databaseProvider);
    final encryptionService = ref.read(encryptionServiceProvider);
    return PushMessagePipeline(
      repo: _repo,
      decrypt: encryptionService.decryptMessage,
      saveEncryptedForRetry: (messageId, payload, err) async {
        await db.into(db.encryptedMessages).insertOnConflictUpdate(
          EncryptedMessagesCompanion.insert(
            id: messageId,
            encryptedPayload: payload,
            receivedAt: DateTime.now(),
            retryCount: const Value(0),
            lastRetryAt: const Value(null),
            errorMessage: Value(err),
          ),
        );
      },
    );
  }

  /// 处理来自 AppDelegate 的方法调用
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'importPendingMessages') {
      await importPendingMessages();
      return true;
    } else if (call.method == 'handleNotificationTap') {
      final data = call.arguments as Map<dynamic, dynamic>?;
      final messageId = data?['id'] as String?;
      if (messageId != null) {
        await _handleNotificationTap(messageId);
      }
      return true;
    }
    return null;
  }
  
  /// 处理通知点击，执行导航和高亮
  /// 
  /// 流程：
  /// 1. 先返回首页
  /// 2. 导入待处理消息（确保消息已入库）
  /// 3. 从数据库查询消息的 groupId
  /// 4. 根据 groupId 决定导航到 GroupConversation 还是在 ConversationList 高亮
  Future<void> _handleNotificationTap(String messageId) async {
    final router = ref.read(routerProvider);
    
    // 先返回首页
    router.go('/conversationlist');
    
    // 导入待处理消息，确保目标消息已入库
    await importPendingMessages();
    
    // 从数据库查询消息的 groupId
    final db = ref.read(databaseProvider);
    final message = await (db.select(db.messages)
      ..where((t) => t.id.equals(messageId))).getSingleOrNull();
    final groupId = message?.groupId;
    
    if (groupId != null && groupId.isNotEmpty) {
      router.push(
        '/conversationlist/${Uri.encodeComponent(groupId)}?messageId=${Uri.encodeComponent(messageId)}',
      );
    } else {
      // 无 groupId，在 ConversationList 高亮
      MessageHighlightService.instance.requestHighlight(messageId: messageId);
    }
  }

  /// 导入所有待处理消息
  Future<int> importPendingMessages() async {
    if (!Platform.isIOS) return 0;

    try {
      final messages = await _getPendingMessages();
      if (messages.isEmpty) return 0;

      debugPrint('IosMessageImporter: Found ${messages.length} pending messages');

      int imported = 0;
      final importedIds = <String>[];

      for (final msg in messages) {
        final id = msg['id'] as String?;
        if (id == null) continue;

        try {
          final success = await _importMessage(id, msg);
          if (success) {
            imported++;
            importedIds.add(id);
          }
        } catch (e) {
          debugPrint('IosMessageImporter: Failed to import $id: $e');
        }
      }

      // 清除已导入的消息
      if (importedIds.isNotEmpty) {
        await _removePendingMessages(importedIds);
      }

      debugPrint('IosMessageImporter: Imported $imported messages');
      return imported;
    } catch (e) {
      debugPrint('IosMessageImporter: Error: $e');
      return 0;
    }
  }

  /// 获取待处理消息列表
  Future<List<Map<String, dynamic>>> _getPendingMessages() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getPendingMessages', {
        'groupId': _appGroupId,
        'key': _pendingMessagesKey,
      });

      if (result == null) return [];

      return result
          .whereType<Map>()
          .map((m) {
            // 安全地转换 Map<Object?, Object?> 到 Map<String, dynamic>
            // UserDefaults 返回的是 Map<Object?, Object?>，需要手动转换
            final converted = <String, dynamic>{};
            for (final entry in m.entries) {
              final key = entry.key?.toString();
              if (key != null && key.isNotEmpty) {
                converted[key] = entry.value;
              }
            }
            return converted;
          })
          .toList();
    } catch (e) {
      debugPrint('IosMessageImporter: getPendingMessages error: $e');
      return [];
    }
  }

  /// 清除已导入的消息
  Future<void> _removePendingMessages(List<String> ids) async {
    try {
      await _channel.invokeMethod('removePendingMessages', {
        'groupId': _appGroupId,
        'key': _pendingMessagesKey,
        'ids': ids,
      });
    } catch (e) {
      debugPrint('IosMessageImporter: removePendingMessages error: $e');
    }
  }

  /// 导入单条消息
  Future<bool> _importMessage(String id, Map<String, dynamic> msg) async {
    if (msg.containsKey('z') || msg.containsKey('x')) {
      final result = await _getPipeline().process(
        id,
        msg,
      );
      return result is PipelineSuccess || result is PipelineSilentHandled;
    }

    // NSE 已解密并写入的格式（无 z/x，含 title/text 等）
    final parsed = ParsedMessage.fromJson(msg);
    if (!validateGroupId(parsed.groupId)) return false;
    parsed.fillFromMessageData(msg);
    await _repo.saveMessage(id, parsed);
    return true;
  }
}
