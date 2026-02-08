import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/theme/app_theme.dart';

/// 系统性方案：使用 SelectableText + onSelectionChanged
///
/// 核心逻辑：
/// 1. [onSelectionChanged] 提供 [SelectionChangedCause]，明确区分长按和拖动。
/// 2. 当 cause 为 longPress 时，设置标志 [_shouldSelectAll]。
/// 3. 在 [contextMenuBuilder] 中检查标志，若为 true 则执行全选。
/// 4. 拖动手柄时 cause 为 drag，不会设置标志，因此不会覆盖用户选区。
class SelectableTextWithMenu extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool isConversationList;
  final VoidCallback? onPinToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onEnterSelectionMode;

  final RenderBox? Function()? getTargetBox;
  final RenderBox? Function()? getContentBox;

  const SelectableTextWithMenu(
    this.text, {
    super.key,
    this.style,
    this.isConversationList = false,
    this.onPinToggle,
    this.onDelete,
    this.onEnterSelectionMode,
    this.getTargetBox,
    this.getContentBox,
  });

  @override
  State<SelectableTextWithMenu> createState() => _SelectableTextWithMenuState();
}

class _SelectableTextWithMenuState extends State<SelectableTextWithMenu> {
  /// 标志：下一次 contextMenuBuilder 调用时是否应执行全选
  /// 仅当 onSelectionChanged 的 cause 为 longPress 时设为 true
  bool _shouldSelectAll = false;

  void _handleSelectionChanged(TextSelection selection, SelectionChangedCause? cause) {
    // 只有长按才触发全选标志
    if (cause == SelectionChangedCause.longPress) {
      _shouldSelectAll = true;
    }
    // drag、tap、keyboard 等其他 cause 不设置标志
  }

  Widget _buildContextMenu(BuildContext context, EditableTextState editableTextState) {
    // 检查是否需要全选
    if (_shouldSelectAll) {
      _shouldSelectAll = false; // 立即重置，避免重复触发
      
      // 延迟执行，避免在 build 阶段调用 setState
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !editableTextState.mounted) return;
        
        final text = editableTextState.currentTextEditingValue.text;
        if (text.isEmpty) return;
        
        final sel = editableTextState.currentTextEditingValue.selection;
        final isFullySelected = sel.isValid && sel.start == 0 && sel.end == text.length;
        
        if (!isFullySelected) {
          editableTextState.userUpdateTextEditingValue(
            editableTextState.currentTextEditingValue.copyWith(
              selection: TextSelection(baseOffset: 0, extentOffset: text.length),
            ),
            SelectionChangedCause.longPress,
          );
        }
      });
    }

    return _SelectionToolbar(
      editableTextState: editableTextState,
      text: widget.text,
      isConversationList: widget.isConversationList,
      onPinToggle: widget.onPinToggle,
      onDelete: widget.onDelete,
      onEnterSelectionMode: widget.onEnterSelectionMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(text: widget.text, style: widget.style),
      onSelectionChanged: _handleSelectionChanged,
      contextMenuBuilder: _buildContextMenu,
    );
  }
}

/// 选择工具栏
class _SelectionToolbar extends StatelessWidget {
  final EditableTextState editableTextState;
  final String text;
  final bool isConversationList;
  final VoidCallback? onPinToggle;
  final VoidCallback? onDelete;
  final VoidCallback? onEnterSelectionMode;

  const _SelectionToolbar({
    required this.editableTextState,
    required this.text,
    required this.isConversationList,
    this.onPinToggle,
    this.onDelete,
    this.onEnterSelectionMode,
  });

  void _dismiss() {
    if (editableTextState.mounted) {
      final val = editableTextState.currentTextEditingValue;
      editableTextState.userUpdateTextEditingValue(
        val.copyWith(
          selection: TextSelection.collapsed(offset: val.text.length),
        ),
        SelectionChangedCause.toolbar,
      );
    }
    ContextMenuController.removeAny();
  }

  void _handleCopy() {
    if (!editableTextState.mounted) return;

    final val = editableTextState.currentTextEditingValue;
    final sel = val.selection;
    final textToCopy = (sel.isValid && !sel.isCollapsed)
        ? val.text.substring(sel.start, sel.end)
        : text;

    Clipboard.setData(ClipboardData(text: textToCopy));
    _dismiss();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final anchors = editableTextState.contextMenuAnchors;

    final actions = <_MenuAction>[];

    if (text.isNotEmpty) {
      actions.add(_MenuAction(l10n.copy, Icons.copy_outlined, _handleCopy));
    }

    if (isConversationList && onPinToggle != null) {
      actions.add(_MenuAction(l10n.pin, Icons.push_pin_outlined, () {
        _dismiss();
        onPinToggle!();
      }));
    }

    if (onDelete != null) {
      actions.add(_MenuAction(l10n.delete, Icons.delete_outline_rounded, () {
        _dismiss();
        onDelete!();
      }, isDestructive: true));
    }

    if (onEnterSelectionMode != null) {
      actions.add(_MenuAction(l10n.multiSelect, Icons.checklist_rounded, () {
        _dismiss();
        Future.microtask(() => onEnterSelectionMode!());
      }));
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return CustomSingleChildLayout(
      delegate: _ToolbarLayout(anchors),
      child: _ToolbarBody(actions: actions, isDark: isDark, anchors: anchors),
    );
  }
}

class _MenuAction {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuAction(this.label, this.icon, this.onTap, {this.isDestructive = false});
}

class _ToolbarLayout extends SingleChildLayoutDelegate {
  final TextSelectionToolbarAnchors anchors;
  static const double _spacing = 8.0;
  static const double _arrowHeight = 8.0;

  const _ToolbarLayout(this.anchors);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final primary = anchors.primaryAnchor;
    final secondary = anchors.secondaryAnchor;
    final showAbove = primary.dy > childSize.height + _spacing + _arrowHeight;
    double x = primary.dx - childSize.width / 2;
    x = x.clamp(_spacing, size.width - childSize.width - _spacing);
    double y = showAbove
        ? (primary.dy - childSize.height - _spacing - _arrowHeight)
        : ((secondary?.dy ?? primary.dy) + _spacing + _arrowHeight);
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_ToolbarLayout old) => anchors != old.anchors;
}

class _ToolbarBody extends StatelessWidget {
  final List<_MenuAction> actions;
  final bool isDark;
  final TextSelectionToolbarAnchors anchors;

  const _ToolbarBody({
    required this.actions,
    required this.isDark,
    required this.anchors,
  });

  @override
  Widget build(BuildContext context) {
    const toolbarHeight = 76.0;
    const spacing = 8.0;
    final arrowOnTop = anchors.primaryAnchor.dy <= toolbarHeight + spacing;
    // 统一使用与 MessageContextMenu 相同的颜色
    final bgColor = isDark ? LinuColors.darkElevatedSurface : Colors.white;
    final borderColor = isDark
        ? LinuColors.darkBorder
        : LinuColors.lightBorder.withValues(alpha: 0.5);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: ShapeDecoration(
          color: bgColor,
          shape: _BubbleBorder(arrowOnTop: arrowOnTop, borderColor: borderColor),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipPath(
          clipper: _BubbleClip(arrowOnTop: arrowOnTop),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < actions.length; i++) ...[
                _ActionButton(action: actions[i], isDark: isDark),
                if (i < actions.length - 1) _Divider(isDark: isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final _MenuAction action;
  final bool isDark;
  const _ActionButton({required this.action, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final color = action.isDestructive
        ? Theme.of(context).colorScheme.error
        : (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText);
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(LinuRadius.medium),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(minWidth: 68),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(action.icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: LinuTextStyles.caption.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isDark;
  const _Divider({required this.isDark});
  @override
  Widget build(BuildContext context) {
    // 统一使用与 MessageContextMenu 相同的分割线颜色
    return Container(
      width: 1,
      height: 40,
      color: isDark ? LinuColors.darkDivider : LinuColors.lightDivider,
    );
  }
}

class _BubbleBorder extends ShapeBorder {
  final bool arrowOnTop;
  final Color borderColor;
  static const _radius = 12.0;
  static const _arrowW = 16.0;
  static const _arrowH = 8.0;
  const _BubbleBorder({this.arrowOnTop = false, this.borderColor = Colors.transparent});
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;
  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(_radius)));
    final cx = rect.center.dx;
    final arrow = Path();
    if (arrowOnTop) {
      arrow.moveTo(cx - _arrowW / 2, rect.top);
      arrow.lineTo(cx, rect.top - _arrowH);
      arrow.lineTo(cx + _arrowW / 2, rect.top);
    } else {
      arrow.moveTo(cx - _arrowW / 2, rect.bottom);
      arrow.lineTo(cx, rect.bottom + _arrowH);
      arrow.lineTo(cx + _arrowW / 2, rect.bottom);
    }
    arrow.close();
    return Path.combine(PathOperation.union, path, arrow);
  }
  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => getOuterPath(rect);
  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    if (borderColor != Colors.transparent) {
      canvas.drawPath(
        getOuterPath(rect),
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );
    }
  }
  @override
  ShapeBorder scale(double t) => this;
}

class _BubbleClip extends CustomClipper<Path> {
  final bool arrowOnTop;
  const _BubbleClip({this.arrowOnTop = false});
  @override
  Path getClip(Size size) => _BubbleBorder(arrowOnTop: arrowOnTop).getOuterPath(Offset.zero & size);
  @override
  bool shouldReclip(covariant _BubbleClip old) => arrowOnTop != old.arrowOnTop;
}
