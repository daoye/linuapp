import 'dart:async';
import 'package:flutter/material.dart';

/// 消息高亮请求
class MessageHighlightRequest {
  final String messageId;
  final String? groupId;

  const MessageHighlightRequest({
    required this.messageId,
    this.groupId,
  });
  
  /// 是否匹配指定的 groupId
  /// - groupId 为 null 表示 ConversationList 页面
  /// - groupId 非空表示 GroupConversation 页面
  bool matchesGroup(String? targetGroupId) {
    if (targetGroupId == null) {
      return groupId == null || groupId!.isEmpty;
    }
    return groupId == targetGroupId;
  }
}

/// 消息高亮服务
/// 
/// 用于在点击通知时，通知当前页面高亮指定消息。
/// 
/// 使用场景：
/// 1. 用户点击通知时，如果已在目标页面，通过此服务广播高亮请求
/// 2. 页面监听此服务，收到匹配的请求后滚动并高亮对应消息
class MessageHighlightService {
  MessageHighlightService._();
  static final instance = MessageHighlightService._();

  final _controller = StreamController<MessageHighlightRequest>.broadcast();

  Stream<MessageHighlightRequest> get onHighlightRequest => _controller.stream;

  void requestHighlight({required String messageId, String? groupId}) {
    _controller.add(MessageHighlightRequest(messageId: messageId, groupId: groupId));
  }

  void dispose() {
    _controller.close();
  }
}

/// 消息高亮 Mixin
/// 
/// 为 ConversationList 和 GroupConversation 提供统一的高亮逻辑
mixin MessageHighlightMixin<T extends StatefulWidget> on State<T> {
  String? highlightingMessageId;
  final Map<String, GlobalKey> messageKeys = {};
  StreamSubscription<MessageHighlightRequest>? _highlightSubscription;
  
  /// 子类需要实现：返回当前页面对应的 groupId（ConversationList 返回 null）
  String? get currentGroupId;
  
  /// 子类需要实现：返回初始的高亮消息 ID（从路由参数获取）
  String? get initialHighlightMessageId;
  
  /// 初始化高亮功能
  void initHighlight() {
    highlightingMessageId = initialHighlightMessageId;
    
    _highlightSubscription = MessageHighlightService.instance.onHighlightRequest.listen((request) {
      if (request.matchesGroup(currentGroupId)) {
        setState(() {
          highlightingMessageId = request.messageId;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToHighlightedMessage();
        });
      }
    });
  }
  
  /// 清理高亮资源
  void disposeHighlight() {
    _highlightSubscription?.cancel();
  }
  
  /// 滚动到高亮消息
  void scrollToHighlightedMessage() {
    if (highlightingMessageId == null) return;
    
    final key = messageKeys[highlightingMessageId];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.3,
      );
    }
  }
  
  /// 获取或创建消息的 GlobalKey
  GlobalKey? getMessageKey(String? messageId, {bool shouldHighlight = false}) {
    if (messageId == null) return null;
    if (shouldHighlight && highlightingMessageId == messageId) {
      return messageKeys[messageId] ??= GlobalKey();
    }
    return messageKeys[messageId];
  }
  
  /// 清除高亮状态
  void clearHighlight() {
    if (mounted) {
      setState(() => highlightingMessageId = null);
    }
  }
}
