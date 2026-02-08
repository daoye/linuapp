import 'package:flutter/material.dart';
import 'package:app/theme/app_theme.dart';

/// 渐变分割线
/// 
/// 垂直分割线，两端渐变透明，中间实色。
/// 用于 action bar、bottom bar 等场景的按钮分隔。
class GradientDivider extends StatelessWidget {
  /// 分割线高度，默认 32
  final double height;
  
  /// 分割线宽度，默认 0.5
  final double width;

  const GradientDivider({
    super.key,
    this.height = 32,
    this.width = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? LinuColors.darkDivider : LinuColors.lightDivider;
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.0),
            color.withValues(alpha: 1.0),
            color.withValues(alpha: 1.0),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.15, 0.85, 1.0],
        ),
      ),
    );
  }
}
