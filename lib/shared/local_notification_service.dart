import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:app/app.dart';
import 'package:app/db/database_provider.dart';
import 'package:app/features/push/push_repository.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/shared/notification_channel_util.dart';
import 'package:app/shared/services/message_highlight_service.dart';

final localNotificationServiceProvider = Provider((ref) {
  return LocalNotificationService(ref);
});

/// 本地通知服务（仅 Android 使用）
/// 用于解密成功后显示真实消息内容
class LocalNotificationService {
  final Ref _ref;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  LocalNotificationService(this._ref);

  /// 初始化通知服务
  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notifications.initialize(
      const InitializationSettings(android: androidSettings),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createDefaultNotificationChannel();
    _initialized = true;
    debugPrint('LocalNotificationService initialized');
  }

  /// 创建默认通知渠道（用于后台消息）
  Future<void> _createDefaultNotificationChannel() async {
    // 获取系统语言环境
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

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// 通知点击回调

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');

    if (response.payload == null || response.payload!.isEmpty) return;

    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      final messageId = data['id'] as String?;

      if (messageId == null) return;

      final router = _ref.read(routerProvider);
      router.go('/conversationlist');

      final db = _ref.read(databaseProvider);
      final repo = PushRepository(db);
      repo.getMessageById(messageId).then((message) {
        if (message == null) {
          return;
        }
        final groupId = message.groupId;
        if (groupId.isNotEmpty) {
          router.push(
            '/conversationlist/${Uri.encodeComponent(groupId)}?messageId=${Uri.encodeComponent(messageId)}',
          );
        } else {
          MessageHighlightService.instance.requestHighlight(messageId: messageId);
        }
      });
    } catch (e) {
      debugPrint('Failed to handle notification tap: $e');
    }
  }

  /// 显示解密成功的消息通知（可选带图，统一使用 default channel）
  Future<void> showMessage({
    required int id,
    required String title,
    required String body,
    String? imageUrl,
    String? payload,
    String? groupId,
  }) async {
    if (!_initialized) await initialize();

    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final l10n = lookupAppLocalizations(locale);
    BigPictureStyleInformation? bigPicture;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        bigPicture = BigPictureStyleInformation(
          FilePathAndroidBitmap(imageUrl),
          contentTitle: title,
          summaryText: body,
        );
      } catch (e) {
        debugPrint('Failed to load image for notification: $e');
      }
    }
    final styleInformation = bigPicture ??
        (body.length > 100 ? BigTextStyleInformation(body) : null);

    final androidDetails = AndroidNotificationDetails(
      'default',
      l10n.defaultNotification,
      channelDescription: l10n.pushNotificationChannel,
      importance: Importance.high,
      priority: Priority.high,
      groupKey: groupId,
      styleInformation: styleInformation,
    );

    await _notifications.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
      payload: payload,
    );
    debugPrint('Local notification shown: $title');
  }

  /// 取消指定通知
  Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// 取消所有通知
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }

  /// 为自定义铃音创建通知 channel（Android 8+ 声音由 channel 决定）
  /// 添加音频后调用；handler 通过 sound name 使用对应 channel
  Future<void> createSoundChannel(String soundName, String filePath) async {
    if (!Platform.isAndroid || soundName.isEmpty) return;
    try {
      final contentUri = await const MethodChannel('com.aprilzz.linu/ringtone')
          .invokeMethod<String>('getSoundContentUri', {'path': filePath});
      if (contentUri == null || contentUri.isEmpty) return;
      final channelId = notificationChannelIdForSound(soundName);
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final l10n = lookupAppLocalizations(locale);
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(AndroidNotificationChannel(
        channelId,
        soundName,
        description: l10n.pushNotificationChannel,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        sound: UriAndroidNotificationSound(contentUri),
      ));
    } catch (e) {
      debugPrint('LocalNotificationService createSoundChannel failed: $e');
    }
  }

  /// 删除自定义铃音对应的通知 channel
  Future<void> deleteSoundChannel(String soundName) async {
    if (!Platform.isAndroid || soundName.isEmpty) return;
    try {
      final channelId = notificationChannelIdForSound(soundName);
      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.deleteNotificationChannel(channelId);
    } catch (e) {
      debugPrint('LocalNotificationService deleteSoundChannel failed: $e');
    }
  }
}

