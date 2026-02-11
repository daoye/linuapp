import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import 'package:app/l10n/app_localizations.dart';

import 'package:app/features/conversations/conversation_list_provider.dart';
import 'package:app/features/conversations/widgets/conversation_group_tile.dart';
import 'package:app/features/conversations/widgets/conversation_message_tile.dart';
import 'package:app/shared/services/action_service.dart';
import 'package:app/shared/services/toast_service.dart';
import 'package:app/shared/services/message_highlight_service.dart';
import 'package:app/shared/widgets/empty_state_with_tutorial.dart';
import 'package:app/shared/widgets/visibility_detector.dart';
import 'package:app/shared/widgets/selection_bottom_bar.dart';
import 'package:app/shared/widgets/confirm_dialog.dart';
import 'package:app/db/database.dart';
import 'package:app/db/database_provider.dart';
import 'package:app/shared/constants.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/utils.dart';
import 'package:app/features/push/ios_message_importer.dart';
import 'package:app/shared/widgets/highlight_wrapper.dart';

class ConversationList extends ConsumerStatefulWidget {
  final String? highlightMessageId;

  const ConversationList({super.key, this.highlightMessageId});

  @override
  ConsumerState<ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends ConsumerState<ConversationList>
    with WidgetsBindingObserver, MessageHighlightMixin {
  bool _isSelectionMode = false;
  final Set<int> _selectedIds = {};
  final ScrollController _scrollController = ScrollController();

  // MessageHighlightMixin 实现
  @override
  String? get currentGroupId => null; // ConversationList 没有 groupId

  @override
  String? get initialHighlightMessageId => widget.highlightMessageId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initHighlight();

    // 初始化时导入待处理消息（iOS）
    if (Platform.isIOS) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _importPendingMessages();
      });
    }
  }

  @override
  void dispose() {
    disposeHighlight();
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(conversationListProvider);
      if (Platform.isIOS) {
        _importPendingMessages();
      }
    }
  }

  Future<void> _importPendingMessages() async {
    try {
      final importer = ref.read(iosMessageImporterProvider);
      await importer.importPendingMessages();
    } catch (e) {
      debugPrint('Failed to import pending messages: $e');
    }
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedIds.clear();
      }
    });
    HapticFeedback.selectionClick();
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
    HapticFeedback.selectionClick();
  }

  void _selectAll(List<ConversationListItem> items) {
    setState(() {
      _selectedIds.clear();
      for (final item in items) {
        _selectedIds.add(item.conversation.id);
      }
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedIds.clear();
    });
  }

  /// 进入选择模式并选中指定会话
  void _enterSelectionModeWithItem(ConversationListItem item) {
    if (!_isSelectionMode) {
      _toggleSelectionMode();
    }
    setState(() {
      _selectedIds.add(item.conversation.id);
    });
    HapticFeedback.selectionClick();
  }

  /// 标记消息为已读
  Future<void> _markMessageAsRead(WidgetRef ref, String messageId) async {
    try {
      final db = ref.read(databaseProvider);
      await (db.update(db.messages)..where((t) => t.id.equals(messageId)))
          .write(const MessagesCompanion(isRead: drift.Value(true)));
    } catch (e) {
      debugPrint('Failed to mark message as read: $e');
    }
  }

  Future<void> _deleteSelected(
    BuildContext context,
    List<ConversationListItem> items,
  ) async {
    if (_selectedIds.isEmpty) return;

    final confirmed = await _showBatchDeleteConfirmation(
      context,
      _selectedIds.length,
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();

      final db = ref.read(databaseProvider);

      for (final id in _selectedIds) {
        final item = items.firstWhere(
          (i) => i.conversation.id == id,
          orElse: () => items.first,
        );

        if (item.conversation.groupId.isNotEmpty) {
          final groupId = item.conversation.groupId;
          // 删除该群组的所有消息
          await (db.delete(db.messages)
                ..where((tbl) => tbl.groupId.equals(groupId)))
              .go();
          // 删除该群组的所有会话记录（可能有多个）
          await (db.delete(db.conversations)
                ..where((tbl) => tbl.groupId.equals(groupId)))
              .go();
          // 删除群组记录
          await (db.delete(db.groups)
                ..where((tbl) => tbl.id.equals(groupId)))
              .go();
        } else {
          // 非群组消息，只删除当前会话
          await (db.delete(db.conversations)
                ..where((tbl) => tbl.id.equals(id)))
              .go();
        }
      }

      setState(() {
        _selectedIds.clear();
        _isSelectionMode = false;
      });
    }
  }

  /// 删除单个会话
  Future<void> _deleteConversation(
    BuildContext context,
    ConversationListItem item,
  ) async {
    final confirmed = await _showDeleteConfirmation(context);

    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();

      final db = ref.read(databaseProvider);

      if (item.conversation.groupId.isNotEmpty) {
        final groupId = item.conversation.groupId;
        // 删除该群组的所有消息
        await (db.delete(db.messages)
              ..where((tbl) => tbl.groupId.equals(groupId)))
            .go();
        // 删除该群组的所有会话记录（可能有多个）
        await (db.delete(db.conversations)
              ..where((tbl) => tbl.groupId.equals(groupId)))
            .go();
        // 删除群组记录
        await (db.delete(db.groups)
              ..where((tbl) => tbl.id.equals(groupId)))
            .go();
      } else {
        // 非群组消息，只删除当前会话
        await (db.delete(db.conversations)
              ..where((tbl) => tbl.id.equals(item.conversation.id)))
            .go();
      }
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    return ConfirmDialog.showDelete(
      context,
      title: l10n.delete,
      content: l10n.deleteConfirmation,
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversationListAsync = ref.watch(conversationListProvider);
    final items = ref.watch(visibleConversationItemsProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark
          ? LinuColors.darkListBackground
          : LinuColors.lightListBackground,
      appBar: _isSelectionMode
          ? _buildSelectionModeAppBar(context, theme, l10n, items)
          : AppBar(
              toolbarHeight: 48,
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(Icons.description_outlined, size: 22),
                tooltip: l10n.docs,
                onPressed: () => context.push('/docs'),
              ),
              title: Text(
                l10n.appTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 22),
                  onPressed: () => context.push('/settings'),
                ),
              ],
            ),
      body: ToastOverlay(
        showCenter: true,
        showBottom: true,
        bottomOffset: 0,
        child: Column(
          children: [
            Expanded(
              child: conversationListAsync.isLoading
                  ? _buildSkeletonList()
                  : items.isEmpty
                  ? const EmptyStateWithTutorial()
                  : _buildConversationList(
                      context,
                      items,
                      bottomPadding,
                      theme,
                      isDark,
                      l10n,
                    ),
            ),
            // 选择模式底部工具栏（自然挤占空间，带动画）
            AnimatedSize(
              duration: AnimationDurations.medium,
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: _isSelectionMode
                  ? _buildSelectionModeBottomBar(context, theme, l10n, items)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    final prefersReducedMotion = AppUtils.prefersReducedMotion(context);
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: LinuSpacing.md,
        vertical: LinuSpacing.sm,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const _ConversationSkeletonItem()
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
  }

  Widget _buildConversationList(
    BuildContext context,
    List<ConversationListItem> items,
    double bottomPadding,
    ThemeData theme,
    bool isDark,
    AppLocalizations l10n,
  ) {
    // 如果有需要高亮的消息，在下一帧滚动到该位置
    if (highlightingMessageId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollToHighlightedMessage();
      });
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // 滚动时立即触发可见性检查
        DelayedVisibilityDetector.notifyVisibilityCheck();
        return false;
      },
      child: GestureDetector(
        onLongPress: () {
          if (!_isSelectionMode && items.isNotEmpty) {
            _enterSelectionModeWithItem(items.first);
          }
        },
        behavior: HitTestBehavior.translucent,
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            LinuSpacing.md,
            LinuSpacing.zero,
            LinuSpacing.md,
            // 选择模式时底部工具栏已有 SafeArea，不需要额外安全区
            _isSelectionMode ? LinuSpacing.sm : bottomPadding,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = _selectedIds.contains(item.conversation.id);
            final messageId = item.message?.id;
            // 只有非 group 类型的消息才在 list 页面高亮
            // group 消息应该跳转到 group detail 页面高亮
            final isGroupConversation = item.conversation.type == 0 && item.group != null;
            final shouldHighlight = !isGroupConversation && messageId != null && messageId == highlightingMessageId;

            // 为需要高亮的消息创建 GlobalKey（仅非 group 类型）
            if (!isGroupConversation && shouldHighlight) {
              messageKeys[messageId] ??= GlobalKey();
            }

            // 根据类型创建对应的卡片
            // type == 0 且有 group 时显示群组卡片（即使没有消息也要显示）
            // 否则显示单条消息卡片
            Widget child;
            if (item.conversation.type == 0 && item.group != null) {
              // 群组会话：即使没有消息也要显示，因为群组有 action 和 reply 功能
              child = ConversationGroupTile(
                group: item.group!,
                lastMessage: item.message,
                isPinned: item.conversation.isPinned,
                isSelectionMode: _isSelectionMode,
                isSelected: isSelected,
                onSelectionTap: () => _toggleSelection(item.conversation.id),
                onPinToggle: () => togglePin(ref, item.conversation.id),
                onDelete: () => _deleteConversation(context, item),
                onEnterSelectionMode: () => _enterSelectionModeWithItem(item),
              );
            } else if (item.message != null) {
              // 单条消息会话
              final message = item.message!;
              final hasUnread = !message.isRead;

              child = DelayedVisibilityDetector(
                key: ValueKey('message_${message.id}'),
                detectorId: 'message_${message.id}',
                visibleDuration: const Duration(seconds: 2),
                onVisible: hasUnread && !_isSelectionMode
                    ? () => _markMessageAsRead(ref, message.id)
                    : null,
                child: ConversationMessageTile(
                  message: message,
                  isPinned: item.conversation.isPinned,
                  onLongPress: () => _enterSelectionModeWithItem(item),
                  onActionTap: _isSelectionMode
                      ? null
                      : (action) =>
                            _handleMessageAction(context, ref, action, message),
                  isSelectionMode: _isSelectionMode,
                  isSelected: isSelected,
                  onSelectionTap: () => _toggleSelection(item.conversation.id),
                  onPinToggle: () => togglePin(ref, item.conversation.id),
                  onDelete: () => _deleteConversation(context, item),
                  onEnterSelectionMode: () => _enterSelectionModeWithItem(item),
                ),
              );
            } else {
              // 既不是群组也没有消息的无效项，跳过
              child = const SizedBox.shrink();
            }

            // 包装高亮效果
            Widget result = Padding(
              padding: EdgeInsets.only(bottom: LinuSpacing.md),
              child: HighlightWrapper(
                key: shouldHighlight ? messageKeys[messageId] : null,
                highlight: shouldHighlight,
                onHighlightEnd: clearHighlight,
                child: child,
              ),
            );

            return result;
          },
        ),
      ),
    );
  }

  /// 检查选中项是否全部为 pin 状态
  bool _areAllSelectedPinned(List<ConversationListItem> items) {
    if (_selectedIds.isEmpty) return false;

    for (final id in _selectedIds) {
      final item = items.firstWhere(
        (i) => i.conversation.id == id,
        orElse: () => items.first,
      );
      if (!item.conversation.isPinned) {
        return false;
      }
    }
    return true;
  }

  /// 批量 pin/unpin 操作
  Future<void> _togglePinSelected(List<ConversationListItem> items) async {
    if (_selectedIds.isEmpty) return;

    final allPinned = _areAllSelectedPinned(items);

    // 如果全部是 pin，则全部 unpin；如果有混合，则全部 pin（只对未 pin 的进行切换）
    for (final id in _selectedIds) {
      final item = items.firstWhere(
        (i) => i.conversation.id == id,
        orElse: () => items.first,
      );
      // 如果全部是 pin，或者当前项未 pin，则切换状态
      if (allPinned || !item.conversation.isPinned) {
        await togglePin(ref, id);
      }
    }

    HapticFeedback.selectionClick();

    // 退出选择模式
    setState(() {
      _selectedIds.clear();
      _isSelectionMode = false;
    });
  }

  /// 构建选择模式的 AppBar
  PreferredSizeWidget _buildSelectionModeAppBar(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    List<ConversationListItem> items,
  ) {
    final selectedCount = _selectedIds.length;
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
    List<ConversationListItem> items,
  ) {
    final selectedCount = _selectedIds.length;
    final allSelected = selectedCount == items.length && items.isNotEmpty;
    final allPinned = _areAllSelectedPinned(items);

    return SelectionBottomBar(
      actions: [
        SelectionAction(
          icon: allPinned ? Icons.push_pin : Icons.push_pin_outlined,
          label: allPinned ? l10n.unpin : l10n.pin,
          onPressed: selectedCount > 0 ? () => _togglePinSelected(items) : null,
          isDisabled: selectedCount == 0,
        ),
        SelectionAction(
          icon: Icons.delete_outline_rounded,
          label: l10n.delete,
          onPressed: selectedCount > 0 ? () => _deleteSelected(context, items) : null,
          isDestructive: true,
          isDisabled: selectedCount == 0,
        ),
        SelectionAction(
          icon: allSelected ? Icons.check_box : Icons.check_box_outline_blank,
          label: allSelected ? l10n.deselectAll : l10n.selectAll,
          onPressed: allSelected ? _deselectAll : () => _selectAll(items),
        ),
      ],
    );
  }

  Future<void> _handleMessageAction(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> action,
    Message message,
  ) async {
    await ActionService.instance.handleMessageAction(
      context,
      ref,
      action,
      messageId: message.id,
      groupId: message.groupId.isNotEmpty ? message.groupId : null,
    );
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
}

class _ConversationSkeletonItem extends StatelessWidget {
  const _ConversationSkeletonItem();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = isDark
        ? LinuColors.darkBorder.withValues(alpha: 0.6)
        : LinuColors.lightBorder.withValues(alpha: 0.8);

    final skeletonColor = isDark
        ? LinuColors.darkBorder.withValues(alpha: 0.3)
        : LinuColors.lightBorder.withValues(alpha: 0.5);

    return Container(
      margin: EdgeInsets.only(bottom: LinuSpacing.sm),
      decoration: BoxDecoration(
        color: isDark
            ? LinuColors.darkCardSurface
            : LinuColors.lightCardSurface,
        borderRadius: BorderRadius.circular(LinuRadius.medium),
        border: Border.all(color: borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText).withValues(
              alpha: 0.08,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: LinuSpacing.lg,
          vertical: LinuSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: skeletonColor,
                borderRadius: BorderRadius.circular(LinuRadius.large),
              ),
            ),
            SizedBox(width: LinuSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(LinuRadius.small),
                    ),
                  ),
                  SizedBox(height: LinuSpacing.sm),
                  Container(
                    height: 12,
                    width: MediaQuery.of(context).size.width * 0.5,
                    decoration: BoxDecoration(
                      color: skeletonColor,
                      borderRadius: BorderRadius.circular(LinuRadius.small),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
