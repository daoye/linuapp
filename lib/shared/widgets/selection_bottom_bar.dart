import 'package:flutter/material.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/constants.dart';

/// 选择模式底部操作栏
/// 
/// 统一的底部浮动操作栏组件，用于选择模式下的批量操作。
/// 
/// ## 特性
/// - 固定在屏幕底部，使用 SafeArea 处理安全区域
/// - 支持自定义按钮配置（图标 + 文本）
/// - 自动处理按钮布局（均匀分布或环绕分布）
/// - 支持禁用状态和危险操作样式
/// - 内置 Tooltip 提示
/// 
/// ## 使用示例
/// 
/// ```dart
/// SelectionBottomBar(
///   actions: [
///     SelectionAction(
///       icon: Icons.push_pin_outlined,
///       label: '置顶',
///       onPressed: () => _pinSelected(),
///     ),
///     SelectionAction(
///       icon: Icons.delete_outline_rounded,
///       label: '删除',
///       onPressed: () => _deleteSelected(),
///       isDestructive: true,
///       isDisabled: selectedCount == 0,
///     ),
///     SelectionAction(
///       icon: Icons.check_box,
///       label: '全选',
///       onPressed: () => _selectAll(),
///     ),
///   ],
/// )
/// ```
/// 
/// ## 配合 AnimatedSwitcher 使用
/// 
/// ```dart
/// Positioned(
///   left: 0,
///   right: 0,
///   bottom: 0,
///   child: AnimatedSwitcher(
///     duration: AnimationDurations.medium,
///     transitionBuilder: (child, animation) {
///       return SlideTransition(
///         position: Tween<Offset>(
///           begin: const Offset(0, 1),
///           end: Offset.zero,
///         ).animate(CurvedAnimation(
///           parent: animation,
///           curve: Curves.easeInOutCubic,
///         )),
///         child: FadeTransition(
///           opacity: animation,
///           child: child,
///         ),
///       );
///     },
///     child: isSelectionMode
///         ? SelectionBottomBar(actions: [...])
///         : const SizedBox.shrink(),
///   ),
/// )
/// ```

/// 选择模式底部操作栏的按钮配置
class SelectionAction {
  /// 按钮图标
  final IconData icon;
  
  /// 按钮文本标签
  final String label;
  
  /// 点击回调
  final VoidCallback? onPressed;
  
  /// 是否为危险操作（使用错误色）
  final bool isDestructive;
  
  /// 是否禁用
  final bool isDisabled;

  const SelectionAction({
    required this.icon,
    required this.label,
    this.onPressed,
    this.isDestructive = false,
    this.isDisabled = false,
  });
}

/// 选择模式底部操作栏
/// 
/// 统一的底部浮动操作栏，用于选择模式下的批量操作
/// 支持自定义按钮配置，带滑入滑出动画
class SelectionBottomBar extends StatelessWidget {
  /// 工具栏最小高度（不含安全区）
  static const double _kBarHeight = 56.0;

  /// 操作按钮列表
  final List<SelectionAction> actions;

  const SelectionBottomBar({
    super.key,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      color: isDark
          ? LinuColors.darkBottomBarBackground
          : LinuColors.lightBottomBarBackground,
      child: SafeArea(
        top: false,
        child: Container(
          constraints: const BoxConstraints(minHeight: _kBarHeight),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: isDark
                    ? LinuColors.darkSecondaryText.withValues(alpha: 0.3)
                    : LinuColors.lightSecondaryText.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: actions.map((action) {
              return Expanded(
                child: _ActionButton(
                  action: action,
                  isDark: isDark,
                  theme: theme,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// 底部操作栏的单个按钮
class _ActionButton extends StatelessWidget {
  final SelectionAction action;
  final bool isDark;
  final ThemeData theme;

  const _ActionButton({
    required this.action,
    required this.isDark,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    // 确定按钮颜色
    Color iconColor;
    Color textColor;
    
    if (action.isDisabled) {
      iconColor = isDark
          ? LinuColors.darkTertiaryText
          : LinuColors.lightTertiaryText;
      textColor = iconColor;
    } else if (action.isDestructive) {
      iconColor = theme.colorScheme.error;
      textColor = theme.colorScheme.error;
    } else {
      iconColor = isDark
          ? LinuColors.darkPrimaryText
          : LinuColors.lightPrimaryText;
      textColor = iconColor;
    }

    return Tooltip(
      message: action.label,
      child: InkWell(
        onTap: action.isDisabled ? null : action.onPressed,
        borderRadius: BorderRadius.circular(LinuRadius.medium),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: LinuSpacing.sm,
            vertical: LinuSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                action.icon,
                size: 22,
                color: iconColor,
              ),
              SizedBox(height: LinuSpacing.xs),
              // 使用 AnimatedSwitcher 平滑切换文本，避免宽度变化导致布局抖动
              // 使用 SizedBox 包裹并设置 minHeight，确保文本区域高度一致
              SizedBox(
                height: 16, // overline 文本的行高
                child: AnimatedSwitcher(
                  duration: AnimationDurations.medium,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    action.label,
                    key: ValueKey(action.label),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: LinuTextStyles.overline.copyWith(
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
