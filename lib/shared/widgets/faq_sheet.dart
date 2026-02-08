import 'package:flutter/material.dart';
import 'package:app/theme/app_theme.dart';

/// FAQ 项目数据
class FaqItem {
  final String question;
  final String answer;
  final IconData? icon;

  const FaqItem({
    required this.question,
    required this.answer,
    this.icon,
  });
}

/// 通用 FAQ 底部弹窗
///
/// 使用可展开的卡片样式显示 FAQ 内容
class FaqSheet extends StatefulWidget {
  final String title;
  final String? subtitle;
  final List<FaqItem> items;

  const FaqSheet({
    super.key,
    required this.title,
    this.subtitle,
    required this.items,
  });

  /// 显示 FAQ 弹窗
  static void show(
    BuildContext context, {
    required String title,
    String? subtitle,
    required List<FaqItem> items,
  }) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => FaqSheet(
          title: title,
          subtitle: subtitle,
          items: items,
        ),
      ),
    );
  }

  @override
  State<FaqSheet> createState() => _FaqSheetState();
}

class _FaqSheetState extends State<FaqSheet> {
  int? _expandedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        LinuSpacing.lg,
        0,
        LinuSpacing.lg,
        LinuSpacing.xl,
      ),
      children: [
        // Header
        _buildHeader(theme),
        const SizedBox(height: LinuSpacing.lg),

        // FAQ Items
        ...List.generate(widget.items.length, (index) {
          return _buildFaqCard(theme, index, widget.items[index]);
        }),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: LinuSpacing.sm),
          Text(
            widget.subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildFaqCard(ThemeData theme, int index, FaqItem item) {
    final isExpanded = _expandedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: LinuSpacing.sm),
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(LinuRadius.large),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            setState(() {
              _expandedIndex = isExpanded ? null : index;
            });
          },
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Question row
                Padding(
                  padding: const EdgeInsets.all(LinuSpacing.md),
                  child: Row(
                    children: [
                      if (item.icon != null) ...[
                        Icon(
                          item.icon,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: LinuSpacing.sm),
                      ],
                      Expanded(
                        child: Text(
                          item.question,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Answer (expandable)
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      LinuSpacing.md,
                      0,
                      LinuSpacing.md,
                      LinuSpacing.md,
                    ),
                    child: Text(
                      item.answer,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
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
}
