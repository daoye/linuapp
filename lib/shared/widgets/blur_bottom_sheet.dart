import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/theme/app_theme.dart';

/// 毛玻璃效果的 Bottom Sheet
/// 
/// 支持浅色和深色模式，提供统一的视觉效果
class BlurBottomSheet extends StatelessWidget {
  /// Sheet 标题（可选）
  final String? title;
  
  /// 子组件列表
  final List<Widget> children;
  
  /// 是否显示拖拽指示条
  final bool showDragHandle;

  const BlurBottomSheet({
    super.key,
    this.title,
    required this.children,
    this.showDragHandle = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Stack(
        children: [
          // 底层：模糊效果层
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 50,
                sigmaY: 50,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // 中层：颜色叠加层（提供足够的对比度）
          Positioned.fill(
            child: Container(
              color: isDark
                  ? LinuColors.darkCardSurface.withValues(alpha: 0.85)
                  : LinuColors.lightCardSurface.withValues(alpha: 0.92),
            ),
          ),
          // 顶层：内容层
          Container(
            decoration: BoxDecoration(
              // 边框颜色 - 使用设计系统的边框颜色，增强对比度
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? LinuColors.darkBorder.withValues(alpha: 0.6)
                      : LinuColors.lightBorder.withValues(alpha: 0.4),
                  width: 0.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 拖拽指示条
                  if (showDragHandle)
                    Container(
                      width: 36,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? LinuColors.darkSecondaryText.withValues(alpha: 0.5)
                            : LinuColors.lightSecondaryText.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  // 标题（可选）
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        title!,
                        style: LinuTextStyles.title.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? LinuColors.darkPrimaryText
                              : LinuColors.lightPrimaryText,
                        ),
                      ),
                    ),
                  // 子组件
                  ...children,
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示毛玻璃 Bottom Sheet
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required List<Widget> children,
    bool showDragHandle = true,
    bool isDismissible = true,
  }) {
    HapticFeedback.lightImpact();
    
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: (Theme.of(context).brightness == Brightness.dark 
          ? LinuColors.darkPrimaryText 
          : LinuColors.lightPrimaryText).withValues(alpha: 0.2),
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      builder: (context) => BlurBottomSheet(
        title: title,
        showDragHandle: showDragHandle,
        children: children,
      ),
    );
  }
}

/// 毛玻璃 Sheet 的菜单项（纯文本居中设计）
class BlurSheetItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const BlurSheetItem({
    super.key,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = isDestructive 
        ? theme.colorScheme.error 
        : (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        splashColor: isDark
            ? LinuColors.darkPressedBackground
            : LinuColors.lightPressedBackground,
        highlightColor: isDark
            ? LinuColors.darkHoverBackground
            : LinuColors.lightHoverBackground,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: LinuSpacing.xl,
            vertical: LinuSpacing.md,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: LinuTextStyles.body.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// 毛玻璃 Sheet 的文本菜单项（用于二级菜单，最多3行）
class BlurSheetTextItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const BlurSheetTextItem({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        splashColor: isDark
            ? LinuColors.darkPressedBackground
            : LinuColors.lightPressedBackground,
        highlightColor: isDark
            ? LinuColors.darkHoverBackground
            : LinuColors.lightHoverBackground,
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: EdgeInsets.symmetric(
            horizontal: LinuSpacing.xl,
            vertical: LinuSpacing.md,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: LinuTextStyles.body.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark
                  ? LinuColors.darkPrimaryText
                  : LinuColors.lightPrimaryText,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
