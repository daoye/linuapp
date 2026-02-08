import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/features/settings/settings_provider.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/services/toast_service.dart';
import 'package:app/shared/widgets/faq_sheet.dart';
import 'package:app/shared/widgets/confirm_dialog.dart';

/// 设备令牌组件
///
/// 显示 APNS/FCM 推送令牌，并支持开启伪装标识符模式。
/// 开启伪装后，额外显示伪装标识符供 webhook 使用。
class DeviceTokenWidget extends ConsumerStatefulWidget {
  const DeviceTokenWidget({super.key});

  @override
  ConsumerState<DeviceTokenWidget> createState() => _DeviceTokenWidgetState();
}

class _DeviceTokenWidgetState extends ConsumerState<DeviceTokenWidget> {
  bool _isDeviceTokenRevealed = false;
  bool _isPseudoTokenRevealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    final deviceToken = settings.deviceToken;
    final hasDeviceToken = deviceToken != null && deviceToken.isNotEmpty;
    final usePseudoToken = !settings.useRealToken;
    final pseudoToken = settings.webhookToken ?? '';

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          ListTile(
            leading: Icon(
              hasDeviceToken ? Icons.smartphone_rounded : Icons.phonelink_off_rounded,
            ),
            title: Text(l10n.deviceToken),
          ),

          // Device Token display
          if (hasDeviceToken) 
            _buildTokenDisplay(
              context, 
              theme, 
              l10n, 
              deviceToken,
              _isDeviceTokenRevealed,
              (revealed) => setState(() => _isDeviceTokenRevealed = revealed),
            ),

          // Loading state
          if (!hasDeviceToken)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                LinuSpacing.lg,
                0,
                LinuSpacing.lg,
                LinuSpacing.lg,
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: LinuSpacing.md),
                  Expanded(
                    child: Text(
                      l10n.waitingForPushPermission,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Pseudo token section (only when device token exists)
          if (hasDeviceToken) ...[
            const Divider(height: 1),
            
            // Pseudo token toggle
            SwitchListTile(
              secondary: Icon(
                Icons.shield_rounded, 
                size: 22,
                color: usePseudoToken ? LinuColors.unreadIndicator : null,
              ),
              title: Text(l10n.usePseudoToken),
              value: usePseudoToken,
              onChanged: (value) {
                if (value) {
                  ref.read(settingsProvider.notifier).setUseRealToken(false);
                } else {
                  _confirmSwitchToRealToken(context, l10n);
                }
              },
            ),

            // Pseudo token display (when enabled)
            if (usePseudoToken && pseudoToken.isNotEmpty) ...[
              _buildTokenDisplay(
                context,
                theme,
                l10n,
                pseudoToken,
                _isPseudoTokenRevealed,
                (revealed) => setState(() => _isPseudoTokenRevealed = revealed),
              ),
              // Reset + FAQ row
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  LinuSpacing.lg,
                  0,
                  LinuSpacing.lg,
                  LinuSpacing.lg,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => _confirmResetToken(context, l10n),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: LinuSpacing.xs),
                          Text(
                            l10n.resetWebhookToken,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _showFaqSheet(context, l10n),
                      child: Text(
                        l10n.webhookTokenFaq,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  /// 令牌显示区域
  Widget _buildTokenDisplay(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
    String token,
    bool isRevealed,
    ValueChanged<bool> onRevealChanged,
  ) {
    final display = isRevealed ? token : _maskToken(token);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LinuSpacing.lg,
        0,
        LinuSpacing.lg,
        LinuSpacing.md,
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
              child: isRevealed
                  ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SelectableText(
                        display,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Text(
                      display,
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
                isRevealed
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 20,
              ),
              onPressed: () => onRevealChanged(!isRevealed),
              visualDensity: VisualDensity.compact,
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 20),
              onPressed: () => _copyToken(context, token, l10n),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }

  String _maskToken(String token) {
    if (token.length <= 12) return '••••••••••••';
    final start = token.substring(0, 6);
    final end = token.substring(token.length - 6);
    return '$start••••••$end';
  }

  void _confirmResetToken(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.resetWebhookToken,
      content: l10n.resetWebhookTokenConfirm,
      icon: Icons.refresh_rounded,
    );
    
    if (confirmed == true && context.mounted) {
      await HapticFeedback.mediumImpact();
      await ref.read(settingsProvider.notifier).resetWebhookToken();
      if (!context.mounted) return;
      ToastService.instance.showCenter(
        l10n.webhookTokenReset,
        false,
        isSuccess: true,
      );
    }
  }

  void _confirmSwitchToRealToken(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.switchToRealToken,
      content: l10n.switchToRealTokenConfirm,
      type: ConfirmDialogType.destructive,
      icon: Icons.warning_amber_rounded,
    );
    
    if (confirmed == true && context.mounted) {
      await ref.read(settingsProvider.notifier).setUseRealToken(true);
      if (!context.mounted) return;
      ToastService.instance.showCenter(
        l10n.switchedToRealToken,
        false,
        isSuccess: true,
      );
    }
  }

  void _showFaqSheet(BuildContext context, AppLocalizations l10n) {
    FaqSheet.show(
      context,
      title: l10n.webhookTokenFaqTitle,
      items: [
        FaqItem(
          question: l10n.webhookFaqQuestion1,
          answer: l10n.webhookFaqAnswer1,
          icon: Icons.shield_outlined,
        ),
        FaqItem(
          question: l10n.webhookFaqQuestion2,
          answer: l10n.webhookFaqAnswer2,
          icon: Icons.security_rounded,
        ),
        FaqItem(
          question: l10n.webhookFaqQuestion3,
          answer: l10n.webhookFaqAnswer3,
          icon: Icons.notifications_rounded,
        ),
        FaqItem(
          question: l10n.webhookFaqQuestion4,
          answer: l10n.webhookFaqAnswer4,
          icon: Icons.refresh_rounded,
        ),
      ],
    );
  }

  Future<void> _copyToken(
    BuildContext context,
    String token,
    AppLocalizations l10n,
  ) async {
    await HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: token));

    if (!context.mounted) return;

    ToastService.instance.showCenter(
      l10n.copied,
      false,
      isSuccess: true,
    );
  }
}
