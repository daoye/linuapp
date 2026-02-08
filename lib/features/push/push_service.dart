import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:app/db/database.dart';
import 'package:app/db/database_provider.dart';
import 'package:app/app.dart';
import 'package:app/features/settings/settings_provider.dart';
import 'package:app/shared/encryption_service.dart';
import 'package:app/shared/local_notification_service.dart';
import 'package:app/features/push/android_background_handler.dart';
import 'package:app/features/push/ios_message_importer.dart';
import 'package:app/features/push/push_models.dart';
import 'package:app/features/push/push_pipeline.dart';
import 'package:app/features/push/push_repository.dart';
import 'package:app/l10n/app_localizations.dart';

// ============================================================
// PushService
// ============================================================

final pushServiceProvider = Provider((ref) => PushService(ref));

class PushService {
  final Ref ref;
  static const _ringingChannel = MethodChannel('com.aprilzz.linu/ringtone');

  PushService(this.ref);

  PushRepository get _repo => PushRepository(ref.read(databaseProvider));

  PushMessagePipeline _getPipeline() {
    final db = ref.read(databaseProvider);
    final encryptionService = ref.read(encryptionServiceProvider);
    return PushMessagePipeline(
      repo: _repo,
      decrypt: encryptionService.decryptMessage,
      saveEncryptedForRetry: (id, payload, err) async {
        await db
            .into(db.encryptedMessages)
            .insertOnConflictUpdate(
              EncryptedMessagesCompanion.insert(
                id: id,
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

  Future<void> initialize() async {
    try {
      await Firebase.initializeApp();

      // iOS: 导入 LinuNotificationService Extension 保存的待处理消息
      if (Platform.isIOS) {
        final importer = ref.read(iosMessageImporterProvider);
        await importer.importPendingMessages();
      }

      // 注册后台处理器
      FirebaseMessaging.onBackgroundMessage(firebaseBackgroundHandler);

      // 请求权限
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await FirebaseMessaging.instance
            .setForegroundNotificationPresentationOptions(
              alert: true,
              badge: true,
              sound: true,
            );

        // 获取设备令牌
        await _fetchAndSaveToken();

        // 监听 token 刷新事件
        FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
          debugPrint('Token refreshed: $newToken');
          await ref.read(settingsProvider.notifier).setDeviceToken(newToken);
        });
      }

      // 前台消息
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 用户点击通知打开应用
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        _handleMessageOpenedApp(message);
      });

      // 应用从终止状态启动
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        await _handleMessageOpenedApp(initialMessage);
      }
    } catch (e) {
      debugPrint('Firebase initialization failed: $e');
    }
  }

  /// 获取并保存设备令牌
  ///
  /// 对于 iOS/macOS，优先获取 APNs token（用于自建服务器直接推送）。
  /// APNs token 可能需要一些时间才能获取，因此添加重试逻辑。
  Future<void> _fetchAndSaveToken() async {
    String? token;

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      token = await FirebaseMessaging.instance.getAPNSToken();
      debugPrint('APNs Token: $token');
    } else {
      token = await FirebaseMessaging.instance.getToken();
      debugPrint('FCM Token: $token');
    }

    if (token != null && token.isNotEmpty) {
      await ref.read(settingsProvider.notifier).setDeviceToken(token);
    }
  }


  /// 处理前台消息
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final data = message.data;
    final messageId = message.messageId ?? '';
    if (!data.containsKey('z') && !data.containsKey('x')) return;
    if (messageId.isEmpty) return;

    final result = await _getPipeline().process(
      messageId,
      data,
    );

    switch (result) {
      case PipelineSuccess(:final parsed):
        await _showNotificationFromParsed(parsed, messageId);
        if (parsed.needRingingAlert && Platform.isAndroid) {
          await _startRingingService(parsed);
        }
      case PipelineDecryptionFailed():
        await _showDefaultNotification(messageId);
      case PipelineParseFailed():
      case PipelineSilentHandled():
        break;
    }
  }

  Future<void> _startRingingService(ParsedMessage parsed) async {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final l10n = lookupAppLocalizations(locale);
      await _ringingChannel.invokeMethod('startRinging', {
        'title': parsed.title.isNotEmpty ? parsed.title : l10n.ringingDefaultTitle,
        'body': parsed.text.isNotEmpty ? parsed.text : l10n.ringingDefaultBody,
        'sound': parsed.sound.isNotEmpty ? parsed.sound : '',
      });
    } catch (e) {
      debugPrint('Failed to start ringing service: $e');
    }
  }

  /// 根据 ParsedMessage 显示前台通知
  Future<void> _showNotificationFromParsed(
    ParsedMessage parsed,
    String messageId,
  ) async {
    final localNotificationService = ref.read(localNotificationServiceProvider);
    await localNotificationService.initialize();

    final title = parsed.title;
    final body = parsed.text;
    final imageUrl = parsed.imageUrl;
    final groupId = parsed.groupId.isNotEmpty ? parsed.groupId : null;

    if (title.isEmpty && body.isEmpty) return;

    final payload = jsonEncode({
      'id': messageId,
    });

    await localNotificationService.showMessage(
      id: messageId.hashCode,
      title: title,
      body: body,
      imageUrl: imageUrl,
      payload: payload,
      groupId: groupId,
    );
  }

  /// 解密失败时展示默认文案
  Future<void> _showDefaultNotification(
    String messageId,
  ) async {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final l10n = lookupAppLocalizations(locale);
    final defaultMsg = ParsedMessage()
      ..title = ''
      ..text = l10n.encryptedMessageNotificationBody
      ..groupId = '';
    await _showNotificationFromParsed(defaultMsg, messageId);
  }

  /// 处理用户点击通知
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    if (Platform.isIOS) {
      final importer = ref.read(iosMessageImporterProvider);
      await importer.importPendingMessages();
    }

    final id = message.messageId;

    if (id == null) {
      return;
    }

    final msg = await _repo.getMessageById(id);
    if (msg == null) {
      return;
    }

    String? groupId = msg.groupId;

    final router = ref.read(routerProvider);

   if (groupId.isNotEmpty) {
      router.push(
        '/conversationlist/${Uri.encodeComponent(groupId)}?messageId=${Uri.encodeComponent(id)}',
      );
    } else {
      router.push('/conversationlist?messageId=${Uri.encodeComponent(id)}');
    }
  }


}
