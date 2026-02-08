import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app/db/database.dart';
import 'package:app/features/push/push_models.dart';
import 'package:app/features/push/push_pipeline.dart';
import 'package:app/features/push/push_repository.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/shared/notification_channel_util.dart';

/// Android 后台消息处理入口
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {
  final messageId = message.messageId;
  final data = message.data;

  if (messageId == null) return;
  if (!data.containsKey('z') && !data.containsKey('x')) return;

  final db = await _getDatabase();
  final repo = PushRepository(db);
  final pipeline = PushMessagePipeline(
    repo: repo,
    decrypt: _decrypt,
    saveEncryptedForRetry: _saveEncryptedMessageForRetry,
  );

  final result = await pipeline.process(messageId, data);

  await _handlePipelineResult(result, messageId);
  await _markMessageProcessed();
}

Future<void> _handlePipelineResult(
  PipelineResult result,
  String messageId,
) async {
  switch (result) {
    case PipelineSuccess(:final parsed):
      await _showNotification(parsed, messageId: messageId);
      if (parsed.needRingingAlert) {
        await _saveRingingParameters(parsed);
      }
    case PipelineDecryptionFailed():
      await _showDefaultNotification();
    case PipelineParseFailed():
    case PipelineSilentHandled():
      break;
  }
}

Future<void> _saveRingingParameters(ParsedMessage parsed) async {
  if (!Platform.isAndroid) return;

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'pending_ringing',
      jsonEncode({
        'title': parsed.title.isNotEmpty ? parsed.title : '来电',
        'body': parsed.text.isNotEmpty ? parsed.text : '新消息',
        'sound': parsed.sound.isNotEmpty ? parsed.sound : '',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      }),
    );
  } catch (e) {
    debugPrint('Failed to save ringing parameters: $e');
  }
}

Future<void> _markMessageProcessed() async {
  if (!Platform.isAndroid) return;

  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'message_processed',
      jsonEncode({'timestamp': DateTime.now().millisecondsSinceEpoch}),
    );
  } catch (e) {
    debugPrint('Failed to set message processed marker: $e');
  }
}

Future<void> _showDefaultNotification() async {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final l10n = lookupAppLocalizations(locale);

  final defaultMsg = ParsedMessage()
    ..title = ''
    ..text = l10n.encryptedMessageNotificationBody
    ..groupId = '';

  await _showNotification(defaultMsg);
}

Future<void> _showNotification(ParsedMessage msg, {String? messageId}) async {
  final plugin = await _getNotificationPlugin();
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final l10n = lookupAppLocalizations(locale);

  String? localImagePath;
  final imageUrl = msg.imageUrl;
  if (imageUrl != null && imageUrl.isNotEmpty) {
    localImagePath = await _downloadFile(imageUrl, 'jpg');
  }

  final channelId = msg.sound.isNotEmpty
      ? notificationChannelIdForSound(msg.sound)
      : 'default';

  StyleInformation? styleInfo;
  AndroidBitmap<Object>? largeIcon;

  if (localImagePath != null) {
    final bitmap = FilePathAndroidBitmap(localImagePath);
    styleInfo = BigPictureStyleInformation(
      bitmap,
      contentTitle: msg.title,
      summaryText: msg.text,
      hideExpandedLargeIcon: true,
    );
    largeIcon = bitmap;
  } else if (msg.text.length > 50) {
    styleInfo = BigTextStyleInformation(msg.text);
  }

  await plugin.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    msg.title,
    msg.text,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        l10n.defaultNotification,
        channelDescription: l10n.pushNotificationChannel,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: styleInfo,
        largeIcon: largeIcon,
        playSound: true,
      ),
    ),
    payload: jsonEncode({'id': messageId}),
  );
}

Future<void> _saveEncryptedMessageForRetry(
  String messageId,
  String encryptedPayload,
  String errorMessage,
) async {
  try {
    final db = await _getDatabase();
    await db.into(db.encryptedMessages).insertOnConflictUpdate(
          EncryptedMessagesCompanion.insert(
            id: messageId,
            encryptedPayload: encryptedPayload,
            receivedAt: DateTime.now(),
            retryCount: const Value(0),
            lastRetryAt: const Value(null),
            errorMessage: Value(errorMessage),
          ),
        );
  } catch (dbError) {
    debugPrint('Failed to save encrypted message: $dbError');
  }
}

Future<String?> _decrypt(String encryptedBase64) async {
  try {
    const storage = FlutterSecureStorage(aOptions: AndroidOptions());

    final keyBase64 = await storage.read(key: 'e2ee_aes_key');
    if (keyBase64 == null) return null;

    final keyBytes = base64Decode(keyBase64);
    final encryptedData = base64Decode(encryptedBase64);
    if (encryptedData.length < 28) return null;

    final nonce = encryptedData.sublist(0, 12);
    final ciphertextWithTag = encryptedData.sublist(12);

    final secretBox = SecretBox(
      ciphertextWithTag.sublist(0, ciphertextWithTag.length - 16),
      nonce: nonce,
      mac: Mac(ciphertextWithTag.sublist(ciphertextWithTag.length - 16)),
    );

    final decrypted = await AesGcm.with256bits().decrypt(
      secretBox,
      secretKey: SecretKey(keyBytes),
    );

    return utf8.decode(decrypted);
  } catch (e) {
    debugPrint('Decryption failed: $e');
    return null;
  }
}

FlutterLocalNotificationsPlugin? _notificationPlugin;

Future<FlutterLocalNotificationsPlugin> _getNotificationPlugin() async {
  if (_notificationPlugin != null) return _notificationPlugin!;

  _notificationPlugin = FlutterLocalNotificationsPlugin();
  await _notificationPlugin!.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  if (Platform.isAndroid) {
    await _createDefaultNotificationChannel();
  }

  return _notificationPlugin!;
}

Future<void> _createDefaultNotificationChannel() async {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  final l10n = lookupAppLocalizations(locale);

  final androidChannel = AndroidNotificationChannel(
    'default',
    l10n.defaultNotification,
    description: l10n.pushNotificationChannel,
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  await _notificationPlugin!
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(androidChannel);
}

AppDatabase? _backgroundDb;

Future<AppDatabase> _getDatabase() async {
  if (_backgroundDb != null) return _backgroundDb!;

  final dbFolder = await getApplicationDocumentsDirectory();
  final file = File(p.join(dbFolder.path, 'linu.db'));
  _backgroundDb = AppDatabase(NativeDatabase(file));

  return _backgroundDb!;
}

Future<String?> _downloadFile(String url, String ext) async {
  try {
    final request = await HttpClient().getUrl(Uri.parse(url));
    final response = await request.close();

    if (response.statusCode == 200) {
      final bytes = await consolidateHttpClientResponseBytes(response);
      final fileName = 'notif_${DateTime.now().millisecondsSinceEpoch}.$ext';
      final file = File('${Directory.systemTemp.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    }
  } catch (e) {
    debugPrint('Download failed: $e');
  }

  return null;
}
