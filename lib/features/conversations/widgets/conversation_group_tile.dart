import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:app/db/database.dart';
import 'package:app/shared/utils.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/widgets/selection_checkbox.dart';
import 'package:app/shared/widgets/message_context_menu.dart';
import 'package:app/shared/constants.dart';

class ConversationGroupTile extends StatefulWidget {
  final Group group;
  final Message? lastMessage;
  final bool isPinned;
  final VoidCallback? onLongPress;
  
  /// 是否处于选择模式
  final bool isSelectionMode;
  
  /// 是否被选中
  final bool isSelected;
  
  /// 选择/取消选择回调
  final VoidCallback? onSelectionTap;

  /// Pin/Unpin 回调
  final VoidCallback? onPinToggle;

  /// 删除回调
  final VoidCallback? onDelete;

  /// 进入多选模式回调
  final VoidCallback? onEnterSelectionMode;

  const ConversationGroupTile({
    super.key,
    required this.group,
    this.lastMessage,
    required this.isPinned,
    this.onLongPress,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionTap,
    this.onPinToggle,
    this.onDelete,
    this.onEnterSelectionMode,
  });

  @override
  State<ConversationGroupTile> createState() => _ConversationGroupTileState();
}

class _ConversationGroupTileState extends State<ConversationGroupTile> {
  final GlobalKey _contentKey = GlobalKey();

  void _showContextMenu(BuildContext context) {
    Feedback.forLongPress(context);
    final renderBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final items = MessageContextMenuItems.build(
      context,
      showPin: true,
      isPinned: widget.isPinned,
      onPinToggle: widget.onPinToggle,
      onDelete: widget.onDelete,
      onEnterSelectionMode: widget.onEnterSelectionMode,
    );
    if (items.isEmpty) return;

    MessageContextMenu.show(context, items, targetBox: renderBox);
  }

  @override
  Widget build(BuildContext context) {
    // 如果提供了 context menu 回调，使用 context menu；否则使用原来的 onLongPress
    final onLongPressHandler = (widget.onPinToggle != null || widget.onDelete != null || widget.onEnterSelectionMode != null)
        ? () => _showContextMenu(context)
        : widget.onLongPress;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final hasUnread = widget.lastMessage != null && !widget.lastMessage!.isRead;

    // Card-style container with shadow and radius
    final borderColor = isDark
        ? LinuColors.darkBorder.withValues(alpha: 0.6)
        : LinuColors.lightBorder.withValues(alpha: 0.8);

    // 卡片内容
    final cardContent = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          key: _contentKey,
          decoration: BoxDecoration(
            color: isDark
                ? LinuColors.darkCardSurface
                : LinuColors.lightCardSurface,
            borderRadius: BorderRadius.circular(LinuRadius.medium),
            border: Border.all(color: borderColor, width: 0.5),
            // 双层阴影效果 - 增加立体感
            boxShadow: [
              // 第一层：近距离清晰阴影
              BoxShadow(
                color: (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText).withValues(
                  alpha: 0.06,
                ),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
              // 第二层：远距离柔和阴影
              BoxShadow(
                color: (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText).withValues(
                  alpha: 0.04,
                ),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(LinuRadius.medium),
              splashColor: isDark
                  ? LinuColors.darkPressedBackground
                  : LinuColors.lightPressedBackground,
              highlightColor: isDark
                  ? LinuColors.darkHoverBackground
                  : LinuColors.lightHoverBackground,
              onLongPress: widget.isSelectionMode ? null : onLongPressHandler,
              onTap: widget.isSelectionMode 
                  ? widget.onSelectionTap 
                  : () => context.push('/conversationlist/${Uri.encodeComponent(widget.group.id)}'),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: LinuSpacing.lg,
                  vertical: LinuSpacing.md,
                ),
                child: Row(
              children: [
                // Avatar
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark
                        ? LinuColors.darkElevatedSurface
                        : LinuColors.lightChatBackground,
                    borderRadius: BorderRadius.circular(LinuRadius.large),
                    image: widget.group.iconUrl.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(widget.group.iconUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.group.iconUrl.isEmpty
                      ? Icon(
                          Icons.group_outlined,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                ),
                SizedBox(width: LinuSpacing.lg),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.group.name.isNotEmpty
                                  ? widget.group.name
                                  : AppLocalizations.of(context)!.defaultGroupName,
                              style: LinuTextStyles.title.copyWith(
                                color: isDark
                                    ? LinuColors.darkPrimaryText
                                    : LinuColors.lightPrimaryText,
                                fontWeight: hasUnread
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: LinuSpacing.xs),
                          // 右上角：日期和 pin 标记
                          if (!widget.isSelectionMode)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // 日期（仅当有消息时显示）
                                if (widget.lastMessage != null)
                                  Text(
                                    AppUtils.formatDateTime(
                                      widget.lastMessage!.createdAt,
                                      yesterday: l10n.yesterday,
                                      locale: Localizations.localeOf(context).toString(),
                                    ),
                                    style: LinuTextStyles.caption.copyWith(
                                      color: isDark
                                          ? LinuColors.darkSecondaryText
                                          : LinuColors.lightSecondaryText,
                                    ),
                                  ),
                                // Pin 标记（如果有）
                                if (widget.isPinned) ...[
                                  if (widget.lastMessage != null)
                                    SizedBox(width: LinuSpacing.xs),
                                  Icon(
                                    Icons.push_pin,
                                    size: 14,
                                    color: isDark
                                        ? LinuColors.darkPrimaryAccent
                                        : LinuColors.lightPrimaryAccent,
                                  ),
                                ],
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: LinuSpacing.xs),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.lastMessage == null
                                  ? l10n.noMessages
                                  : (widget.lastMessage!.content.isEmpty
                                      ? l10n.emptyField
                                      : widget.lastMessage!.content),
                              style: LinuTextStyles.body.copyWith(
                                color: isDark
                                    ? LinuColors.darkSecondaryText
                                    : LinuColors.lightSecondaryText,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
                ),
              ),
            ),
          ),
        ),
      // 未读标记（右上角浮动，考虑圆角）
      if (hasUnread)
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: LinuColors.unreadIndicator,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );

    // 统一布局，使用 AnimatedContainer 控制 checkbox 宽度
    return RepaintBoundary(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 使用 AnimatedContainer 控制 checkbox 宽度，实现平滑过渡
          AnimatedContainer(
            duration: AnimationDurations.medium,
            curve: Curves.easeInOutCubic,
            width: widget.isSelectionMode ? 30 : 0,
            child: widget.isSelectionMode
                ? SelectionCheckbox(
                    isSelected: widget.isSelected,
                    onTap: widget.onSelectionTap,
                  )
                : const SizedBox.shrink(),
          ),
          // 卡片内容
          Expanded(child: cardContent),
        ],
      ),
    );
  }
}
