import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:app/db/database.dart';
import 'package:app/db/database_provider.dart';
import 'package:app/shared/encryption_service.dart';
import 'package:app/features/push/push_models.dart';
import 'package:app/features/push/push_parser.dart';
import 'package:app/features/push/push_repository.dart';

final encryptedMessageRetryServiceProvider = Provider((ref) {
  final db = ref.watch(databaseProvider);
  final encryptionService = ref.watch(encryptionServiceProvider);
  return EncryptedMessageRetryService(db, encryptionService);
});

/// 加密消息重试结果
class RetryResult {
  final int total;
  final int success;
  final int failed;
  final List<String> errors;

  RetryResult({
    required this.total,
    required this.success,
    required this.failed,
    this.errors = const [],
  });

  @override
  String toString() => 'RetryResult(total: $total, success: $success, failed: $failed)';
}

/// 加密消息重试服务
/// 负责重试解密失败的消息，解密成功后入库并发送本地通知
class EncryptedMessageRetryService {
  final AppDatabase _db;
  final EncryptionService _encryptionService;
  late final PushRepository _repo;

  bool _isRetrying = false;

  EncryptedMessageRetryService(
    this._db,
    this._encryptionService,
  ) : _repo = PushRepository(_db);

  /// 是否正在重试
  bool get isRetrying => _isRetrying;

  /// 重试所有待解密的消息
  Future<RetryResult> retryAll() async {
    if (_isRetrying) {
      debugPrint('Retry already in progress, skipping...');
      return RetryResult(total: 0, success: 0, failed: 0);
    }

    _isRetrying = true;
    debugPrint('Starting retry of all encrypted messages...');

    try {
      final pendingMessages = await _db.getPendingEncryptedMessages();
      if (pendingMessages.isEmpty) {
        debugPrint('No pending encrypted messages to retry');
        return RetryResult(total: 0, success: 0, failed: 0);
      }

      int success = 0;
      int failed = 0;
      List<String> errors = [];

      for (final msg in pendingMessages) {
        final result = await retrySingle(msg.id);
        if (result) {
          success++;
        } else {
          failed++;
          errors.add('Message ${msg.id} failed');
        }
      }

      debugPrint('Retry completed: success=$success, failed=$failed');
      return RetryResult(
        total: pendingMessages.length,
        success: success,
        failed: failed,
        errors: errors,
      );
    } finally {
      _isRetrying = false;
    }
  }

  /// 重试单条消息
  /// 返回 true 表示成功，false 表示失败
  Future<bool> retrySingle(String id) async {
    try {
      // 获取加密消息
      final query = _db.select(_db.encryptedMessages)
        ..where((t) => t.id.equals(id));
      final encryptedMsg = await query.getSingleOrNull();

      if (encryptedMsg == null) {
        debugPrint('Encrypted message not found: $id');
        return false;
      }

      // 尝试解密
      final decrypted = await _encryptionService.decryptMessage(
        encryptedMsg.encryptedPayload,
      );

      if (decrypted == null) {
        // 解密失败，更新重试信息
        await _db.updateEncryptedMessageRetry(id, 'Decryption returned null');
        debugPrint('Decryption failed for message: $id');
        return false;
      }

      // 解密成功，解析并保存
      await _processDecryptedMessage(
        id: id,
        decryptedJson: decrypted,
        receivedAt: encryptedMsg.receivedAt,
      );

      // 删除加密记录
      await _db.deleteEncryptedMessage(id);
      debugPrint('Successfully decrypted and saved message: $id');
      return true;
    } catch (e) {
      // 解密出错，更新重试信息
      await _db.updateEncryptedMessageRetry(id, e.toString());
      debugPrint('Error retrying message $id: $e');
      return false;
    }
  }

  /// 处理解密后的消息
  Future<void> _processDecryptedMessage({
    required String id,
    required String decryptedJson,
    required DateTime receivedAt,
  }) async {
    final parsed = tryParseDecryptedJson(decryptedJson, {});
    if (parsed == null) {
      await _db.deleteEncryptedMessage(id);
      return;
    }

    if (parsed.priority == MessagePriority.silent) {
      // 静默消息：只更新群组配置
      if (parsed.groupId.isNotEmpty && parsed.groupConfig != null) {
        await _repo.updateGroupConfig(parsed.groupId, parsed.groupConfig!);
    }
      // 静默消息不保存，删除加密记录后返回
      return;
    }

    // 注意：PushRepository.saveMessage 使用 DateTime.now()，但我们需要使用 receivedAt
    // 所以先保存消息，然后更新创建时间
    await _repo.saveMessage(id, parsed);
    
    // 更新消息的创建时间为实际接收时间
    await (_db.update(_db.messages)..where((t) => t.id.equals(id)))
        .write(MessagesCompanion(createdAt: Value(receivedAt)));

  }
}

