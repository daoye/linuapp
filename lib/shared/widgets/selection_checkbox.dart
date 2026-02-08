import 'package:flutter/material.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/constants.dart';

/// 统一的选择模式复选框组件
/// 所有页面共用，保持一致的视觉风格
class SelectionCheckbox extends StatelessWidget {
  final bool isSelected;
  final VoidCallback? onTap;
  
  /// 复选框尺寸，默认 22dp
  final double size;
  
  /// 点击区域尺寸，默认 36dp
  final double hitAreaSize;

  const SelectionCheckbox({
    super.key,
    required this.isSelected,
    this.onTap,
    this.size = 20,
    this.hitAreaSize = 30,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: hitAreaSize,
        height: hitAreaSize,
        child: Align(
          alignment: Alignment.centerLeft,
          child: AnimatedContainer(
            duration: AnimationDurations.fast,
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : (isDark
                        ? LinuColors.darkBorder.withValues(alpha: 0.6)
                        : LinuColors.lightBorder.withValues(alpha: 0.8)),
                width: 2,
              ),
            ),
            child: AnimatedScale(
              scale: isSelected ? 1.0 : 0.0,
              duration: AnimationDurations.fast,
              child: Icon(
                Icons.check_rounded,
                size: 14,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 选择列宽度常量
const double kSelectionColumnWidth = 28.0;

