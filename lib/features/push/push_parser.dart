import 'dart:convert';
import 'package:app/features/push/push_models.dart';

/// 从 FCM data 中解析明文消息（x 字段）
ParsedMessage? tryParsePlaintextFromData(Map<String, dynamic> data) {
  final xRaw = data['x'];
  if (xRaw is! String || xRaw.isEmpty) return null;
  final parsed = ParsedMessage.fromXArray(xRaw);
  if (parsed == null) return null;
  if (!validateGroupId(parsed.groupId)) return null;
  parsed.fillFromMessageData(data);
  return parsed;
}

/// 从解密后的 JSON 字符串解析消息，并做 groupId 校验与加密元数据填充
ParsedMessage? tryParseDecryptedJson(String decryptedJson, Map<String, dynamic> data) {
  try {
    final json = jsonDecode(decryptedJson) as Map<String, dynamic>;
    final parsed = ParsedMessage.fromJson(json);
    if (!validateGroupId(parsed.groupId)) return null;
    parsed.fillEncryptedMetadataFromData(data);
    return parsed;
  } catch (_) {
    return null;
  }
}
