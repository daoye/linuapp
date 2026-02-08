import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/conversation_actions/webhook_service.dart';
import 'package:app/features/push/push_models.dart' show WebhookMethod;
import 'package:app/features/settings/settings_provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/widgets/blur_bottom_sheet.dart';
import 'package:app/shared/widgets/gradient_divider.dart';
import 'package:app/shared/services/toast_service.dart';

/// 融入式 Action 菜单栏
/// 
/// 设计要点：
/// - 按钮完全融入 bottombar 背景，透明底，无边框
/// - 均分横向空间，高度占满
/// - 只有交互态（按压反馈），没有激活态
/// - 二级菜单使用半透明毛玻璃 Sheet
class ConversationActionBar extends ConsumerStatefulWidget {
  final String menuConfigJson;
  final String? groupId;
  final Function(String actionLabel, bool success)? onActionComplete;
  final Function(String actionLabel, bool isLoading, bool? success)?
  onActionStatusChanged;

  const ConversationActionBar({
    super.key,
    required this.menuConfigJson,
    this.groupId,
    this.onActionComplete,
    this.onActionStatusChanged,
  });

  @override
  ConsumerState<ConversationActionBar> createState() =>
      _ConversationActionBarState();
}

class _ConversationActionBarState extends ConsumerState<ConversationActionBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    List<dynamic> actions = [];

    try {
      final decoded = jsonDecode(widget.menuConfigJson);
      if (decoded is List) {
        actions = decoded;
      } else if (decoded is Map) {
        actions = decoded['actions'] ?? [];
      }
    } catch (e) {
      return const SizedBox.shrink();
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    final topLevelActions = actions.take(4).toList();

    // 无外部 padding，让按钮占满空间
    // 固定高度，确保布局稳定
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          for (var i = 0; i < topLevelActions.length; i++) ...[
            if (i > 0) const GradientDivider(),
            Expanded(
              child: _buildActionButton(
                label: topLevelActions[i]['label'] ?? 'Action',
                callback: topLevelActions[i]['callback'] ?? '',
                method: _parseMethod(topLevelActions[i]['method']),
                payload: _extractPayload(topLevelActions[i]['payload']),
                children: _extractChildren(topLevelActions[i]['children']),
                isDark: isDark,
                theme: theme,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 解析 method 字段
  WebhookMethod _parseMethod(dynamic value) {
    if (value == null) return WebhookMethod.get;
    final str = value.toString().toLowerCase();
    return str == 'post' ? WebhookMethod.post : WebhookMethod.get;
  }

  /// 提取 payload，支持 String 和 Map 类型
  String? _extractPayload(dynamic rawPayload) {
    if (rawPayload is String) {
      return rawPayload;
    } else if (rawPayload is Map) {
      return jsonEncode(rawPayload);
    }
    return null;
  }

  /// 提取 children，限制最多8项
  List<Map<String, dynamic>>? _extractChildren(dynamic rawChildren) {
    if (rawChildren is List) {
      return rawChildren
          .take(8)
          .map((c) => Map<String, dynamic>.from(c as Map))
          .toList();
    }
    return null;
  }

  Widget _buildActionButton({
    required String label,
    required String callback,
    required WebhookMethod method,
    required String? payload,
    List<Map<String, dynamic>>? children,
    required bool isDark,
    required ThemeData theme,
  }) {
    final hasChildren = children != null && children.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(LinuRadius.medium),
        // 使用设计系统的交互反馈颜色
        splashColor: isDark
            ? LinuColors.darkPressedBackground
            : LinuColors.lightPressedBackground,
        highlightColor: isDark
            ? LinuColors.darkHoverBackground
            : LinuColors.lightHoverBackground,
        onTap: () {
          HapticFeedback.selectionClick();
          if (hasChildren) {
            _showSubmenuSheet(label, children);
          } else {
            _handleAction(label, callback, method, payload);
          }
        },
        child: Container(
          // 占满分配的高度
          height: double.infinity,
          alignment: Alignment.center,
          // 添加内边距，与模式切换按钮保持一致
          padding: const EdgeInsets.symmetric(
            horizontal: LinuSpacing.sm,
            vertical: LinuSpacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  // 使用设计系统的文本样式，允许最多两行
                  style: LinuTextStyles.label.copyWith(
                    color: isDark
                        ? LinuColors.darkPrimaryText
                        : LinuColors.lightPrimaryText,
                    fontSize: 13, // 稍微小一点以适应两行
                    height: 1.3, // 紧凑的行高
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
              if (hasChildren) ...[
                SizedBox(width: LinuSpacing.xs),
                Icon(
                  Icons.expand_more_rounded,
                  size: 14,
                  color: isDark
                      ? LinuColors.darkSecondaryText
                      : LinuColors.lightSecondaryText,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 显示二级菜单 Sheet（半透明毛玻璃效果）
  void _showSubmenuSheet(String parentLabel, List<Map<String, dynamic>> children) {
    BlurBottomSheet.show(
      context: context,
      title: parentLabel,
      children: children.map((child) {
        final label = child['label'] ?? 'Action';
        final callback = child['callback'] ?? '';
        final method = _parseMethod(child['method']);
        final rawPayload = child['payload'];
        final String? payload = rawPayload is String
            ? rawPayload
            : (rawPayload is Map ? jsonEncode(rawPayload) : null);

        return BlurSheetTextItem(
          label: label,
          onTap: () {
            Navigator.of(context).pop();
            _handleAction(label, callback, method, payload);
          },
    );
      }).toList(),
    );
  }

  Future<void> _handleAction(
    String label,
    String callback,
    WebhookMethod method,
    String? payload,
  ) async {
    if (callback.isEmpty) return;

    widget.onActionStatusChanged?.call(label, true, null);
    HapticFeedback.lightImpact();

    final settings = ref.read(settingsProvider);
    final webhookToken = settings.effectiveWebhookToken;

    final webhookPayload = {
      'device_token': webhookToken,
      'group_id': widget.groupId ?? '',
      'type': 'menu',
      'payload': payload,
    };

    final response = await WebhookService.instance.callWebhook(
      url: callback,
      method: method,
      body: webhookPayload,
    );

    if (mounted) {
      widget.onActionStatusChanged?.call(label, false, response.isSuccess);
      widget.onActionComplete?.call(label, response.isSuccess);
      
      if (response.message != null && response.message!.isNotEmpty) {
        ToastService.instance.showBottom(
          response.message!,
          false,
          isSuccess: response.isSuccess,
        );
      }
    }
  }
}
