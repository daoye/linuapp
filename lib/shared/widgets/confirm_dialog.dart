import 'package:flutter/material.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/l10n/app_localizations.dart';

/// 确认对话框类型
enum ConfirmDialogType {
  /// 普通确认（主题色主按钮）
  normal,
  /// 危险操作确认（红色主按钮 + 警告图标）
  destructive,
}

/// 统一的确认对话框
/// 
/// 用于删除、重置等需要用户确认的操作
/// 
/// 设计特点：
/// - 危险操作使用醒目的红色图标容器
/// - 清晰的视觉层次：图标 -> 标题 -> 内容 -> 按钮
/// - 按钮全宽显示，更易点击
class ConfirmDialog extends StatelessWidget {
  /// 对话框标题
  final String title;
  
  /// 对话框内容
  final String content;
  
  /// 确认按钮文本（默认使用 l10n.confirm）
  final String? confirmText;
  
  /// 取消按钮文本（默认使用 l10n.cancel）
  final String? cancelText;
  
  /// 对话框类型
  final ConfirmDialogType type;
  
  /// 标题图标（可选）
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText,
    this.cancelText,
    this.type = ConfirmDialogType.normal,
    this.icon,
  });

  /// 显示确认对话框
  /// 
  /// 返回 true 表示用户确认，false 或 null 表示取消
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
    ConfirmDialogType type = ConfirmDialogType.normal,
    IconData? icon,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        type: type,
        icon: icon,
      ),
    );
  }

  /// 显示删除确认对话框（快捷方法）
  static Future<bool?> showDelete(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return show(
      context,
      title: title,
      content: content,
      confirmText: confirmText ?? l10n.delete,
      type: ConfirmDialogType.destructive,
      icon: Icons.delete_outline_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDestructive = type == ConfirmDialogType.destructive;
    final isDark = theme.brightness == Brightness.dark;

    final accentColor = isDestructive 
        ? theme.colorScheme.error 
        : theme.colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LinuRadius.xlarge),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(LinuSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 图标区域
              if (icon != null) ...[
                _buildIconContainer(theme, accentColor, isDark),
                const SizedBox(height: LinuSpacing.lg),
              ],
              
              // 标题
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: LinuSpacing.sm),
              
              // 内容
              Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: LinuSpacing.xl),
              
              // 按钮区域
              _buildButtons(context, theme, l10n, isDestructive, accentColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconContainer(ThemeData theme, Color accentColor, bool isDark) {
    final containerColor = accentColor.withValues(alpha: isDark ? 0.2 : 0.1);
    
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: containerColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: accentColor,
        size: 28,
      ),
    );
  }

  Widget _buildButtons(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    bool isDestructive,
    Color accentColor,
  ) {
    return Column(
      children: [
        // 确认按钮（全宽）
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(vertical: LinuSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LinuRadius.medium),
              ),
            ),
            child: Text(
              confirmText ?? l10n.confirm,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        
        const SizedBox(height: LinuSpacing.sm),
        
        // 取消按钮（全宽，文字按钮样式）
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: LinuSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(LinuRadius.medium),
              ),
            ),
            child: Text(
              cancelText ?? l10n.cancel,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
