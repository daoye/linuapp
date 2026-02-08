import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/settings/key_manager.dart';
import 'package:app/features/messages/encrypted_messages_provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/shared/services/toast_service.dart';
import 'package:app/shared/services/biometric_auth_service.dart';
import 'package:app/shared/widgets/faq_sheet.dart';
import 'package:app/shared/widgets/confirm_dialog.dart';

/// 密钥管理组件
///
/// 提供端到端加密密钥的管理功能（仅限付费用户）：
/// - 生成新密钥
/// - 导入现有密钥
/// - 查看/复制密钥
/// - 删除密钥
class KeyManagementWidget extends ConsumerStatefulWidget {
  const KeyManagementWidget({super.key});

  @override
  ConsumerState<KeyManagementWidget> createState() =>
      _KeyManagementWidgetState();
}

class _KeyManagementWidgetState extends ConsumerState<KeyManagementWidget> {
  bool _isRevealed = false;
  String? _cachedKey;

  /// 根据错误类型获取本地化错误消息
  String _getAuthErrorMessage(AuthErrorType errorType, AppLocalizations l10n) {
    switch (errorType) {
      case AuthErrorType.noCredentialsSet:
        return l10n.authNoCredentials;
      case AuthErrorType.noBiometricsEnrolled:
        return l10n.authNotAvailable;
      case AuthErrorType.notAvailable:
        return l10n.authNotAvailable;
      case AuthErrorType.locked:
        return l10n.authFailed;
      case AuthErrorType.canceled:
        return l10n.authCancelled;
      default:
        return l10n.authFailed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final keyAsync = ref.watch(encryptionKeyProvider);

    return keyAsync.when(
      data: (key) => _buildCard(context, theme, l10n, hasKey: key != null),
      loading: () => _buildCard(context, theme, l10n, isLoading: true),
      error: (_, _) => _buildCard(context, theme, l10n, hasKey: false),
    );
  }

  /// 主卡片
  Widget _buildCard(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n, {
    bool hasKey = false,
    bool isLoading = false,
  }) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: Icon(hasKey ? Icons.key_rounded : Icons.key_off_rounded),
            title: Text(l10n.e2eEncryption),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert_rounded),
              onPressed: () => _showActionsSheet(context, l10n, hasKey: hasKey),
            ),
          ),

          // Key display (when configured)
          if (hasKey && !isLoading) _buildKeyDisplay(context, theme, l10n),

          // Loading state
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(LinuSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),

          // Empty state prompt
          if (!hasKey && !isLoading) _buildEmptyPrompt(context, theme, l10n),

          // Divider before common entries
          if (hasKey || !isLoading) const Divider(height: 1),

          // 待解密消息入口 - 始终显示
          _buildEncryptedMessagesEntry(context, theme, l10n),

          // FAQ 入口 - 始终显示
          ListTile(
            dense: true,
            leading: Icon(
              Icons.help_outline_rounded,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            title: Text(l10n.e2eFaq, style: theme.textTheme.bodyMedium),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => _showFaqSheet(context, l10n),
          ),
        ],
      ),
    );
  }

  /// 密钥显示区域
  Widget _buildKeyDisplay(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LinuSpacing.lg,
        0,
        LinuSpacing.lg,
        LinuSpacing.lg,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LinuSpacing.md,
          vertical: LinuSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(LinuRadius.medium),
        ),
        child: Row(
          children: [
            Expanded(
              child: _cachedKey == null
                  ? Text(
                      '••••••••••••',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : _isRevealed
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText(
                        _cachedKey!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Text(
                      '••••••••••••',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: LinuSpacing.xs),
            IconButton(
              icon: Icon(
                _isRevealed
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 20,
              ),
              onPressed: () {
                if (_cachedKey == null) {
                  _viewKey(context, l10n);
                } else {
                  setState(() {
                    _isRevealed = !_isRevealed;
                    if (!_isRevealed) {
                      _cachedKey = null;
                    }
                  });
                }
              },
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              onPressed: () => _copyKey(context, l10n),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  /// 查看密钥（需要身份认证）
  Future<void> _viewKey(BuildContext context, AppLocalizations l10n) async {
    if (_cachedKey != null) {
      setState(() => _isRevealed = true);
      return;
    }

    // exportKey() 内部已经有身份认证，这里不需要再次认证
    try {
      final key = await ref
          .read(keyManagerProvider)
          .exportKey(authReason: l10n.authReason);
      if (key != null) {
        setState(() {
          _cachedKey = key;
          _isRevealed = true;
        });
      } else {
        if (!context.mounted) return;
        ToastService.instance.showCenter(
          l10n.authCancelled,
          false,
          isSuccess: false,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      if (e is AuthenticationException) {
        ToastService.instance.showCenter(
          _getAuthErrorMessage(e.errorType, l10n),
          false,
          isSuccess: false,
        );
      } else {
        ToastService.instance.showCenter(
          l10n.authFailed,
          false,
          isSuccess: false,
        );
      }
    }
  }

  /// 空状态提示（紧凑设计）
  Widget _buildEmptyPrompt(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LinuSpacing.lg,
        vertical: LinuSpacing.md, // 减少垂直间距
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: LinuSpacing.md,
          vertical: LinuSpacing.sm,
      ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(LinuRadius.medium),
        ),
        constraints: BoxConstraints(minHeight: 40),
        child: Center(
          child: Text.rich(
            TextSpan(
        children: [
                TextSpan(
                  text: l10n.e2eEncryptionEmptyDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
                WidgetSpan(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _showActionsSheet(context, l10n, hasKey: false),
                    child: Text(
                      l10n.setupKey,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
          ),
        ],
            ),
          ),
        ),
      ),
    );
  }

  /// 操作菜单
  void _showActionsSheet(
    BuildContext context,
    AppLocalizations l10n, {
    required bool hasKey,
  }) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: LinuSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 密钥操作
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(LinuSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(LinuRadius.medium),
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    size: 20,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(l10n.generateKey),
                subtitle: Text(
                  l10n.generateKeyDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _handleGenerateKey(context, l10n, hasKey: hasKey);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(LinuSpacing.sm),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(LinuRadius.medium),
                  ),
                  child: Icon(
                    Icons.download_rounded,
                    size: 20,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                title: Text(l10n.importKey),
                subtitle: Text(
                  l10n.importKeyDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _handleImportKey(context, l10n, hasKey: hasKey);
                },
              ),
              // 危险操作区域
              if (hasKey) ...[
                const Divider(height: LinuSpacing.lg),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(LinuSpacing.sm),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(LinuRadius.medium),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  title: Text(
                    l10n.deleteKey,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: Text(
                    l10n.deleteKeyDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmDelete(context, l10n);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 待解密消息入口
  Widget _buildEncryptedMessagesEntry(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final countAsync = ref.watch(encryptedMessagesCountProvider);

    return countAsync.when(
      data: (count) {
        if (count == 0) {
          return const SizedBox.shrink();
        }
        return ListTile(
          dense: true,
          leading: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Center(
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: TextStyle(
                        color: theme.colorScheme.onError,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            l10n.encryptedMessagesWithCount(count),
            style: theme.textTheme.bodyMedium,
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () => context.push('/encrypted-messages'),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  /// FAQ 底部弹窗
  void _showFaqSheet(BuildContext context, AppLocalizations l10n) {
    FaqSheet.show(
      context,
      title: l10n.e2eFaqTitle,
      items: [
        FaqItem(
          question: l10n.faqQuestion1,
          answer: l10n.faqAnswer1,
          icon: Icons.lock_outline_rounded,
        ),
        FaqItem(
          question: l10n.faqQuestion2,
          answer: l10n.faqAnswer2,
          icon: Icons.warning_amber_rounded,
        ),
        FaqItem(
          question: l10n.faqQuestion3,
          answer: l10n.faqAnswer3,
          icon: Icons.sync_rounded,
        ),
        FaqItem(
          question: l10n.faqQuestion4,
          answer: l10n.faqAnswer4,
          icon: Icons.cloud_off_rounded,
        ),
        FaqItem(
          question: l10n.faqQuestion5,
          answer: l10n.faqAnswer5,
          icon: Icons.code_rounded,
        ),
      ],
    );
  }

  Future<void> _handleGenerateKey(
    BuildContext context,
    AppLocalizations l10n, {
    required bool hasKey,
  }) async {
    if (hasKey) {
      final confirmed = await _showOverwriteConfirmDialog(context, l10n);
      if (!confirmed || !mounted) return;
    }
    if (!context.mounted) return;
    await _generateKey(context, l10n);
  }

  Future<void> _handleImportKey(
    BuildContext context,
    AppLocalizations l10n, {
    required bool hasKey,
  }) async {
    if (hasKey) {
      final confirmed = await _showOverwriteConfirmDialog(context, l10n);
      if (!confirmed || !mounted) return;
    }
    if (!context.mounted) return;
    _showImportSheet(context, l10n);
  }

  Future<void> _generateKey(BuildContext context, AppLocalizations l10n) async {
    // generateKey() 内部已经有身份认证，这里不需要再次认证
    try {
    await HapticFeedback.mediumImpact();
      await ref
          .read(keyManagerProvider)
          .generateKey(authReason: l10n.authReason);
    _cachedKey = null;
    ref.invalidate(encryptionKeyProvider);

    if (!context.mounted) return;
      ToastService.instance.showCenter(
        l10n.keyGenerated,
        false,
        isSuccess: true,
      );
    } catch (e) {
      if (!context.mounted) return;
      if (e is AuthenticationException) {
        ToastService.instance.showCenter(
          _getAuthErrorMessage(e.errorType, l10n),
          false,
          isSuccess: false,
        );
      } else {
        ToastService.instance.showCenter(
          l10n.authFailed,
          false,
          isSuccess: false,
        );
      }
    }
  }

  void _showImportSheet(BuildContext context, AppLocalizations l10n) {
    final controller = TextEditingController();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        String? errorText;

        return StatefulBuilder(
          builder: (innerContext, setState) {
            final bottomInset = MediaQuery.of(sheetContext).viewInsets.bottom;

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: LinuSpacing.lg,
                  right: LinuSpacing.lg,
                  top: LinuSpacing.sm,
                  bottom: bottomInset + LinuSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.importKey,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: LinuSpacing.xs),
                    Text(
                      l10n.importKeyDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: LinuSpacing.lg),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: l10n.importKeyHint,
                        errorText: errorText,
                        errorMaxLines: 2,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste_rounded),
                          onPressed: () async {
                            final data = await Clipboard.getData('text/plain');
                            if (data?.text != null) {
                              controller.text = data!.text!;
                            }
                          },
                        ),
                      ),
                      onChanged: (value) {
                        if (errorText != null && value.trim().isNotEmpty) {
                          setState(() => errorText = null);
                        }
                      },
                      maxLines: 2,
                      minLines: 1,
                    ),
                    const SizedBox(height: LinuSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: LinuSpacing.md),
                        Expanded(
                          child: FilledButton(
                            onPressed: () async {
                              final value = controller.text.trim();
                              if (value.isEmpty) {
                                setState(
                                  () => errorText = l10n.invalidKeyFormat,
                                );
                                return;
                              }

                              // importKey() 内部已经有身份认证，这里不需要再次认证
                              try {
                                await ref
                                    .read(keyManagerProvider)
                                    .importKey(
                                      value,
                                      authReason: l10n.authReason,
                                    );
                                _cachedKey = null;
                                ref.invalidate(encryptionKeyProvider);
                                if (mounted && sheetContext.mounted) {
                                  Navigator.pop(sheetContext);
                                  ToastService.instance.showCenter(
                                    l10n.keyImported,
                                    false,
                                    isSuccess: true,
                                  );
                                }
                              } catch (e) {
                                if (e is AuthenticationException) {
                                  if (mounted && sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                    ToastService.instance.showCenter(
                                      _getAuthErrorMessage(e.errorType, l10n),
                                      false,
                                      isSuccess: false,
                                    );
                                  }
                                } else {
                                  setState(
                                    () => errorText = l10n.invalidKeyFormat,
                                  );
                                }
                              }
                            },
                            child: Text(l10n.importKey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<bool> _showOverwriteConfirmDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final result = await ConfirmDialog.show(
      context,
      title: l10n.replaceExistingKey,
      content: l10n.replaceKeyConfirm,
      confirmText: l10n.replace,
    );
    return result == true;
  }

  void _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await ConfirmDialog.showDelete(
      context,
      title: l10n.deleteKey,
      content: l10n.deleteKeyConfirm,
    );

    if (confirmed != true || !context.mounted) return;

    // deleteKey() 内部已经有身份认证，这里不需要再次认证
    try {
      await ref
          .read(keyManagerProvider)
          .deleteKey(authReason: l10n.authReason);
      _cachedKey = null;
      ref.invalidate(encryptionKeyProvider);
      if (!context.mounted) return;
      ToastService.instance.showCenter(
        l10n.keyDeleted,
        false,
        isSuccess: true,
      );
    } catch (e) {
      if (!context.mounted) return;
      if (e is AuthenticationException) {
        ToastService.instance.showCenter(
          _getAuthErrorMessage(e.errorType, l10n),
          false,
          isSuccess: false,
        );
      } else {
        ToastService.instance.showCenter(
          l10n.authFailed,
          false,
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _copyKey(BuildContext context, AppLocalizations l10n) async {
    // exportKey() 内部已经有身份认证，这里不需要再次认证
    try {
      final key = await ref
          .read(keyManagerProvider)
          .exportKey(authReason: l10n.authReason);
    if (key != null) {
      await Clipboard.setData(ClipboardData(text: key));
      await HapticFeedback.lightImpact();
        if (!context.mounted) return;
        ToastService.instance.showCenter(
          l10n.copied,
          false,
          isSuccess: true,
        );
      } else {
        if (!context.mounted) return;
        ToastService.instance.showCenter(
          l10n.authCancelled,
          false,
          isSuccess: false,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      if (e is AuthenticationException) {
        ToastService.instance.showCenter(
          _getAuthErrorMessage(e.errorType, l10n),
          false,
          isSuccess: false,
        );
      } else {
        ToastService.instance.showCenter(
          l10n.authFailed,
          false,
          isSuccess: false,
        );
      }
    }
  }


}
