import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/widgets/empty_state.dart';
import 'package:app/shared/services/toast_service.dart';
import 'package:app/shared/constants.dart';
import 'package:app/features/settings/settings_provider.dart';
import 'package:app/l10n/app_localizations.dart';

/// 带教程和测试推送的空状态组件
/// 
/// 在空列表状态下展示简易教程，帮助用户了解如何发送消息
class EmptyStateWithTutorial extends ConsumerStatefulWidget {
  const EmptyStateWithTutorial({super.key});

  @override
  ConsumerState<EmptyStateWithTutorial> createState() =>
      _EmptyStateWithTutorialState();
}

class _EmptyStateWithTutorialState
    extends ConsumerState<EmptyStateWithTutorial> {
  bool _isSending = false;

  Future<void> _sendTestPush() async {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.read(settingsProvider);
    final token = settings.deviceToken;

    if (token == null) {
      ToastService.instance.showCenter(
        l10n.testPushNoToken,
        false,
        isSuccess: false,
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final isIOS = Platform.isIOS;
      final platform = isIOS ? 'ios' : 'android';
      
      // 使用 GET 请求调用简化的推送接口：/v1/push/:platform/:token
      // 支持 query parameters: title, text, group_id 等
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.pushPath}/$platform/$token'
      ).replace(
        queryParameters: {
          'text': "Hello",
        },
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 202 || response.statusCode == 200) {
        await HapticFeedback.mediumImpact();
        ToastService.instance.showBottom(
          l10n.testPushSent,
          false,
          isSuccess: true,
        );
      } else {
        final body = jsonDecode(response.body);
        final error = body['error'] ?? 'Unknown error';
        ToastService.instance.showBottom(
          '${l10n.testPushFailed}: $error',
          false,
          isSuccess: false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ToastService.instance.showBottom(
        '${l10n.testPushFailed}: $e',
        false,
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return EmptyState(
      title: l10n.noMessages,
      description: l10n.noMessagesDescription,
      icon: Icons.notifications_none_rounded,
      customContent: _buildTutorialCard(theme, isDark, l10n),
      actionLabel: _isSending ? l10n.sending : l10n.testPushButton,
      onAction: _sendTestPush,
      isActionLoading: _isSending,
    );
  }

  Widget _buildTutorialCard(
    ThemeData theme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final cardColor = isDark
        ? LinuColors.darkCardSurface
        : LinuColors.lightCardSurface;
    
    final borderColor = isDark
        ? LinuColors.darkBorder.withValues(alpha: 0.5)
        : LinuColors.lightBorder.withValues(alpha: 0.5);

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(LinuSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(LinuRadius.large),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Row(
            children: [
              Icon(
                Icons.rocket_launch_outlined,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: LinuSpacing.sm),
              Text(
                l10n.quickStartTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: LinuSpacing.md),
          
          // 步骤列表
          _buildStep(theme, isDark, '1', l10n.quickStartStep1),
          const SizedBox(height: LinuSpacing.sm),
          _buildStep(theme, isDark, '2', l10n.quickStartStep2),
          const SizedBox(height: LinuSpacing.sm),
          _buildStep(theme, isDark, '3', l10n.quickStartStep3),
          
          const SizedBox(height: LinuSpacing.md),
          
          // API 示例
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(LinuSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? LinuColors.darkElevatedSurface
                  : LinuColors.lightChatBackground,
              borderRadius: BorderRadius.circular(LinuRadius.medium),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'GET',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: LinuColors.success,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: LinuSpacing.sm),
                Expanded(
                  child: SelectableText(
                    '${ApiConstants.pushPath}/${Platform.isIOS ? 'ios' : 'android'}/{token}?text=Hello',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: LinuSpacing.md),
          
          // 查看文档按钮
          Center(
            child: GestureDetector(
              onTap: () => context.push('/docs'),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.viewDocs,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    ThemeData theme,
    bool isDark,
    String number,
    String text,
  ) {
    final numberBgColor = isDark
        ? LinuColors.darkElevatedSurface
        : LinuColors.lightChatBackground;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: numberBgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(width: LinuSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
