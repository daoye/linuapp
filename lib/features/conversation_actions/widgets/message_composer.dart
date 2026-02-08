import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/db/database.dart';
import 'package:app/db/database_provider.dart';
import 'package:app/features/conversation_actions/webhook_service.dart';
import 'package:app/features/push/push_models.dart';
import 'package:app/features/settings/settings_provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/constants.dart';
import 'package:uuid/uuid.dart';

/// 紧凑型消息输入组件
/// 
/// 设计要点：
/// - 极小的外部 padding，最大化输入区域
/// - 输入框占满高度，自适应多行
/// - 发送按钮紧凑设计
class MessageComposer extends ConsumerStatefulWidget {
  final String groupId;
  final Webhook replyWebhook;
  final Function(bool success)? onReplySent;

  const MessageComposer({
    super.key,
    required this.groupId,
    required this.replyWebhook,
    this.onReplySent,
  });

  @override
  ConsumerState<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends ConsumerState<MessageComposer> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSending = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _onFocusChanged() {
    // 聚焦状态变化时刷新 UI
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // 极小的 padding，最大化输入区域
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 输入框 - 占满剩余空间，高度自适应
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? LinuColors.darkCardSurface.withValues(alpha: 0.08)
                    : LinuColors.lightPrimaryText.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(20),
                border: _focusNode.hasFocus
                    ? Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      )
                    : null,
              ),
            child: TextField(
              controller: _controller,
                focusNode: _focusNode,
              enabled: !_isSending,
              decoration: InputDecoration(
                hintText: l10n.reply,
                  hintStyle: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? LinuColors.darkTertiaryText
                        : LinuColors.lightTertiaryText,
                ),
                  border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                ),
                  isDense: true,
              ),
                style: TextStyle(
                  fontSize: 15,
                  height: 1.3,
                  color: isDark
                      ? LinuColors.darkPrimaryText
                      : LinuColors.lightPrimaryText,
                ),
                minLines: 1,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 发送按钮 - 固定在底部
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: AnimatedContainer(
              duration: AnimationDurations.medium,
              curve: Curves.easeOutCubic,
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _hasText || _isSending
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: _isSending || !_hasText ? null : _sendReply,
                  child: Center(
                    child: _isSending
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.onPrimary,
                            ),
                          )
                        : Icon(
                            Icons.arrow_upward_rounded,
                            size: 20,
                            color: _hasText
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendReply() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    HapticFeedback.lightImpact();

    final db = ref.read(databaseProvider);
    final messageId = const Uuid().v4();

    // 插入消息，状态为"发送中"
    await db.into(db.messages).insert(
          MessagesCompanion.insert(
            id: messageId,
            groupId: Value(widget.groupId),
            content: Value(text),
            createdAt: Value(DateTime.now()),
            isClientSent: const Value(true),
            sendStatus: const Value(1), // 1 = 发送中
          ),
        );

    // 调用 webhook
    final settings = ref.read(settingsProvider);
    final webhookToken = settings.effectiveWebhookToken;
    
    final response = await WebhookService.instance.callWebhook(
      url: widget.replyWebhook.url,
      method: widget.replyWebhook.method,
      body: {
        'device_token': webhookToken,
        'group_id': widget.groupId,
        'type': 'reply',
        'text': text,
      },
    );

    // 根据结果更新发送状态
    await (db.update(db.messages)..where((m) => m.id.equals(messageId)))
        .write(MessagesCompanion(
      sendStatus: Value(response.isSuccess ? 0 : 2), // 0=成功, 2=失败
    ));

    if (mounted) {
      setState(() {
        _isSending = false;
        _hasText = false;
      });
      _controller.clear();
      widget.onReplySent?.call(response.isSuccess);
    }
  }
}
