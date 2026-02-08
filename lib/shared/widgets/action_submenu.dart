import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/constants.dart';

/// Configuration for submenu positioning and sizing
class SubmenuConfig {
  final double maxWidth;
  final bool growLeft;
  final bool growDown;

  const SubmenuConfig({
    required this.maxWidth,
    this.growLeft = false,
    this.growDown = false,
  });
}

/// A unified floating submenu widget used by both ConversationActionBar and TemplateMessageCard.
/// Provides consistent styling and behavior for second-level action menus.
class ActionSubmenu extends StatelessWidget {
  final List<Map<String, dynamic>> children;
  final void Function(Map<String, dynamic> action)? onActionTap;
  final double maxWidth;
  /// Maximum visible items before scrolling kicks in
  final int maxVisibleItems;

  const ActionSubmenu({
    super.key,
    required this.children,
    this.onActionTap,
    this.maxWidth = 280,
    this.maxVisibleItems = 5,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(LinuRadius.large),
      shadowColor: (Theme.of(context).brightness == Brightness.dark 
          ? LinuColors.darkPrimaryText 
          : LinuColors.lightPrimaryText).withValues(alpha: 0.2),
      color: isDark ? LinuColors.darkCardSurface : LinuColors.lightCardSurface,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(LinuRadius.large),
          border: Border.all(
            color: (isDark ? LinuColors.darkBorder : LinuColors.lightBorder)
                .withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: 160,
            maxWidth: maxWidth,
            maxHeight: children.length > maxVisibleItems
                ? (maxVisibleItems * 52.0) + 16.0
                : double.infinity,
          ),
          child: IntrinsicWidth(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(LinuRadius.large),
              child: children.length > maxVisibleItems
                  ? _buildScrollableContent(isDark)
                  : _buildStaticContent(isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScrollableContent(bool isDark) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: LinuSpacing.xs),
      child: _buildMenuItems(isDark),
    );
  }

  Widget _buildStaticContent(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: LinuSpacing.xs),
      child: _buildMenuItems(isDark),
    );
  }

  Widget _buildMenuItems(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children.asMap().entries.map((entry) {
        final child = entry.value;
        final childLabel = child['label'] ?? 'Action';

        return _MenuItemTile(
          label: childLabel,
          isDark: isDark,
          onTap: onActionTap != null ? () => onActionTap!(child) : null,
        );
      }).toList(),
    );
  }
}

class _MenuItemTile extends StatefulWidget {
  final String label;
  final bool isDark;
  final VoidCallback? onTap;

  const _MenuItemTile({
    required this.label,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_MenuItemTile> createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<_MenuItemTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      child: AnimatedContainer(
        duration: AnimationDurations.fast,
        margin: EdgeInsets.symmetric(
          horizontal: LinuSpacing.xs,
          vertical: LinuSpacing.xs / 2,
        ),
                padding: EdgeInsets.symmetric(
                  horizontal: LinuSpacing.md,
          vertical: LinuSpacing.sm + 2,
                ),
        decoration: BoxDecoration(
          color: _isPressed
              ? (widget.isDark
                  ? LinuColors.darkPressedBackground
                  : LinuColors.lightPressedBackground)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(LinuRadius.medium),
        ),
                  child: Text(
          widget.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: LinuTextStyles.body.copyWith(
            color: widget.isDark
                          ? LinuColors.darkPrimaryText
                          : LinuColors.lightPrimaryText,
            fontWeight: FontWeight.w500,
                ),
              ),
            ),
    );
  }
}

/// Helper class to calculate submenu positioning
class SubmenuPositionCalculator {
  /// Calculate submenu configuration based on button position and screen bounds
  static SubmenuConfig calculate({
    required RenderBox buttonBox,
    required RenderBox overlayBox,
    required int itemCount,
    double horizontalMargin = 8.0,
    double verticalMargin = 8.0,
    double? maxWidthOverride,
  }) {
    final buttonPosition = buttonBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final buttonLeft = buttonPosition.dx;
    final buttonTop = buttonPosition.dy;
    final buttonRight = buttonLeft + buttonBox.size.width;
    final buttonBottom = buttonTop + buttonBox.size.height;
    final screenWidth = overlayBox.size.width;
    final screenHeight = overlayBox.size.height;

    final availableRight = screenWidth - buttonLeft - horizontalMargin;
    final availableLeft = buttonRight - horizontalMargin;
    final growLeft = availableRight < availableLeft;

    final directionalLimit = growLeft ? availableLeft : availableRight;
    final maxWidth = maxWidthOverride != null
        ? directionalLimit.clamp(140.0, maxWidthOverride)
        : directionalLimit.clamp(140.0, screenWidth - 2 * horizontalMargin);

    final estimatedHeight = (itemCount * 48.0) + 16.0;
    final availableAbove = buttonTop - verticalMargin;
    final availableBelow = screenHeight - buttonBottom - verticalMargin;
    final growDown = availableAbove < estimatedHeight && availableBelow > availableAbove;

    return SubmenuConfig(
      maxWidth: maxWidth,
      growLeft: growLeft,
      growDown: growDown,
    );
  }

  static Alignment getTargetAnchor(SubmenuConfig config) {
    if (config.growDown) {
      return config.growLeft ? Alignment.bottomRight : Alignment.bottomLeft;
    } else {
      return config.growLeft ? Alignment.topRight : Alignment.topLeft;
    }
  }

  static Alignment getFollowerAnchor(SubmenuConfig config) {
    if (config.growDown) {
      return config.growLeft ? Alignment.topRight : Alignment.topLeft;
    } else {
      return config.growLeft ? Alignment.bottomRight : Alignment.bottomLeft;
    }
  }

  static Offset getOffset(SubmenuConfig config) {
    return config.growDown ? const Offset(0, 4) : const Offset(0, -4);
  }
}
