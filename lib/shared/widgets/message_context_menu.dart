import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/l10n/app_localizations.dart';

const double _kAppBarHeight = 56.0;

/// 构建消息上下文菜单项（复制、Pin/Unpin、删除、多选）
class MessageContextMenuItems {
  MessageContextMenuItems._();

  static List<ContextMenuItem> build(
    BuildContext context, {
    String? copyText,
    bool isPinned = false,
    bool showPin = false,
    VoidCallback? onPinToggle,
    VoidCallback? onDelete,
    VoidCallback? onEnterSelectionMode,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final items = <ContextMenuItem>[];

    if (copyText != null && copyText.isNotEmpty) {
      items.add(ContextMenuItem(
        label: l10n.copy,
        icon: Icons.copy_outlined,
        onTap: () => Clipboard.setData(ClipboardData(text: copyText)),
      ));
    }
    if (showPin && onPinToggle != null) {
      items.add(ContextMenuItem(
        label: isPinned ? l10n.unpin : l10n.pin,
        icon: isPinned ? Icons.push_pin : Icons.push_pin_outlined,
        onTap: onPinToggle,
      ));
    }
    if (onDelete != null) {
      items.add(ContextMenuItem(
        label: l10n.delete,
        icon: Icons.delete_outline_rounded,
        onTap: onDelete,
        isDestructive: true,
      ));
    }
    if (onEnterSelectionMode != null) {
      items.add(ContextMenuItem(
        label: l10n.multiSelect,
        icon: Icons.checklist_rounded,
        onTap: onEnterSelectionMode,
      ));
    }
    return items;
  }
}

/// 上下文菜单项
class ContextMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isDestructive;
  final bool enabled;

  const ContextMenuItem({
    required this.label,
    this.icon,
    required this.onTap,
    this.isDestructive = false,
    this.enabled = true,
  });
}

/// 统一的上下文菜单组件
class MessageContextMenu {
  MessageContextMenu._();

  /// 在指定控件附近显示上下文菜单（带三角指示器）
  static OverlayEntry? show(
    BuildContext context,
    List<ContextMenuItem> items, {
    required RenderBox targetBox,
    RenderBox? contentBox,
    bool preferAbove = true,
    VoidCallback? onDismiss,
  }) {
    if (items.isEmpty) return null;
    return _show(context, items,
        targetBox: targetBox, contentBox: contentBox, preferAbove: preferAbove, onDismiss: onDismiss);
  }

  /// 在指定坐标显示上下文菜单（无三角指示器）
  static OverlayEntry? showAtPosition(
    BuildContext context,
    List<ContextMenuItem> items, {
    required Offset anchor,
    bool preferAbove = true,
    VoidCallback? onDismiss,
  }) {
    if (items.isEmpty) return null;
    return _show(context, items, anchor: anchor, preferAbove: preferAbove, onDismiss: onDismiss);
  }

  static OverlayEntry? _show(
    BuildContext context,
    List<ContextMenuItem> items, {
    RenderBox? targetBox,
    RenderBox? contentBox,
    Offset? anchor,
    bool preferAbove = true,
    VoidCallback? onDismiss,
  }) {
    assert(targetBox != null || anchor != null);

    final overlay = Overlay.of(context);
    final mq = MediaQuery.of(context);
    final screenSize = mq.size;
    final safePadding = mq.padding;
    final topSafe = mq.viewPadding.top + _kAppBarHeight;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. 目标区域
    final bool useAnchor = targetBox == null;
    final bool showIndicator = !useAnchor;
    double targetCenterX, targetTop, targetBottom;

    if (useAnchor) {
      targetCenterX = anchor!.dx;
      targetTop = targetBottom = anchor.dy;
    } else {
      final tPos = targetBox.localToGlobal(Offset.zero);
      targetCenterX = tPos.dx + targetBox.size.width / 2;
      final vBox = contentBox ?? targetBox;
      final vPos = vBox.localToGlobal(Offset.zero);
      targetTop = vPos.dy;
      targetBottom = vPos.dy + vBox.size.height;
    }

    // 2. 菜单尺寸估算（用于定位）
    const double iconSize = 24.0, textH = 18.0, iconTextGap = 6.0;
    const double vPad = 10.0, hPad = 14.0, minW = 68.0, sep = 0.5, border = 0.5;
    const double arrowW = 16.0, arrowH = 8.0, spacing = 0.0;

    final textStyle = LinuTextStyles.caption.copyWith(fontSize: 13, fontWeight: FontWeight.w500);
    double menuW = border * 2;
    for (int i = 0; i < items.length; i++) {
      final tp = TextPainter(text: TextSpan(text: items[i].label, style: textStyle), textDirection: TextDirection.ltr)
        ..layout();
      double cw = tp.width > iconSize ? tp.width : iconSize;
      double iw = cw + hPad * 2;
      if (iw < minW) iw = minW;
      menuW += iw;
      if (i < items.length - 1) menuW += sep;
    }
    final double menuH = iconSize + iconTextGap + textH + vPad * 2 + border * 2;
    final double arrowExt = showIndicator ? arrowH : 0;
    final double totalH = menuH + arrowExt;

    // 3. 上/下方向
    bool above = preferAbove;
    if (preferAbove && targetTop < totalH + spacing + topSafe) above = false;
    if (!preferAbove && targetBottom + totalH + spacing > screenSize.height - safePadding.bottom) above = true;

    // 4. X 位置
    final double screenL = spacing + safePadding.left;
    final double screenR = screenSize.width - spacing - safePadding.right;
    double menuX = targetCenterX - menuW / 2;
    if (menuX < screenL) menuX = screenL;
    if (menuX + menuW > screenR) menuX = screenR - menuW;

    // 5. Y 位置
    double menuY;
    if (above) {
      menuY = targetTop - spacing - arrowExt - menuH;
      if (menuY < spacing + topSafe) menuY = spacing + topSafe;
    } else {
      menuY = targetBottom + spacing + arrowExt;
      final maxY = screenSize.height - menuH - spacing - safePadding.bottom;
      if (menuY > maxY) menuY = maxY;
    }

    // 6. 创建 Overlay
    OverlayEntry? entry;
    void dismiss() {
      if (entry?.mounted == true) {
        entry!.remove();
      }
      entry = null;
      onDismiss?.call();
    }

    entry = OverlayEntry(
      builder: (_) => _MenuOverlay(
        position: Offset(menuX, menuY),
        showIndicator: showIndicator,
        indicatorOnBottom: above,
        arrowSize: Size(arrowW, arrowH),
        items: items,
        isDark: isDark,
        onDismiss: dismiss,
      ),
    );
    Future.microtask(() => overlay.insert(entry!));
    return entry;
  }
}

/// 菜单覆盖层
class _MenuOverlay extends StatelessWidget {
  final Offset position;
  final bool showIndicator;
  final bool indicatorOnBottom;
  final Size arrowSize;
  final List<ContextMenuItem> items;
  final bool isDark;
  final VoidCallback onDismiss;

  const _MenuOverlay({
    required this.position,
    required this.showIndicator,
    required this.indicatorOnBottom,
    required this.arrowSize,
    required this.items,
    required this.isDark,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 TapRegion 检测菜单外部点击，不会阻止选择手柄的拖动手势
    return Stack(
      children: [
        Positioned(
          left: position.dx,
          top: position.dy,
          child: TapRegion(
            onTapOutside: (_) => onDismiss(),
            child: _MenuContent(
              items: items,
              isDark: isDark,
              showArrow: showIndicator,
              arrowOnTop: !indicatorOnBottom,
              arrowWidth: arrowSize.width,
              arrowHeight: arrowSize.height,
              onDismiss: onDismiss,
            ),
          ),
        ),
      ],
    );
  }
}

/// 菜单内容
class _MenuContent extends StatelessWidget {
  final List<ContextMenuItem> items;
  final bool isDark;
  final bool showArrow;
  final bool arrowOnTop;
  final double arrowWidth;
  final double arrowHeight;
  final VoidCallback onDismiss;

  const _MenuContent({
    required this.items,
    required this.isDark,
    required this.showArrow,
    required this.arrowOnTop,
    required this.arrowWidth,
    required this.arrowHeight,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    // 统一的颜色配置
    final backgroundColor = isDark 
        ? LinuColors.darkElevatedSurface  // #1F1F1F - 比卡片 #141414 更亮
        : Colors.white;
    final borderColor = isDark
        ? LinuColors.darkBorder  // #303030
        : LinuColors.lightBorder.withValues(alpha: 0.5);
    final dividerColor = isDark
        ? LinuColors.darkDivider  // #262626
        : LinuColors.lightDivider;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: _BubbleShape(
            radius: LinuRadius.large,
            arrowWidth: arrowWidth,
            arrowHeight: arrowHeight,
            arrowOnTop: arrowOnTop,
            showArrow: showArrow,
            borderColor: borderColor,
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipPath(
          clipper: _BubbleClipper(
            radius: LinuRadius.large,
            arrowWidth: arrowWidth,
            arrowHeight: arrowHeight,
            arrowOnTop: arrowOnTop,
            showArrow: showArrow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _MenuItem(item: items[i], isDark: isDark, onDismiss: onDismiss),
                if (i < items.length - 1)
                  Container(
                    width: 1,
                    height: 40,
                    color: dividerColor,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 气泡形状（三角居中）
class _BubbleShape extends ShapeBorder {
  final double radius;
  final double arrowWidth;
  final double arrowHeight;
  final bool arrowOnTop;
  final bool showArrow;
  final Color borderColor;

  const _BubbleShape({
    required this.radius,
    required this.arrowWidth,
    required this.arrowHeight,
    required this.arrowOnTop,
    required this.showArrow,
    required this.borderColor,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    if (showArrow) {
      final cx = rect.center.dx;
      final arrow = Path();
      if (arrowOnTop) {
        arrow.moveTo(cx - arrowWidth / 2, rect.top);
        arrow.lineTo(cx, rect.top - arrowHeight);
        arrow.lineTo(cx + arrowWidth / 2, rect.top);
      } else {
        arrow.moveTo(cx - arrowWidth / 2, rect.bottom);
        arrow.lineTo(cx, rect.bottom + arrowHeight);
        arrow.lineTo(cx + arrowWidth / 2, rect.bottom);
      }
      arrow.close();
      return Path.combine(PathOperation.union, path, arrow);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    canvas.drawPath(
      getOuterPath(rect),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  ShapeBorder scale(double t) => this;
}

/// 气泡裁切器
class _BubbleClipper extends CustomClipper<Path> {
  final double radius;
  final double arrowWidth;
  final double arrowHeight;
  final bool arrowOnTop;
  final bool showArrow;

  _BubbleClipper({
    required this.radius,
    required this.arrowWidth,
    required this.arrowHeight,
    required this.arrowOnTop,
    required this.showArrow,
  });

  @override
  Path getClip(Size size) {
    final rect = Offset.zero & size;
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    if (showArrow) {
      final cx = size.width / 2;
      final arrow = Path();
      if (arrowOnTop) {
        arrow.moveTo(cx - arrowWidth / 2, 0);
        arrow.lineTo(cx, -arrowHeight);
        arrow.lineTo(cx + arrowWidth / 2, 0);
      } else {
        arrow.moveTo(cx - arrowWidth / 2, size.height);
        arrow.lineTo(cx, size.height + arrowHeight);
        arrow.lineTo(cx + arrowWidth / 2, size.height);
      }
      arrow.close();
      return Path.combine(PathOperation.union, path, arrow);
    }
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// 菜单项
class _MenuItem extends StatelessWidget {
  final ContextMenuItem item;
  final bool isDark;
  final VoidCallback onDismiss;

  const _MenuItem({required this.item, required this.isDark, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final color = item.isDestructive
        ? Theme.of(context).colorScheme.error
        : (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText);
    final effectiveColor = item.enabled ? color : color.withValues(alpha: 0.4);

    return InkWell(
      onTap: item.enabled ? () { onDismiss(); item.onTap(); } : null,
      borderRadius: BorderRadius.circular(LinuRadius.medium),
      splashColor: (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText).withValues(alpha: 0.1),
      highlightColor: (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText).withValues(alpha: 0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(minWidth: 68),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 24, color: effectiveColor),
              const SizedBox(height: 6),
            ],
            Text(
              item.label,
              style: LinuTextStyles.caption.copyWith(fontSize: 13, fontWeight: FontWeight.w500, color: effectiveColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
