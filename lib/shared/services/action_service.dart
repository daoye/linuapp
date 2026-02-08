import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/features/conversation_actions/webhook_service.dart';
import 'package:app/features/push/push_models.dart';
import 'package:app/features/settings/settings_provider.dart';
import 'package:app/shared/services/toast_service.dart';

class ActionService {
  static final ActionService _instance = ActionService._internal();
  static ActionService get instance => _instance;

  ActionService._internal();

  /// Parse webhook method from action map
  WebhookMethod _parseMethod(Map<String, dynamic> action) {
    final methodStr = action['method']?.toString().toLowerCase() ?? '';
    return methodStr == 'post' ? WebhookMethod.post : WebhookMethod.get;
  }

  Future<void> handleMessageAction(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> action, {
    required String messageId,
    String? groupId,
  }) async {
    if (action['type'] == 'navigation') {
      await _handleNavigation(context, action);
      return;
    }

    final actionLabel = action['label'] as String? ?? 'Action';
    final callback = action['callback'] as String?;
    final payload = action['payload'] as String?;
    final method = _parseMethod(action);

    if (callback == null || callback.isEmpty) return;

    ToastService.instance.showCenter(actionLabel, true);
    HapticFeedback.lightImpact();

    try {
      final settings = ref.read(settingsProvider);
      final webhookToken = settings.effectiveWebhookToken;

      final webhookPayload = <String, dynamic>{
        'device_token': webhookToken,
        'message_id': messageId,
        'type': 'action',
        'payload': payload,
      };
      // 仅当 groupId 存在时才添加
      if (groupId != null && groupId.isNotEmpty) {
        webhookPayload['group_id'] = groupId;
      }

      final response = await WebhookService.instance.callWebhook(
        url: callback,
        method: method,
        body: webhookPayload,
      );

      ToastService.instance.showCenter(
        actionLabel,
        false,
        isSuccess: response.isSuccess,
      );
    } catch (e) {
      ToastService.instance.showCenter(
        actionLabel,
        false,
        isSuccess: false,
      );
    }
  }

  /// Handle message action using MessageAction object
  Future<void> handleMessageActionObject(
    BuildContext context,
    WidgetRef ref,
    MessageAction action, {
    required String messageId,
    String? groupId,
  }) async {
    ToastService.instance.showCenter(action.label, true);
    HapticFeedback.lightImpact();

    try {
      final settings = ref.read(settingsProvider);
      final webhookToken = settings.effectiveWebhookToken;

      final webhookPayload = <String, dynamic>{
        'device_token': webhookToken,
        'message_id': messageId,
        'type': 'action',
        'payload': action.payload,
      };
      // 仅当 groupId 存在时才添加
      if (groupId != null && groupId.isNotEmpty) {
        webhookPayload['group_id'] = groupId;
      }

      final response = await WebhookService.instance.callWebhookWithConfig(
        webhook: action.callback,
        body: webhookPayload,
      );

      ToastService.instance.showCenter(
        action.label,
        false,
        isSuccess: response.isSuccess,
      );
    } catch (e) {
      ToastService.instance.showCenter(
        action.label,
        false,
        isSuccess: false,
      );
    }
  }

  Future<void> handleGroupAction(
    WidgetRef ref,
    String label,
    String callback,
    String? payload,
    String groupId, {
    WebhookMethod method = WebhookMethod.get,
  }) async {
    if (callback.isEmpty) return;

    ToastService.instance.showBottom(label, true);
    HapticFeedback.lightImpact();

    try {
      final settings = ref.read(settingsProvider);
      final webhookToken = settings.effectiveWebhookToken;

      final webhookPayload = {
        'device_token': webhookToken,
        'group_id': groupId,
        'type': 'menu',
        'payload': payload,
      };

      final response = await WebhookService.instance.callWebhook(
        url: callback,
        method: method,
        body: webhookPayload,
      );

      ToastService.instance.showBottom(
        label,
        false,
        isSuccess: response.isSuccess,
      );
    } catch (e) {
      ToastService.instance.showBottom(
        label,
        false,
        isSuccess: false,
      );
    }
  }

  /// Handle group action using MessageAction object
  Future<void> handleGroupActionObject(
    WidgetRef ref,
    MessageAction action,
    String groupId,
  ) async {
    return handleGroupAction(
      ref,
      action.label,
      action.callback.url,
      action.payload?.toString(),
      groupId,
      method: action.callback.method,
    );
  }

  Future<void> _handleNavigation(
    BuildContext context,
    Map<String, dynamic> action,
  ) async {
    try {
      final target = action['target'];
      if (target == null || target is! Map<String, dynamic>) {
        return;
      }

      final url = target['url'] as String?;
      if (url == null || url.isEmpty) {
        return;
      }

      final uri = Uri.parse(url);
      
      // 即使 canLaunchUrl 返回 false，也尝试启动 URL
      // 因为在 Android 11+ 上，包可见性问题可能导致误判
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        
        if (!launched && context.mounted) {
          ToastService.instance.showCenter(
            '无法打开链接',
            false,
            isSuccess: false,
          );
        }
      } catch (launchError) {
        if (context.mounted) {
          ToastService.instance.showCenter(
            '打开链接失败',
            false,
            isSuccess: false,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ToastService.instance.showCenter(
          '打开链接失败',
          false,
          isSuccess: false,
        );
      }
    }
  }
}

