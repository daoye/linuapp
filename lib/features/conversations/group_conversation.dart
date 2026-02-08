import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/features/conversation_messages/conversation_messages_provider.dart';
import 'package:app/features/conversation_messages/widgets/template_message_card.dart';
import 'package:app/features/conversation_messages/widgets/message_bubble.dart';
import 'package:app/features/conversation_actions/widgets/conversation_action_bar.dart';
import 'package:app/features/conversation_actions/widgets/message_composer.dart';
import 'package:app/features/conversation_actions/webhook_service.dart';
import 'package:app/features/push/push_models.dart';
import 'package:app/features/settings/settings_provider.dart';
import 'package:app/shared/services/action_service.dart';
import 'package:app/shared/services/toast_service.dart';
import 'package:app/shared/services/message_highlight_service.dart';
import 'package:app/shared/widgets/empty_state.dart';
import 'package:app/shared/widgets/selection_bottom_bar.dart';
import 'package:app/shared/widgets/confirm_dialog.dart';
import 'package:app/shared/utils.dart';
import 'package:app/db/database.dart';
import 'package:app/db/database_provider.dart';
import 'package:app/shared/constants.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/widgets/highlight_wrapper.dart';
import 'package:app/shared/widgets/gradient_divider.dart';
import 'package:drift/drift.dart' as drift;

class GroupConversation extends ConsumerStatefulWidget {
  final String groupId;
  final String? highlightMessageId;

  const GroupConversation({
    super.key,
    required this.groupId,
    this.highlightMessageId,
  });

  @override
  ConsumerState<GroupConversation> createState() => _GroupConversationState();
}

class _GroupConversationState extends ConsumerState<GroupConversation> 
    with MessageHighlightMixin {
  final ScrollController _scrollController = ScrollController();
  bool _showMenu = true;
  bool _isSelectionMode = false;
  final Set<String> _selectedMessageIds = {};
  bool _hasMarkedAsRead = false;

  // MessageHighlightMixin 实现
  @override
  String? get currentGroupId => widget.groupId;
  
  @override
  String? get initialHighlightMessageId => widget.highlightMessageId;

  @override
  void initState() {
    super.initState();
    initHighlight();
  }

  @override
  void dispose() {
    disposeHighlight();
    _scrollController.dispose();
    super.dispose();
  }

  /// 标记该 group 的所有消息为已读
  Future<void> _markMessagesAsRead() async {
    if (_hasMarkedAsRead) return;

    try {
      final db = ref.read(databaseProvider);
      await db.markGroupMessagesAsRead(widget.groupId);
      _hasMarkedAsRead = true;
    } catch (e) {
      debugPrint('Failed to mark messages as read: $e');
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedMessageIds.clear();
      }
    });
    HapticFeedback.selectionClick();
  }

  void _toggleSelection(String messageId) {
    setState(() {
      if (_selectedMessageIds.contains(messageId)) {
        _selectedMessageIds.remove(messageId);
      } else {
        _selectedMessageIds.add(messageId);
      }
    });
    HapticFeedback.selectionClick();
  }

  void _selectAll(List<Message> messages) {
    setState(() {
      _selectedMessageIds.clear();
      for (final msg in messages) {
        _selectedMessageIds.add(msg.id);
      }
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedMessageIds.clear();
    });
  }

  Future<void> _deleteSelected(BuildContext context) async {
    if (_selectedMessageIds.isEmpty) return;

    final confirmed = await _showBatchDeleteConfirmation(
      context,
      _selectedMessageIds.length,
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();

      final db = ref.read(databaseProvider);

      for (final id in _selectedMessageIds) {
        await _deleteMessageById(id, db);
      }

      setState(() {
        _selectedMessageIds.clear();
        _isSelectionMode = false;
      });
    }
  }

  Future<bool?> _showBatchDeleteConfirmation(
    BuildContext context,
    int count,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    return ConfirmDialog.showDelete(
      context,
      title: l10n.deleteSelected,
      content: '${l10n.deleteConfirmation}\n\n${l10n.itemsSelected(count)}',
    );
  }

  Future<bool?> _showDeleteConfirmation(
    BuildContext context,
    Message message,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    return ConfirmDialog.showDelete(
      context,
      title: l10n.delete,
      content: l10n.deleteConfirmation,
    );
  }

  /// 进入选择模式并选中指定消息
  void _enterSelectionModeWithMessage(Message message) {
    if (!_isSelectionMode) {
      _toggleSelectionMode();
    }
    setState(() {
      _selectedMessageIds.add(message.id);
    });
    HapticFeedback.selectionClick();
  }

  Future<void> _deleteMessageById(String messageId, AppDatabase db) async {
    // 先获取消息信息
    final message = await (db.select(
      db.messages,
    )..where((tbl) => tbl.id.equals(messageId))).getSingleOrNull();

    if (message == null) return;

    final groupId = message.groupId;

    // 删除消息
    await (db.delete(
      db.messages,
    )..where((tbl) => tbl.id.equals(messageId))).go();

    // 查找该 group 最新的剩余消息
    final latest =
        await (db.select(db.messages)
              ..where((t) => t.groupId.equals(groupId))
              ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)])
              ..limit(1))
            .getSingleOrNull();

    if (latest != null) {
      // 更新 conversations 表的 message_id 指向最新消息
      await (db.update(db.conversations)
            ..where((t) => t.groupId.equals(groupId)))
          .write(ConversationsCompanion(messageId: drift.Value(latest.id)));
    } else {
      // 没有剩余消息，保留 conversation 但清空 message_id
      await (db.update(db.conversations)
            ..where((t) => t.groupId.equals(groupId)))
          .write(const ConversationsCompanion(messageId: drift.Value('')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final groupAsync = ref.watch(groupConversationProvider(widget.groupId));
    final messagesAsync = ref.watch(
      groupConversationMessagesProvider(widget.groupId),
    );

    // 监听消息变化，当消息加载完成后标记为已读
    ref.listen(groupConversationMessagesProvider(widget.groupId), (
      previous,
      next,
    ) {
      next.whenData((messages) {
        if (messages.isNotEmpty && !_hasMarkedAsRead) {
          _markMessagesAsRead();
        }
      });
    });

    return Scaffold(
      appBar: _isSelectionMode
          ? _buildSelectionModeAppBar(context, theme, l10n, messagesAsync)
          : AppBar(
              toolbarHeight: 48,
              centerTitle: true,
              title: groupAsync.when(
                data: (group) => Text(
                  (group?.name.isNotEmpty ?? false)
                      ? group!.name
                      : l10n.defaultGroupName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading: () => Text(
                  l10n.groupConversationFallback,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                error: (err, stack) => Text(
                  l10n.groupConversationFallback,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
      body: ToastOverlay(
        showCenter: true,
        showBottom: true,
        bottomOffset: _minBottomBarHeight + LinuSpacing.md,
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                loading: () {
                  final prefersReducedMotion =
                      AppUtils.prefersReducedMotion(context);
                  return ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return const _ChatSkeletonItem()
                          .animate()
                          .fadeIn(
                            duration: prefersReducedMotion
                                ? 0.ms
                                : AnimationDurations.fast,
                            delay: prefersReducedMotion ? 0.ms : (index * 40).ms,
                          )
                          .shimmer(duration: AnimationDurations.shimmer);
                    },
                  );
                },
                error: (err, stack) => Center(child: Text('${l10n.error}: $err')),
                data: (messages) {
                  // 检查 group 是否有 actions 或 reply 配置
                  final hasGroupConfig = groupAsync.maybeWhen(
                    data: (group) {
                      if (group == null) return false;
                      return group.actions.isNotEmpty || group.replyWebhook.isNotEmpty;
                    },
                    orElse: () => false,
                  );

                  // 消息为空且没有 group config 时，显示简单的空状态
                  if (messages.isEmpty && !hasGroupConfig) {
                    return EmptyState(
                      title: l10n.noMessagesInConversation,
                      description: l10n.noMessagesInConversationDescription,
                      icon: Icons.notifications_none_rounded,
                    );
                  }

                  // 如果有需要高亮的消息，在下一帧滚动到该位置
                  if (highlightingMessageId != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      scrollToHighlightedMessage();
                    });
                  }

                  // 检查是否有底部栏（非选择模式时的 bottombar 或选择模式的工具栏）
                  final hasAnyBottomBar = _isSelectionMode || groupAsync.maybeWhen(
                    data: (group) {
                      if (group == null) return false;
                      final menuJson = group.actions;
                      final replyUrl = group.replyWebhook;
                      return menuJson.isNotEmpty || replyUrl.isNotEmpty;
                    },
                    orElse: () => false,
                  );

                  // 获取底部安全区高度
                  final bottomSafeArea = MediaQuery.of(context).padding.bottom;
                  // 计算底部 padding：有底部栏时只需基本间距，否则需要安全区
                  final listViewBottomPadding = hasAnyBottomBar
                      ? LinuSpacing.lg
                      : LinuSpacing.lg + bottomSafeArea;

                  return Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Theme.of(context).brightness == Brightness.light
                              ? LinuColors.lightChatBackground
                              : LinuColors.darkChatBackground,
                          child: messages.isEmpty
                              // 消息为空但有 group config，显示空状态
                              ? EmptyState(
                                  title: l10n.noMessagesInConversation,
                                  description: l10n.noMessagesInConversationDescription,
                                  icon: Icons.notifications_none_rounded,
                                )
                              : GestureDetector(
                                  onLongPress: () {
                                    if (!_isSelectionMode && messages.isNotEmpty) {
                                      _enterSelectionModeWithMessage(messages.first);
                                    }
                                  },
                                  behavior: HitTestBehavior.translucent,
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    child: ListView.builder(
                                      reverse: true,
                                      shrinkWrap: true,
                                      controller: _scrollController,
                                      padding: EdgeInsets.fromLTRB(
                                        LinuSpacing.md,
                                        LinuSpacing.lg,
                                        LinuSpacing.md,
                                        listViewBottomPadding,
                                      ),
                                      itemCount: messages.length,
                                      itemBuilder: (context, index) {
                                        final message = messages[index];
                                        final position = _calculateBubblePosition(
                                          messages,
                                          index,
                                        );
                                        final replyWebhook = groupAsync.maybeWhen(
                                          data: (group) => Webhook.fromJson(group?.replyWebhook),
                                          orElse: () => null,
                                        );
                                        return _buildMessageItem(
                                          context,
                                          message,
                                          position,
                                          theme,
                                          replyWebhook: replyWebhook,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      // Bottom bar（仅在非选择模式时显示）
                      if (!_isSelectionMode)
                        groupAsync.when(
                          data: (group) => _buildBottomBar(group),
                          loading: () => const SizedBox.shrink(),
                          error: (err, stack) => const SizedBox.shrink(),
                        ),
                    ],
                  );
                },
              ),
            ),
            // 选择模式底部工具栏（自然挤占空间，带动画）
            AnimatedSize(
              duration: AnimationDurations.medium,
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: _isSelectionMode
                  ? _buildSelectionModeBottomBar(context, theme, l10n, messagesAsync)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  /// Calculate the position of a bubble within a consecutive message group
  BubblePosition _calculateBubblePosition(List<Message> messages, int index) {
    final message = messages[index];

    if (!_isPlainTextBubble(message)) {
      return BubblePosition.standalone;
    }

    final isClient = message.isClientSent;

    Message? below;
    if (index > 0) {
      below = messages[index - 1];
    }

    Message? above;
    if (index < messages.length - 1) {
      above = messages[index + 1];
    }

    final hasSameSenderBelow =
        below != null &&
        below.isClientSent == isClient &&
        _isPlainTextBubble(below) &&
        _isCloseInTime(below, message);

    final hasSameSenderAbove =
        above != null &&
        above.isClientSent == isClient &&
        _isPlainTextBubble(above) &&
        _isCloseInTime(above, message);

    if (hasSameSenderBelow && hasSameSenderAbove) {
      return BubblePosition.middle;
    } else if (hasSameSenderBelow && !hasSameSenderAbove) {
      return BubblePosition.first;
    } else if (!hasSameSenderBelow && hasSameSenderAbove) {
      return BubblePosition.last;
    } else {
      return BubblePosition.standalone;
    }
  }

  bool _isPlainTextBubble(Message message) {
    // 只有客户端消息才使用气泡显示
    return message.isClientSent;
  }

  bool _isCloseInTime(Message a, Message b) {
    final at = a.createdAt;
    final bt = b.createdAt;

    return at.year == bt.year &&
        at.month == bt.month &&
        at.day == bt.day &&
        at.hour == bt.hour &&
        at.minute == bt.minute;
  }

  Widget _buildMessageItem(
    BuildContext context,
    Message message,
    BubblePosition position,
    ThemeData theme, {
    Webhook? replyWebhook,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final isSelected = _selectedMessageIds.contains(message.id);
    final l10n = AppLocalizations.of(context)!;
    final shouldHighlight = message.id == highlightingMessageId;

    // 为需要高亮的消息创建 GlobalKey
    if (shouldHighlight) {
      messageKeys[message.id] ??= GlobalKey();
    }

    final showTimestamp =
        position == BubblePosition.standalone ||
        position == BubblePosition.last;

    // 计算垂直边距
    double topPadding;
    double bottomPadding;
    switch (position) {
      case BubblePosition.standalone:
        topPadding = LinuSpacing.xs;
        bottomPadding = LinuSpacing.xs;
      case BubblePosition.first:
        topPadding = LinuSpacing.xs;
        bottomPadding = LinuSpacing.xs / 2;
      case BubblePosition.middle:
        topPadding = LinuSpacing.xs / 2;
        bottomPadding = LinuSpacing.xs / 2;
      case BubblePosition.last:
        topPadding = LinuSpacing.xs / 2;
        bottomPadding = LinuSpacing.xs;
    }

    // 服务端推送的消息统一使用卡片显示
    if (!message.isClientSent) {
      return HighlightWrapper(
        key: shouldHighlight ? messageKeys[message.id] : null,
        highlight: shouldHighlight,
        onHighlightEnd: clearHighlight,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: LinuSpacing.sm),
          child: TemplateMessageCard(
            message: message,
            onActionTap: _isSelectionMode
                ? null
                : (action) => _handleAction(message, action),
            isSelectionMode: _isSelectionMode,
            isSelected: isSelected,
            onSelectionTap: () => _toggleSelection(message.id),
            onLongPress: () => _enterSelectionModeWithMessage(message),
            showDateInCorner: true,
            isConversationList: false,
            onDelete: () async {
              final confirmed = await _showDeleteConfirmation(context, message);
              if (confirmed == true && context.mounted) {
                HapticFeedback.mediumImpact();
                final db = ref.read(databaseProvider);
                await _deleteMessageById(message.id, db);
              }
            },
            onEnterSelectionMode: () => _enterSelectionModeWithMessage(message),
          ),
        ),
      );
    }

    // 客户端消息使用气泡显示
    return HighlightWrapper(
      key: shouldHighlight ? messageKeys[message.id] : null,
      highlight: shouldHighlight,
      onHighlightEnd: clearHighlight,
      child: Padding(
        padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            MessageBubble(
              message: message,
              position: position,
              showTimestamp: false,
              isSelectionMode: _isSelectionMode,
              isSelected: isSelected,
              onSelectionTap: () => _toggleSelection(message.id),
              onLongPress: () => _enterSelectionModeWithMessage(message),
              isConversationList: false, // group conversation 不是会话列表
              onDelete: () async {
                final confirmed = await _showDeleteConfirmation(context, message);
                if (confirmed == true && context.mounted) {
                  HapticFeedback.mediumImpact();
                  final db = ref.read(databaseProvider);
                  await _deleteMessageById(message.id, db);
                }
              },
              onEnterSelectionMode: () => _enterSelectionModeWithMessage(message),
              onRetry: replyWebhook != null
                  ? () => _retryMessage(message, replyWebhook)
                  : null,
            ),
            if (showTimestamp)
              Padding(
                padding: EdgeInsets.only(
                  top: LinuSpacing.xs,
                  left: message.isClientSent ? 0 : LinuSpacing.sm + (_isSelectionMode ? 30 : 0),
                  right: message.isClientSent ? LinuSpacing.sm : 0,
                ),
                child: Text(
                  AppUtils.formatDateTime(
                    message.createdAt,
                    yesterday: l10n.yesterday,
                    locale: Localizations.localeOf(context).toString(),
                  ),
                  style: LinuTextStyles.caption.copyWith(
                    color: isDark
                        ? LinuColors.darkTertiaryText
                        : LinuColors.lightTertiaryText,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 重试发送消息
  Future<void> _retryMessage(Message message, Webhook webhook) async {
    final db = ref.read(databaseProvider);

    // 更新状态为"发送中"
    await (db.update(db.messages)..where((m) => m.id.equals(message.id)))
        .write(const MessagesCompanion(sendStatus: drift.Value(1)));

    HapticFeedback.lightImpact();

    // 调用 webhook
    final settings = ref.read(settingsProvider);
    final webhookToken = settings.effectiveWebhookToken;

    final response = await WebhookService.instance.callWebhook(
      url: webhook.url,
      method: webhook.method,
      body: {
        'device_token': webhookToken,
        'group_id': widget.groupId,
        'type': 'reply',
        'text': message.content,
      },
    );

    // 根据结果更新发送状态
    await (db.update(db.messages)..where((m) => m.id.equals(message.id)))
        .write(MessagesCompanion(
      sendStatus: drift.Value(response.isSuccess ? 0 : 2),
    ));

    if (response.message != null && response.message!.isNotEmpty) {
      ToastService.instance.showBottom(
        response.message!,
        false,
        isSuccess: response.isSuccess,
      );
    }
  }

  static const double _minBottomBarHeight = 56.0;

  /// 构建选择模式的 AppBar
  PreferredSizeWidget _buildSelectionModeAppBar(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    AsyncValue<List<Message>> messagesAsync,
  ) {
    final selectedCount = _selectedMessageIds.length;
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      toolbarHeight: 48,
      leading: TextButton(
        onPressed: _toggleSelectionMode,
        child: Text(
          l10n.cancel,
          style: LinuTextStyles.body.copyWith(
            color: isDark
                ? LinuColors.darkPrimaryText
                : LinuColors.lightPrimaryText,
          ),
        ),
      ),
      leadingWidth: 80,
      title: Text(
        l10n.itemsSelected(selectedCount),
        style: LinuTextStyles.title.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark
              ? LinuColors.darkPrimaryText
              : LinuColors.lightPrimaryText,
        ),
      ),
      centerTitle: true,
    );
  }

  /// 构建选择模式的底部浮动层
  Widget _buildSelectionModeBottomBar(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    AsyncValue<List<Message>> messagesAsync,
  ) {
    final selectedCount = _selectedMessageIds.length;
    final allSelected = messagesAsync.maybeWhen(
      data: (messages) =>
          selectedCount == messages.length && messages.isNotEmpty,
      orElse: () => false,
    );

    return messagesAsync.maybeWhen(
      data: (messages) => SelectionBottomBar(
        actions: [
          SelectionAction(
            icon: Icons.delete_outline_rounded,
            label: l10n.delete,
            onPressed: selectedCount > 0 ? () => _deleteSelected(context) : null,
            isDestructive: true,
            isDisabled: selectedCount == 0,
          ),
          SelectionAction(
            icon: allSelected ? Icons.check_box : Icons.check_box_outline_blank,
            label: allSelected ? l10n.deselectAll : l10n.selectAll,
            onPressed: allSelected ? _deselectAll : () => _selectAll(messages),
          ),
        ],
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildBottomBar(Group? group) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final menuJson = group?.actions ?? '';
    final replyWebhook = Webhook.fromJson(group?.replyWebhook);

    final hasMenu = menuJson.isNotEmpty;
    final hasReply = replyWebhook != null;

    if (!hasMenu && !hasReply) {
      return const SizedBox.shrink();
    }

    final bool showMenu = hasMenu && (_showMenu || !hasReply);
    final bool showModeSwitch = hasMenu && hasReply;

    // 根据当前模式决定显示的内容
    Widget content;
    if (showMenu) {
      content = ConversationActionBar(
        menuConfigJson: menuJson,
        groupId: widget.groupId,
        onActionStatusChanged: _handleGroupMenuStatusChange,
      );
    } else if (replyWebhook != null) {
      content = MessageComposer(
        groupId: widget.groupId,
        replyWebhook: replyWebhook,
      );
    } else {
      content = const SizedBox.shrink();
    }

    return Container(
      color: isDark
          ? LinuColors.darkBottomBarBackground
          : LinuColors.lightBottomBarBackground,
      child: SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(minHeight: _minBottomBarHeight),
          padding: const EdgeInsets.symmetric(horizontal: 4),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 模式切换按钮
              if (showModeSwitch) ...[
                SizedBox(
                  width: 44,
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        splashColor: theme.colorScheme.primary.withValues(
                          alpha: 0.1,
                        ),
                        highlightColor: theme.colorScheme.onSurface.withValues(
                          alpha: 0.05,
                        ),
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _showMenu = !_showMenu);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: AnimatedSwitcher(
                            duration: AnimationDurations.medium,
                            transitionBuilder: (child, animation) {
                              return RotationTransition(
                                turns: Tween(
                                  begin: 0.25,
                                  end: 0.0,
                                ).animate(animation),
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Icon(
                              showMenu
                                  ? Icons.keyboard_rounded
                                  : Icons.apps_rounded,
                              key: ValueKey(showMenu),
                              size: 22,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // 分割线 - 分隔模式切换按钮和 action 菜单
                if (showMenu) const GradientDivider(),
              ],
              // 内容区域 - 直接切换，不用动画避免位置问题
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAction(
    Message message,
    Map<String, dynamic> action,
  ) async {
    await ActionService.instance.handleMessageAction(
      context,
      ref,
      action,
      messageId: message.id,
      groupId: widget.groupId,
    );
  }

  void _handleGroupMenuStatusChange(
    String actionLabel,
    bool isLoading,
    bool? success,
  ) {
    ToastService.instance.showBottom(
      actionLabel,
      isLoading,
      isSuccess: success,
    );
  }
}

class _ChatSkeletonItem extends StatelessWidget {
  const _ChatSkeletonItem();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: LinuSpacing.lg,
        vertical: LinuSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? LinuColors.darkCardSurface
                  : LinuColors.lightCardSurface,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: LinuSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? LinuColors.darkCardSurface
                        : LinuColors.lightCardSurface,
                    borderRadius: BorderRadius.circular(LinuRadius.medium),
                  ),
                ),
                SizedBox(height: LinuSpacing.sm),
                Container(
                  height: 14,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    color: isDark
                        ? LinuColors.darkCardSurface
                        : LinuColors.lightCardSurface,
                    borderRadius: BorderRadius.circular(LinuRadius.medium),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
