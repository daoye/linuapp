import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:app/db/database.dart';
import 'package:app/shared/widgets/error_placeholder.dart';
import 'package:app/features/conversation_messages/widgets/video_player.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/widgets/card_action_menu.dart';
import 'package:app/shared/widgets/selection_checkbox.dart';
import 'package:app/shared/widgets/selectable_text_with_menu.dart';
import 'package:app/shared/widgets/message_context_menu.dart';
import 'package:app/shared/utils.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/shared/constants.dart';

class TemplateMessageCard extends StatefulWidget {
  final Message message;
  final Function(Map<String, dynamic> action)? onActionTap;

  /// 是否处于选择模式
  final bool isSelectionMode;

  /// 是否被选中
  final bool isSelected;

  /// 选择/取消选择回调
  final VoidCallback? onSelectionTap;

  /// 长按回调
  final VoidCallback? onLongPress;

  /// 是否在卡片右上角显示日期（默认 true，在 group conversation 中显示）
  final bool showDateInCorner;

  /// 是否显示 pin 标记（默认 false）
  final bool showPin;

  /// 是否显示未读标记（默认 false）
  final bool showUnread;

  /// 是否在会话列表页面（用于决定是否显示 pin/unpin 选项）
  final bool isConversationList;

  /// Pin/Unpin 回调（仅会话列表）
  final VoidCallback? onPinToggle;

  /// 删除回调
  final VoidCallback? onDelete;

  /// 进入多选模式回调
  final VoidCallback? onEnterSelectionMode;

  const TemplateMessageCard({
    super.key,
    required this.message,
    this.onActionTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionTap,
    this.onLongPress,
    this.showDateInCorner = true,
    this.showPin = false,
    this.showUnread = false,
    this.isConversationList = false,
    this.onPinToggle,
    this.onDelete,
    this.onEnterSelectionMode,
  });

  @override
  State<TemplateMessageCard> createState() => _TemplateMessageCardState();
}

class _TemplateMessageCardState extends State<TemplateMessageCard> {
  final GlobalKey _contentKey = GlobalKey();
  final GlobalKey _mediaContentKey = GlobalKey(); // 内容区域（图片/视频 + 消息内容）的 key

  void _showContextMenu(BuildContext context) {
    Feedback.forLongPress(context);
    final renderBox = _contentKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    String? copyText;
    if (widget.message.title.isNotEmpty || widget.message.content.isNotEmpty) {
      final title = widget.message.title.trim();
      final content = widget.message.content.trim();
      if (title.isNotEmpty && content.isNotEmpty) {
        copyText = '$title\n$content';
      } else if (title.isNotEmpty) {
        copyText = title;
      } else {
        copyText = content;
      }
    }
    final items = MessageContextMenuItems.build(
      context,
      copyText: copyText,
      showPin: widget.isConversationList,
      isPinned: widget.showPin,
      onPinToggle: widget.onPinToggle,
      onDelete: widget.onDelete,
      onEnterSelectionMode: widget.onEnterSelectionMode,
    );
    if (items.isEmpty) return;

    final contentBox = _mediaContentKey.currentContext?.findRenderObject() as RenderBox?;
    MessageContextMenu.show(context, items, targetBox: renderBox, contentBox: contentBox);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Parse actions from JSON string
    List<Map<String, dynamic>> actions = [];
    if (widget.message.actions.isNotEmpty) {
      try {
        final actionsList = jsonDecode(widget.message.actions) as List;
        actions = actionsList
            .map((action) => Map<String, dynamic>.from(action as Map))
            .toList();
      } catch (e) {
        // Invalid actions JSON, ignore
      }
    }

    // Check for media
    final hasMedia = widget.message.mediaType.isNotEmpty;
    final mediaType = widget.message.mediaType;
    final mediaUrl = widget.message.mediaUrl;

    // Check for target (detail)
    final hasTarget = widget.message.detailUrl.isNotEmpty;
    final targetUrl = widget.message.detailUrl;

    final rawTitle = widget.message.title.trim();
    final hasTextTitle = rawTitle.isNotEmpty;
    final showHeader = hasTextTitle || hasTarget || true; // 始终显示 header，即使没有 title 也显示"（无）"
    final displayTitle = hasTextTitle 
        ? rawTitle 
        : (hasTarget ? 'Link' : l10n.emptyField);

    // Center the card within the chat timeline with horizontal margins
    final isDark = theme.brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    // 选择模式下需要减去选择列宽度
    // 选择列直接贴着列表左边界（列表已有 LinuSpacing.md 左边距），只保留右侧间距
    final availableWidth = widget.isSelectionMode
        ? screenWidth - kSelectionColumnWidth - LinuSpacing.md
        : screenWidth - LinuSpacing.md * 2;

    final borderColor = isDark
        ? LinuColors.darkBorder.withValues(alpha: 0.6)
        : LinuColors.lightBorder.withValues(alpha: 0.8);

    // 卡片内容
    final cardContent = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          key: _contentKey,
          constraints: BoxConstraints(maxWidth: availableWidth),
          decoration: BoxDecoration(
            // Card surface using LinuColors
            color: isDark
                ? LinuColors.darkCardSurface
                : LinuColors.lightCardSurface,
            borderRadius: BorderRadius.circular(LinuRadius.medium),
            border: Border.all(
              color: borderColor,
              width: 0.5, // Thinner border for cleaner look
            ),
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
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card v2: Optional header with title (when title exists)
          if (showHeader) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: LinuSpacing.md,
                vertical: LinuSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      displayTitle,
                      style: LinuTextStyles.title.copyWith(
                        color: isDark
                            ? LinuColors.darkPrimaryText
                            : LinuColors.lightPrimaryText,
                      ),
                    ),
                  ),
                  SizedBox(width: LinuSpacing.xs),
                  // 右上角：日期、pin 和 external 标记
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 日期（仅在 showDateInCorner 为 true 时显示）
                      if (widget.showDateInCorner)
                        Text(
                          AppUtils.formatDateTime(
                            widget.message.createdAt,
                            yesterday: l10n.yesterday,
                            locale: Localizations.localeOf(context).toString(),
                          ),
                          style: LinuTextStyles.caption.copyWith(
                            color: isDark
                                ? LinuColors.darkTertiaryText
                                : LinuColors.lightTertiaryText,
                          ),
                        ),
                      // Pin 标记（如果有）
                      if (widget.showPin) ...[
                        if (widget.showDateInCorner)
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
            ),
          ],

          // 内容区域（图片/视频 + 消息内容）- 用于菜单定位
          Column(
            key: _mediaContentKey,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media (Image or Video) - Card v2: improved transition
              if (hasMedia) ...[
                // Add small spacing between header and media if both exist
                if (showHeader) SizedBox(height: LinuSpacing.xs),
                if (mediaType == 'video' && mediaUrl.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: LinuSpacing.sm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(LinuRadius.small),
                      child: AppVideoPlayer(videoUrl: mediaUrl),
                    ),
                  )
                else if (mediaType == 'image' && mediaUrl.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: LinuSpacing.sm),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(LinuRadius.small),
                      child: CachedNetworkImage(
                        imageUrl: mediaUrl,
                        width: double.infinity,
                        height: 180, // Slightly smaller for better proportion
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 180,
                          decoration: BoxDecoration(
                            color: isDark
                                ? LinuColors.darkElevatedSurface
                                : LinuColors.lightChatBackground,
                            borderRadius: BorderRadius.circular(
                              LinuRadius.small,
                            ),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) =>
                            const ImagePlaceholder(
                              height: 180,
                              errorMessage: 'Failed to load image',
                            ),
                      ),
                    ),
                  ),
              ],

              // Body text area - Card v3: make main content tappable for navigation
              Padding(
                padding: EdgeInsets.only(
                  left: LinuSpacing.md,
                  right: LinuSpacing.md,
                  top: hasMedia ? LinuSpacing.sm : LinuSpacing.sm, // showHeader 现在总是为 true，所以总是使用 sm
                  bottom: actions.isEmpty ? LinuSpacing.md : LinuSpacing.sm,
                ),
                child: widget.isSelectionMode
                    ? Text(
                        widget.message.content.isEmpty 
                            ? l10n.emptyField 
                            : widget.message.content,
                        style: LinuTextStyles.body.copyWith(
                          color: isDark
                              ? LinuColors.darkSecondaryText
                              : LinuColors.lightSecondaryText,
                          height:
                              1.4, // Card v3: Improved line height for readability
                        ),
                      )
                    : SelectableTextWithMenu(
                        widget.message.content.isEmpty
                            ? l10n.emptyField
                            : widget.message.content,
                        style: LinuTextStyles.body.copyWith(
                          color: isDark
                              ? LinuColors.darkSecondaryText
                              : LinuColors.lightSecondaryText,
                          height: 1.4,
                        ),
                        getTargetBox: () => _contentKey.currentContext?.findRenderObject() as RenderBox?,
                        getContentBox: () => _mediaContentKey.currentContext?.findRenderObject() as RenderBox?,
                        isConversationList: widget.isConversationList,
                        onPinToggle: widget.onPinToggle,
                        onDelete: widget.onDelete,
                        onEnterSelectionMode: widget.onEnterSelectionMode,
                      ),
              ),
            ],
          ),

          // T057: Card-specific action menu using ListTile + Divider + trailing chevron
          // 选择模式下也显示，但不响应点击
          if (actions.isNotEmpty || hasTarget) ...[
            // Subtle divider between content and actions
            Container(
              height: 0.5,
              color: isDark
                  ? LinuColors.darkDivider.withValues(alpha: 0.5)
                  : LinuColors.lightDivider.withValues(alpha: 0.5),
            ),
            // Card action menu with ListTile style
            // 选择模式下禁用点击
            IgnorePointer(
              ignoring: widget.isSelectionMode,
              child: Opacity(
                opacity: widget.isSelectionMode ? 0.5 : 1.0,
                child: CardActionMenu(
                  actions: [
                    ...actions,
                    // 如果有详情链接，在末尾添加 viewDetails action
                    if (hasTarget && widget.onActionTap != null)
                      {
                        'label': l10n.viewDetails,
                        'type': 'navigation',
                        'target': {'url': targetUrl},
                      },
                  ],
                  onActionTap: widget.onActionTap,
                ),
              ),
            ),
          ],
        ],
          ),
        ),
        // 未读标记（右上角浮动，考虑圆角）
        if (widget.showUnread)
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
          // 卡片内容居中
          Expanded(child: Center(child: cardContent)),
        ],
      ),
    );
  }
}

