import 'package:flutter/foundation.dart';
import 'package:app/features/push/push_models.dart';
import 'package:app/features/push/push_parser.dart';
import 'package:app/features/push/push_repository.dart';

/// 管线处理结果
sealed class PipelineResult {}

/// 成功入库，可展示 [parsed]
final class PipelineSuccess extends PipelineResult {
  final ParsedMessage parsed;
  PipelineSuccess(this.parsed);
}

/// 解密失败，已写入 encryptedMessages，应展示默认文案
final class PipelineDecryptionFailed extends PipelineResult {}

/// 解析失败或无效 payload
final class PipelineParseFailed extends PipelineResult {}

/// 静默消息已处理（仅更新群组配置）
final class PipelineSilentHandled extends PipelineResult {}

/// 消息处理管线：解密 → 解码 → 校验 → 静默/入库
/// 与平台无关，由各入口注入 repo、decrypt、saveEncryptedForRetry
class PushMessagePipeline {
  final PushRepository repo;
  final Future<String?> Function(String encryptedPayload) decrypt;
  final Future<void> Function(String messageId, String encryptedPayload, String errorMessage) saveEncryptedForRetry;

  PushMessagePipeline({
    required this.repo,
    required this.decrypt,
    required this.saveEncryptedForRetry,
  });

  /// 处理单条消息，返回结果供调用方决定是否/如何展示通知
  Future<PipelineResult> process(
    String messageId,
    Map<String, dynamic> data,
  ) async {
    if (data.containsKey('z')) {
      return _processEncrypted(messageId, data);
    }
    if (data.containsKey('x')) {
      return _processPlaintext(messageId, data);
    }
    return PipelineParseFailed();
  }

  Future<PipelineResult> _processEncrypted(
    String messageId,
    Map<String, dynamic> data,
  ) async {
    final encryptedPayload = data['z'] as String;
    String? decrypted;
    try {
      decrypted = await decrypt(encryptedPayload);
    } catch (e) {
      debugPrint('Encrypted message error: $e');
      await saveEncryptedForRetry(messageId, encryptedPayload, 'Decryption error: $e');
      return PipelineDecryptionFailed();
    }

    if (decrypted == null) {
      await saveEncryptedForRetry(messageId, encryptedPayload, 'Decryption failed: Unable to decrypt message');
      return PipelineDecryptionFailed();
    }

    final parsed = tryParseDecryptedJson(decrypted, data);
    if (parsed == null) {
      await saveEncryptedForRetry(messageId, encryptedPayload, 'Invalid decrypted JSON');
      return PipelineParseFailed();
    }


    if (parsed.priority == MessagePriority.silent) {
      if (parsed.groupConfig != null && parsed.groupId.isNotEmpty) {
        await repo.updateGroupConfig(parsed.groupId, parsed.groupConfig!);
      }
      return PipelineSilentHandled();
    }

    await repo.saveMessage(messageId, parsed);
    return PipelineSuccess(parsed);
  }

  Future<PipelineResult> _processPlaintext(
    String messageId,
    Map<String, dynamic> data,
  ) async {
    final parsed = tryParsePlaintextFromData(data);
    if (parsed == null) return PipelineParseFailed();

    if (parsed.priority == MessagePriority.silent) {
      if (parsed.groupConfig != null && parsed.groupId.isNotEmpty) {
        await repo.updateGroupConfig(parsed.groupId, parsed.groupConfig!);
      }
      return PipelineSilentHandled();
    }

    await repo.saveMessage(messageId, parsed);
    return PipelineSuccess(parsed);
  }
}
