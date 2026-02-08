import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app/db/database.dart';
import 'package:app/db/database_provider.dart';
import 'package:app/features/messages/encrypted_messages_provider.dart';
import 'package:app/shared/services/toast_service.dart';
import 'package:app/shared/widgets/confirm_dialog.dart';
import 'package:app/shared/widgets/empty_state.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/constants.dart';
import 'package:app/l10n/app_localizations.dart';

/// 待解密消息页面
/// 显示所有解密失败的消息，支持重试和删除
class EncryptedMessagesPage extends ConsumerWidget {
  const EncryptedMessagesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(encryptedMessagesProvider);
    final retryState = ref.watch(retryStateProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? LinuColors.darkListBackground
          : LinuColors.lightListBackground,
      appBar: AppBar(
        title: Text(l10n.encryptedMessages),
        actions: [
          if (!retryState.isRetrying)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: l10n.retryAll,
              onPressed: () => _retryAll(context, ref, l10n),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: l10n.deleteAll,
            onPressed: () => _deleteAll(context, ref, l10n),
          ),
        ],
      ),
      body: messagesAsync.when(
        data: (messages) {
          if (messages.isEmpty) {
            return _buildEmptyState(context, theme, isDark, l10n);
          }
          return _buildMessageList(context, ref, messages, retryState.isRetrying, theme, isDark);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: LinuSpacing.lg),
              Text(
                l10n.error,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: LinuSpacing.xs),
              Text(
                error.toString(),
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isDark, AppLocalizations l10n) {
    return EmptyState(
      title: l10n.noEncryptedMessages,
      description: l10n.allMessagesDecrypted,
      icon: Icons.lock_open_rounded,
    );
  }

  Widget _buildMessageList(
    BuildContext context,
    WidgetRef ref,
    List<EncryptedMessage> messages,
    bool isRetrying,
    ThemeData theme,
    bool isDark,
  ) {
    final prefersReducedMotion =
        MediaQuery.of(context).disableAnimations;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(
        LinuSpacing.md,
        LinuSpacing.md,
        LinuSpacing.md,
        MediaQuery.of(context).padding.bottom + LinuSpacing.md,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final tile = _EncryptedMessageTile(
          key: ValueKey(msg.id),
          message: msg,
          enabled: !isRetrying,
          onRetry: () => _retrySingle(context, ref, msg.id),
          onDelete: () => _deleteSingle(context, ref, msg.id),
          theme: theme,
          isDark: isDark,
          l10n: AppLocalizations.of(context)!,
        );

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < messages.length - 1 ? LinuSpacing.md : 0,
          ),
          child: prefersReducedMotion
              ? tile
              : tile
                  .animate()
                  .fadeIn(
                    duration: AnimationDurations.standard,
                    delay: Duration(milliseconds: 50 * index.clamp(0, 8)),
                    curve: Curves.easeOut,
                  )
                  .slideY(
                    begin: 0.05,
                    end: 0,
                    duration: AnimationDurations.standard,
                    delay: Duration(milliseconds: 50 * index.clamp(0, 8)),
                    curve: Curves.easeOut,
                  ),
        );
      },
    );
  }

  Future<void> _retryAll(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.retryAllMessages,
      content: l10n.retryAllMessagesConfirm,
    );

    if (confirmed == true && context.mounted) {
      await ref.read(retryStateProvider.notifier).retryAll();
      
      final result = ref.read(retryStateProvider).lastResult;
      if (result != null && context.mounted) {
        ToastService.instance.showCenter(
          l10n.retryComplete(result.success, result.failed),
          false,
          isSuccess: true,
        );
      }
    }
  }

  Future<void> _retrySingle(BuildContext context, WidgetRef ref, String id) async {
    final l10n = AppLocalizations.of(context)!;
    final success = await ref.read(retryStateProvider.notifier).retrySingle(id);
    
    if (context.mounted) {
      final theme = Theme.of(context);
      ToastService.instance.showCenter(
        success ? l10n.decryptionSuccess : l10n.decryptionFailed,
        false,
        isSuccess: success,
        backgroundColor: success ? theme.colorScheme.primary : theme.colorScheme.error,
        icon: success ? Icons.check_circle : Icons.error,
      );
    }
  }

  Future<void> _deleteSingle(BuildContext context, WidgetRef ref, String id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await ConfirmDialog.showDelete(
      context,
      title: l10n.deleteMessage,
      content: l10n.deleteMessageConfirm,
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.deleteEncryptedMessage(id);
      
      if (context.mounted) {
        ToastService.instance.showCenter(
          l10n.messageDeleted,
          false,
          isSuccess: true,
        );
      }
    }
  }

  Future<void> _deleteAll(BuildContext context, WidgetRef ref, AppLocalizations l10n) async {
    final confirmed = await ConfirmDialog.showDelete(
      context,
      title: l10n.deleteAllMessages,
      content: l10n.deleteAllMessagesConfirm,
      confirmText: l10n.deleteAll,
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.deleteAllEncryptedMessages();
      
      if (context.mounted) {
        ToastService.instance.showCenter(
          l10n.allMessagesDeleted,
          false,
          isSuccess: true,
        );
      }
    }
  }
}

/// 单条待解密消息 Tile
class _EncryptedMessageTile extends StatelessWidget {
  final EncryptedMessage message;
  final bool enabled;
  final VoidCallback onRetry;
  final VoidCallback onDelete;
  final ThemeData theme;
  final bool isDark;
  final AppLocalizations l10n;

  const _EncryptedMessageTile({
    super.key,
    required this.message,
    required this.enabled,
    required this.onRetry,
    required this.onDelete,
    required this.theme,
    required this.isDark,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final dateFormat = DateFormat.yMd(locale.toString()).add_Hm();

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? LinuColors.darkCardSurface
            : LinuColors.lightCardSurface,
        borderRadius: BorderRadius.circular(LinuRadius.medium),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: LinuSpacing.md,
          vertical: LinuSpacing.xs,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: LinuColors.warning.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(LinuRadius.small),
          ),
          child: Icon(
            Icons.lock_rounded,
            size: 20,
            color: LinuColors.warning,
          ),
        ),
        title: Text(
          dateFormat.format(message.receivedAt),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: SelectableText(
          message.id,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: enabled ? onDelete : null,
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: theme.colorScheme.error.withValues(alpha: 0.8),
              ),
              tooltip: l10n.delete,
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              onPressed: enabled ? onRetry : null,
              icon: Icon(
                Icons.refresh_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              tooltip: l10n.retry,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
