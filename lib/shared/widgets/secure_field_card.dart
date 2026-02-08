import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/utils.dart';
import 'package:app/shared/constants.dart';

/// 安全字段操作项配置
class SecureFieldAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const SecureFieldAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });
}

/// 安全字段卡片状态
enum SecureFieldStatus {
  /// 已配置，显示安全状态
  configured,

  /// 未配置，显示警告状态
  notConfigured,

  /// 加载中
  loading,
}

/// 统一的敏感信息展示卡片
///
/// 用于展示密钥、Token 等敏感信息，提供统一的用户体验：
/// - 显示/隐藏切换
/// - 复制功能
/// - 状态指示
/// - 操作菜单
/// - 动画效果
class SecureFieldCard extends StatefulWidget {
  /// 卡片标题
  final String title;

  /// 标题旁的帮助按钮点击回调
  final VoidCallback? onHelpTap;

  /// 字段值，为 null 时显示空状态
  final String? value;

  /// 加载字段值的异步方法（用于延迟加载敏感数据）
  final Future<String?> Function()? loadValue;

  /// 卡片状态
  final SecureFieldStatus status;

  /// 是否支持显示/隐藏切换
  final bool canToggleVisibility;

  /// 是否支持复制
  final bool canCopy;

  /// 复制成功后的提示文本
  final String copySuccessMessage;

  /// 操作菜单项
  final List<SecureFieldAction> actions;

  /// 空状态图标
  final IconData emptyIcon;

  /// 空状态标题
  final String emptyTitle;

  /// 空状态描述
  final String emptyDescription;

  /// 空状态主按钮
  final SecureFieldAction? emptyAction;

  /// 状态标签（已配置时显示）
  final String? statusLabel;

  /// 状态图标
  final IconData? statusIcon;

  const SecureFieldCard({
    super.key,
    required this.title,
    this.onHelpTap,
    this.value,
    this.loadValue,
    this.status = SecureFieldStatus.configured,
    this.canToggleVisibility = true,
    this.canCopy = true,
    this.copySuccessMessage = 'Copied',
    this.actions = const [],
    this.emptyIcon = Icons.key_off_rounded,
    this.emptyTitle = 'Not configured',
    this.emptyDescription = 'Configure this field to enable the feature.',
    this.emptyAction,
    this.statusLabel,
    this.statusIcon,
  });

  @override
  State<SecureFieldCard> createState() => _SecureFieldCardState();
}

class _SecureFieldCardState extends State<SecureFieldCard>
    with SingleTickerProviderStateMixin {
  bool _isRevealed = false;
  bool _showCopySuccess = false;
  String? _cachedValue;
  bool _isLoadingValue = false;

  late final AnimationController _copyAnimController;

  @override
  void initState() {
    super.initState();
    _copyAnimController = AnimationController(
      vsync: this,
      duration: AnimationDurations.medium,
    );

    if (widget.loadValue != null && widget.value == null) {
      _loadValueAsync();
    }
  }

  @override
  void dispose() {
    _copyAnimController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SecureFieldCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当 status 从 loading 变为其他状态时，或者 value 变化时，重新加载
    if (widget.loadValue != null &&
        widget.value == null &&
        oldWidget.status != widget.status) {
      _loadValueAsync();
    }
  }

  Future<void> _loadValueAsync() async {
    if (widget.loadValue == null || _isLoadingValue) return;

    setState(() => _isLoadingValue = true);

    try {
      final value = await widget.loadValue!();
      if (mounted) {
        setState(() {
          _cachedValue = value;
          _isLoadingValue = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingValue = false);
      }
    }
  }

  String get _displayValue => widget.value ?? _cachedValue ?? '';

  String _maskValue(String value) {
    if (value.length <= 12) return '••••••••••••';
    final start = value.substring(0, 6);
    final end = value.substring(value.length - 6);
    return '$start••••••••$end';
  }

  Future<void> _copyToClipboard() async {
    final value = _displayValue;
    if (value.isEmpty) return;

    await HapticFeedback.lightImpact();
    await Clipboard.setData(ClipboardData(text: value));

    if (!mounted) return;

    setState(() => _showCopySuccess = true);
    _copyAnimController.forward();

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      _copyAnimController.reverse();
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() => _showCopySuccess = false);
      }
    }
  }

  void _toggleVisibility() {
    HapticFeedback.selectionClick();
    setState(() => _isRevealed = !_isRevealed);
  }

  void _showActionsSheet() {
    if (widget.actions.isEmpty) return;

    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.actions.map((action) {
            return ListTile(
              leading: Icon(
                action.icon,
                color: action.isDestructive ? theme.colorScheme.error : null,
              ),
              title: Text(
                action.label,
                style: action.isDestructive
                    ? TextStyle(color: theme.colorScheme.error)
                    : null,
              ),
              onTap: () {
                Navigator.pop(sheetContext);
                action.onTap();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConfigured = widget.status == SecureFieldStatus.configured;
    final isLoading = widget.status == SecureFieldStatus.loading;
    final hasValue = _displayValue.isNotEmpty;
    final prefersReducedMotion = AppUtils.prefersReducedMotion(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(LinuRadius.large),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(theme, isConfigured),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(LinuSpacing.lg),
            child: isLoading
                ? _buildLoadingState(theme)
                : (hasValue && isConfigured)
                    ? _buildValueDisplay(theme)
                    : _buildEmptyState(theme, prefersReducedMotion),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          duration: prefersReducedMotion
              ? Duration.zero
              : AnimationDurations.slow,
          curve: Curves.easeOut,
        )
        .slideY(
          begin: 0.02,
          end: 0,
          duration: prefersReducedMotion
              ? Duration.zero
              : AnimationDurations.slow,
          curve: Curves.easeOut,
        );
  }

  Widget _buildHeader(ThemeData theme, bool isConfigured) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: LinuSpacing.lg,
        vertical: LinuSpacing.md,
      ),
      child: Row(
        children: [
          // Title with optional help button
          Expanded(
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.onHelpTap != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onHelpTap,
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Status badge
          if (widget.statusLabel != null) _buildStatusBadge(theme, isConfigured),

          // Actions menu button
          if (widget.actions.isNotEmpty) ...[
            const SizedBox(width: LinuSpacing.sm),
            _ActionButton(
              icon: Icons.more_horiz_rounded,
              onTap: _showActionsSheet,
              tooltip: 'More actions',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, bool isConfigured) {
    final isDark = theme.brightness == Brightness.dark;
    final color = isConfigured
        ? (isDark ? LinuColors.darkPrimaryAccent : LinuColors.lightPrimaryAccent)
        : theme.colorScheme.error;

    return AnimatedContainer(
      duration: AnimationDurations.slow,
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.statusIcon ??
                (isConfigured
                    ? Icons.verified_rounded
                    : Icons.warning_amber_rounded),
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            widget.statusLabel!,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: LinuSpacing.xl),
      child: Column(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: LinuSpacing.md),
          Text(
            'Loading...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueDisplay(ThemeData theme) {
    final displayText = _isRevealed ? _displayValue : _maskValue(_displayValue);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Value container
        Container(
          padding: const EdgeInsets.all(LinuSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(LinuRadius.medium),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Value text
              Expanded(
                child: AnimatedSwitcher(
                  duration: AnimationDurations.medium,
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: Text(
                    displayText,
                    key: ValueKey(_isRevealed),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurface,
                      letterSpacing: _isRevealed ? 0 : 1,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(width: LinuSpacing.sm),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.canToggleVisibility)
                    _ActionButton(
                      icon: _isRevealed
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      onTap: _toggleVisibility,
                      tooltip: _isRevealed ? 'Hide' : 'Show',
                    ),
                  if (widget.canCopy) ...[
                    const SizedBox(width: LinuSpacing.xs),
                    _CopyButton(
                      onTap: _copyToClipboard,
                      showSuccess: _showCopySuccess,
                      animationController: _copyAnimController,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool prefersReducedMotion) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: LinuSpacing.lg),
      child: Column(
        children: [
          // Icon with subtle animation
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              widget.emptyIcon,
              size: 28,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          )
              .animate(
                onPlay: prefersReducedMotion
                    ? null
                    : (c) => c.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.03, 1.03),
                duration: prefersReducedMotion
                    ? Duration.zero
                    : AnimationDurations.extraLong,
                curve: Curves.easeInOut,
              )
              .then()
              .scale(
                begin: const Offset(1.03, 1.03),
                end: const Offset(1, 1),
                duration: AnimationDurations.extraLong,
                curve: Curves.easeInOut,
              ),

          const SizedBox(height: LinuSpacing.lg),

          // Title
          Text(
            widget.emptyTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: LinuSpacing.xs),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: LinuSpacing.xl),
            child: Text(
              widget.emptyDescription,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),

          // Primary action button
          if (widget.emptyAction != null) ...[
            const SizedBox(height: LinuSpacing.xl),
            FilledButton.icon(
              onPressed: widget.emptyAction!.onTap,
              icon: Icon(widget.emptyAction!.icon, size: 18),
              label: Text(widget.emptyAction!.label),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: LinuSpacing.xl,
                  vertical: LinuSpacing.md,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 操作按钮（统一样式）
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// 复制按钮（带成功动画）
class _CopyButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool showSuccess;
  final AnimationController animationController;

  const _CopyButton({
    required this.onTap,
    required this.showSuccess,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: showSuccess ? 'Copied!' : 'Copy',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: showSuccess ? null : onTap,
          borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
            duration: AnimationDurations.medium,
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: showSuccess
                  ? (theme.brightness == Brightness.dark
                      ? LinuColors.darkPrimaryAccent
                      : LinuColors.lightPrimaryAccent).withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AnimatedSwitcher(
              duration: AnimationDurations.medium,
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              child: Icon(
                showSuccess ? Icons.check_rounded : Icons.copy_rounded,
                key: ValueKey(showSuccess),
                size: 20,
                color: showSuccess
                    ? (theme.brightness == Brightness.dark
                        ? LinuColors.darkPrimaryAccent
                        : LinuColors.lightPrimaryAccent)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

