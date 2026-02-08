import 'package:flutter/material.dart';
import 'package:app/db/database.dart';
import 'package:app/shared/utils.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/widgets/selection_checkbox.dart';
import 'package:app/shared/widgets/selectable_text_with_menu.dart';
import 'package:app/shared/widgets/message_context_menu.dart';
import 'package:app/shared/constants.dart';

/// Position of a bubble within a consecutive message group
enum BubblePosition {
  /// Single message, not part of a group
  standalone,

  /// First message in a group (has full top corners)
  first,

  /// Middle message in a group (reduced corners on both ends)
  middle,

  /// Last message in a group (has full bottom corners + tail)
  last,
}

class MessageBubble extends StatefulWidget {
  final Message message;

  /// Position within a consecutive message group
  final BubblePosition position;

  /// Whether to show the timestamp (typically only on last/standalone)
  final bool showTimestamp;

  /// 是否处于选择模式
  final bool isSelectionMode;

  /// 是否被选中
  final bool isSelected;

  /// 选择/取消选择回调
  final VoidCallback? onSelectionTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 是否在会话列表页面（用于决定是否显示 pin/unpin 选项）
  final bool isConversationList;

  /// Pin/Unpin 回调（仅会话列表）
  final VoidCallback? onPinToggle;

  /// 删除回调
  final VoidCallback? onDelete;

  /// 进入多选模式回调
  final VoidCallback? onEnterSelectionMode;

  /// 重试发送回调（仅客户端发送的消息）
  final VoidCallback? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    this.position = BubblePosition.standalone,
    this.showTimestamp = true,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionTap,
    this.onLongPress,
    this.isConversationList = false,
    this.onPinToggle,
    this.onDelete,
    this.onEnterSelectionMode,
    this.onRetry,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  final GlobalKey _contentKey = GlobalKey();

  void _showContextMenu(BuildContext context) {
    Feedback.forLongPress(context);
    final renderBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final items = MessageContextMenuItems.build(
      context,
      copyText: widget.message.content.isNotEmpty ? widget.message.content : null,
      showPin: widget.isConversationList,
      isPinned: false,
      onPinToggle: widget.onPinToggle,
      onDelete: widget.onDelete,
      onEnterSelectionMode: widget.onEnterSelectionMode,
    );
    if (items.isEmpty) return;

    MessageContextMenu.show(context, items, targetBox: renderBox);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final isClient = widget.message.isClientSent;
    final screenWidth = MediaQuery.of(context).size.width;

    // 选择模式下需要减去选择列宽度
    // 无论左右，选择列都贴着列表边界（列表已有 LinuSpacing.sm 左右边距），只保留另一侧间距
    final availableWidth = widget.isSelectionMode
        ? screenWidth - kSelectionColumnWidth - LinuSpacing.sm
        : screenWidth;

    // 根据屏幕宽度动态调整最大宽度
    final maxWidthRatio = screenWidth < 360
        ? 0.85 // 小屏幕（< 360px）
        : screenWidth < 768
            ? 0.78 // 正常屏幕（360-768px）
            : 0.65; // 大屏幕（> 768px）

    // Bubble colors based on theme and sender
    final bubbleColor = isClient
        ? (isDark
              ? LinuColors.darkOutgoingBubble
              : LinuColors.lightOutgoingBubble)
        : (isDark
              ? LinuColors.darkIncomingBubble
              : LinuColors.lightIncomingBubble);

    final textColor = isClient
        ? (isDark
              ? LinuColors.darkOutgoingBubbleText
              : LinuColors.lightOutgoingBubbleText)
        : (isDark
              ? LinuColors.darkIncomingBubbleText
              : LinuColors.lightIncomingBubbleText);

    final timestampColor = isClient
        ? (isDark
              ? LinuColors.darkSecondaryText
              : LinuColors.lightSecondaryText)
        : (isDark ? LinuColors.darkTertiaryText : LinuColors.lightTertiaryText);

    // Calculate border radius based on position in message group
    final borderRadius = _MessageBubbleState._getBorderRadius(
      isClient,
      widget.position,
    );

    // 气泡内容
    final bubbleContent = Container(
      key: _contentKey,
        constraints: BoxConstraints(
        maxWidth: availableWidth * maxWidthRatio,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: LinuSpacing.md,
          vertical: LinuSpacing.sm + 2, // 10dp
        ),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: borderRadius,
          // Minimal border for incoming bubbles in light mode only
          border: (!isClient && !isDark)
              ? Border.all(color: LinuColors.lightBorder, width: 0.5)
              : null,
        ),
        child: Column(
          crossAxisAlignment: isClient
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          widget.isSelectionMode
              ? Text(
                  widget.message.content,
                  style: LinuTextStyles.body.copyWith(color: textColor),
                )
              : SelectableTextWithMenu(
                  widget.message.content,
                  style: LinuTextStyles.body.copyWith(color: textColor),
                  getTargetBox: () => _contentKey.currentContext?.findRenderObject() as RenderBox?,
                  isConversationList: widget.isConversationList,
                  onPinToggle: widget.onPinToggle,
                  onDelete: widget.onDelete,
                  onEnterSelectionMode: widget.onEnterSelectionMode,
                ),
          if (widget.showTimestamp) ...[
              SizedBox(height: LinuSpacing.xs),
              Text(
                AppUtils.formatDateTime(
                  widget.message.createdAt,
                  yesterday: l10n.yesterday,
                  locale: Localizations.localeOf(context).toString(),
                ),
                style: LinuTextStyles.caption.copyWith(color: timestampColor),
              ),
            ],
          ],
        ),
    );

    // 发送状态指示器（仅客户端发送的消息）
    final sendStatus = widget.message.sendStatus;
    final showStatusIndicator = isClient && sendStatus != 0;

    Widget? statusIndicator;
    if (showStatusIndicator) {
      if (sendStatus == 1) {
        // 发送中
        statusIndicator = Padding(
          padding: EdgeInsets.only(right: LinuSpacing.xs),
          child: SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: isDark
                  ? LinuColors.darkSecondaryText
                  : LinuColors.lightSecondaryText,
            ),
          ),
        );
      } else if (sendStatus == 2) {
        // 发送失败，可点击重试
        statusIndicator = Padding(
          padding: EdgeInsets.only(right: LinuSpacing.xs),
          child: GestureDetector(
            onTap: widget.onRetry,
            child: Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: theme.colorScheme.error,
            ),
          ),
        );
      }
    }

    // 统一布局，使用 AnimatedContainer 控制 checkbox 宽度
    return GestureDetector(
      onLongPress: widget.isSelectionMode
          ? null
          : () {
              _showContextMenu(context);
            },
      onTap: widget.isSelectionMode
          ? widget.onSelectionTap
          : () {
              // 点击空白处时清除文本选择
              FocusScope.of(context).unfocus();
            },
      behavior: HitTestBehavior.translucent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 使用 AnimatedContainer 控制 checkbox 宽度，实现平滑过渡
          AnimatedContainer(
            duration: AnimationDurations.medium,
            curve: Curves.easeInOutCubic,
            width: widget.isSelectionMode ? 30 : 0,
            child: widget.isSelectionMode
                ? Padding(
                    padding: EdgeInsets.only(top: LinuSpacing.xs),
                    child: SelectionCheckbox(
                      isSelected: widget.isSelected,
                      onTap: widget.onSelectionTap,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Align(
              alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
              child: isClient
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (statusIndicator != null) statusIndicator,
                        bubbleContent,
                      ],
                    )
                  : bubbleContent,
            ),
          ),
        ],
      ),
    );
  }

  /// Calculate border radius based on bubble position in a message group
  ///
  /// Visual layout (with ListView.reverse = true):
  /// - first: TOP of group (full top corners, small bottom-right/left for tail side)
  /// - middle: MIDDLE of group (small corners on tail side, both top and bottom)
  /// - last: BOTTOM of group (small top corner on tail side, full bottom corners with tail)
  static BorderRadius _getBorderRadius(bool isClient, BubblePosition position) {
    const large = LinuRadius.large;
    const small = LinuRadius.small;
    const tiny = LinuRadius.small / 2; // 2dp for grouped edges

    // For standalone messages, use the classic WhatsApp-style tail
    if (position == BubblePosition.standalone) {
      return BorderRadius.only(
        topLeft: Radius.circular(large),
        topRight: Radius.circular(large),
        bottomLeft: isClient ? Radius.circular(large) : Radius.circular(small),
        bottomRight: isClient ? Radius.circular(small) : Radius.circular(large),
      );
    }

    // For grouped messages, adjust corners based on VISUAL position
    if (isClient) {
      // Outgoing (right-aligned) messages - tail on bottom-right
      switch (position) {
        case BubblePosition.first:
          // TOP of group: full top corners, tiny bottom-right (connects to middle)
          return BorderRadius.only(
            topLeft: Radius.circular(large),
            topRight: Radius.circular(large),
            bottomLeft: Radius.circular(large),
            bottomRight: Radius.circular(tiny),
          );
        case BubblePosition.middle:
          // MIDDLE of group: tiny on right side (both top and bottom)
          return BorderRadius.only(
            topLeft: Radius.circular(large),
            topRight: Radius.circular(tiny),
            bottomLeft: Radius.circular(large),
            bottomRight: Radius.circular(tiny),
          );
        case BubblePosition.last:
          // BOTTOM of group: tiny top-right, tail on bottom-right
          return BorderRadius.only(
            topLeft: Radius.circular(large),
            topRight: Radius.circular(tiny),
            bottomLeft: Radius.circular(large),
            bottomRight: Radius.circular(small), // Tail
          );
        case BubblePosition.standalone:
          return BorderRadius.circular(large); // Already handled above
      }
    } else {
      // Incoming (left-aligned) messages - tail on bottom-left
      switch (position) {
        case BubblePosition.first:
          // TOP of group: full top corners, tiny bottom-left (connects to middle)
          return BorderRadius.only(
            topLeft: Radius.circular(large),
            topRight: Radius.circular(large),
            bottomLeft: Radius.circular(tiny),
            bottomRight: Radius.circular(large),
          );
        case BubblePosition.middle:
          // MIDDLE of group: tiny on left side (both top and bottom)
          return BorderRadius.only(
            topLeft: Radius.circular(tiny),
            topRight: Radius.circular(large),
            bottomLeft: Radius.circular(tiny),
            bottomRight: Radius.circular(large),
          );
        case BubblePosition.last:
          // BOTTOM of group: tiny top-left, tail on bottom-left
          return BorderRadius.only(
            topLeft: Radius.circular(tiny),
            topRight: Radius.circular(large),
            bottomLeft: Radius.circular(small), // Tail
            bottomRight: Radius.circular(large),
          );
        case BubblePosition.standalone:
          return BorderRadius.circular(large); // Already handled above
      }
    }
  }
}

