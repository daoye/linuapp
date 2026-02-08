import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/utils.dart';
import 'package:app/shared/constants.dart';

/// 空状态组件
/// 
/// 用于展示列表/详情页面无内容时的友好提示
/// 
/// 设计特点：
/// - 居中的图标容器（带背景色）增加视觉重量
/// - 标题 + 描述的文字层次
/// - 可选的操作按钮
/// - 可选的自定义内容区域（如教程）
/// - 尊重 prefers-reduced-motion
class EmptyState extends StatelessWidget {
  /// 主标题
  final String title;
  
  /// 描述文字（可选）
  final String? description;
  
  /// 图标
  final IconData icon;
  
  /// 操作按钮文字
  final String? actionLabel;
  
  /// 操作按钮回调
  final VoidCallback? onAction;
  
  /// 操作按钮是否处于加载状态
  final bool isActionLoading;
  
  /// 自定义内容区域（显示在描述和按钮之间）
  final Widget? customContent;

  const EmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.chat_bubble_outline,
    this.actionLabel,
    this.onAction,
    this.isActionLoading = false,
    this.customContent,
  });

  /// 兼容旧 API 的工厂构造函数
  factory EmptyState.legacy({
    Key? key,
    required String message,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return EmptyState(
      key: key,
      title: message,
      icon: icon ?? Icons.chat_bubble_outline,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prefersReducedMotion = AppUtils.prefersReducedMotion(context);
    
    final iconContainerColor = isDark
        ? LinuColors.darkElevatedSurface
        : LinuColors.lightChatBackground;
    
    final iconColor = isDark
        ? LinuColors.darkSecondaryText
        : LinuColors.lightSecondaryText;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: LinuSpacing.xl,
          vertical: LinuSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 图标容器
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: iconContainerColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: iconColor,
              ),
            )
                .animate()
                .fadeIn(
                  duration: prefersReducedMotion
                      ? Duration.zero
                      : AnimationDurations.slow,
                  curve: Curves.easeOut,
                )
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: prefersReducedMotion
                      ? Duration.zero
                      : AnimationDurations.slow,
                  curve: Curves.easeOutBack,
                ),
            
            const SizedBox(height: LinuSpacing.xl),
            
            // 标题
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(
                  duration: prefersReducedMotion
                      ? Duration.zero
                      : AnimationDurations.standard,
                  delay: prefersReducedMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                )
                .slideY(
                  begin: 0.1,
                  end: 0,
                  duration: prefersReducedMotion
                      ? Duration.zero
                      : AnimationDurations.standard,
                  curve: Curves.easeOut,
                ),
            
            // 描述
            if (description != null) ...[
              const SizedBox(height: LinuSpacing.sm),
              Text(
                description!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(
                    duration: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.standard,
                    delay: prefersReducedMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 150),
                    curve: Curves.easeOut,
                  )
                  .slideY(
                    begin: 0.1,
                    end: 0,
                    duration: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.standard,
                    curve: Curves.easeOut,
                  ),
            ],
            
            // 自定义内容区域
            if (customContent != null) ...[
              const SizedBox(height: LinuSpacing.xl),
              customContent!
                  .animate()
                  .fadeIn(
                    duration: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.standard,
                    delay: prefersReducedMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                  ),
            ],
            
            // 操作按钮
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: LinuSpacing.xl),
              FilledButton.tonal(
                onPressed: isActionLoading ? null : onAction,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LinuSpacing.xl,
                    vertical: LinuSpacing.md,
                  ),
                ),
                child: isActionLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      )
                    : Text(actionLabel!),
              )
                  .animate()
                  .fadeIn(
                    duration: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.standard,
                    delay: prefersReducedMotion
                        ? Duration.zero
                        : const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  )
                  .slideY(
                    begin: 0.1,
                    end: 0,
                    duration: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.standard,
                    curve: Curves.easeOut,
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
