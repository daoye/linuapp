import 'package:flutter/material.dart';
import 'package:app/db/database.dart';
import 'package:app/features/conversation_messages/widgets/template_message_card.dart';

/// Adapter widget that wraps TemplateMessageCard for use in the conversation list.
/// Converts ConversationListItem data into TemplateMessageCard props.
///
/// This is a lightweight adapter layer - all visual and interaction logic
/// is handled by TemplateMessageCard to maintain consistency with the
/// group conversation page.
class ConversationMessageTile extends StatelessWidget {
  final Message message;
  final bool isPinned;
  final VoidCallback? onLongPress;
  final Function(Map<String, dynamic> action)? onActionTap;
  
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

  const ConversationMessageTile({
    super.key,
    required this.message,
    required this.isPinned,
    this.onLongPress,
    this.onActionTap,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onSelectionTap,
    this.onPinToggle,
    this.onDelete,
    this.onEnterSelectionMode,
  });

  @override
  Widget build(BuildContext context) {
    final hasUnread = !message.isRead;
    
    return TemplateMessageCard(
      message: message,
      onActionTap: isSelectionMode ? null : onActionTap,
      isSelectionMode: isSelectionMode,
      isSelected: isSelected,
      onSelectionTap: onSelectionTap,
      onLongPress: onLongPress,
      showDateInCorner: true, // 始终显示日期
      showPin: isPinned, // 始终显示 pin
      showUnread: hasUnread, // 始终显示未读标记
      isConversationList: true, // 这是会话列表页面
      onPinToggle: onPinToggle,
      onDelete: onDelete,
      onEnterSelectionMode: onEnterSelectionMode,
    );
  }
}
