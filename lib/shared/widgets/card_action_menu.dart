import 'package:flutter/material.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/widgets/blur_bottom_sheet.dart';

/// T057: Card-specific action menu using ListTile + Divider + trailing chevron.
/// For second-level menus, uses a bottom sheet instead of overlay popup.
/// Only used by TemplateMessageCard; ConversationActionBar keeps its current style.
class CardActionMenu extends StatelessWidget {
  final List<Map<String, dynamic>> actions;
  final void Function(Map<String, dynamic> action)? onActionTap;

  const CardActionMenu({
    super.key,
    required this.actions,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: actions.asMap().entries.map((entry) {
        final index = entry.key;
        final action = entry.value;
        final label = action['label'] ?? 'Action';
        final rawChildren = action['children'];
        final List<Map<String, dynamic>>? children = rawChildren is List
            ? rawChildren.map((c) => Map<String, dynamic>.from(c as Map)).toList()
            : null;
        final hasChildren = children?.isNotEmpty ?? false;
        final isLast = index == actions.length - 1;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                if (hasChildren && children != null) {
                  _showChildrenSheet(context, label, children);
                  return;
                }
                onActionTap?.call(action);
              },
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: EdgeInsets.symmetric(
                  horizontal: LinuSpacing.md,
                  vertical: LinuSpacing.sm,
                ),
                child: Row(
                  children: [
                    // Label
                    Expanded(
                      child: Text(
                        label,
                        style: LinuTextStyles.body.copyWith(
                          color: isDark
                              ? LinuColors.darkPrimaryText
                              : LinuColors.lightPrimaryText,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Trailing indicator: expand_more for children, chevron_right for direct action
                    if (hasChildren)
                      Icon(
                        Icons.expand_more,
                        size: 20,
                        color: isDark
                            ? LinuColors.darkSecondaryText
                            : LinuColors.lightSecondaryText,
                      )
                    else
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: isDark
                          ? LinuColors.darkTertiaryText
                          : LinuColors.lightTertiaryText,
                    ),
                  ],
                ),
              ),
            ),
            // Divider between items (not after last)
            if (!isLast)
              Container(
                height: 0.5,
                margin: EdgeInsets.symmetric(horizontal: LinuSpacing.sm),
                color: isDark
                    ? LinuColors.darkDivider.withValues(alpha: 0.5)
                    : LinuColors.lightDivider.withValues(alpha: 0.5),
              ),
          ],
        );
      }).toList(),
    );
  }

  void _showChildrenSheet(
    BuildContext context,
    String parentLabel,
    List<Map<String, dynamic>> children,
  ) {
    // 保存 Navigator 引用，避免在 bottom sheet 关闭后 context 失效
    final navigator = Navigator.of(context);
    final callback = onActionTap;
    
    BlurBottomSheet.show(
      context: context,
      title: parentLabel,
      children: children.map((child) {
        return BlurSheetTextItem(
          label: child['label'] ?? 'Action',
          onTap: () {
            navigator.pop();
            // 在下一帧执行回调，确保 bottom sheet 完全关闭
            WidgetsBinding.instance.addPostFrameCallback((_) {
              callback?.call(child);
            });
          },
        );
      }).toList(),
    );
  }
}
