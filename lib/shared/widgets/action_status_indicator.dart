import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app/shared/constants.dart';
import 'package:app/theme/app_theme.dart';

/// Status indicator for webhook action processing
/// Shows loading, success, or error state with action label
class ActionStatusIndicator extends StatefulWidget {
  final String actionLabel;
  final bool isLoading;
  final bool? isSuccess;
  final bool shouldDismiss;

  const ActionStatusIndicator({
    super.key,
    required this.actionLabel,
    required this.isLoading,
    this.isSuccess,
    this.shouldDismiss = false,
  });

  @override
  State<ActionStatusIndicator> createState() => _ActionStatusIndicatorState();
}

class _ActionStatusIndicatorState extends State<ActionStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _dismissController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _dismissController = AnimationController(
      duration: AnimationDurations.shimmer,
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _dismissController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _heightAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _dismissController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void didUpdateWidget(ActionStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldDismiss && !oldWidget.shouldDismiss) {
      _dismissController.forward();
    }
  }

  @override
  void dispose() {
    _dismissController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget icon;
    Color backgroundColor;
    Color textColor;
    String statusText;

    if (widget.isLoading) {
      icon = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
      backgroundColor = theme.colorScheme.surfaceContainerHighest;
      textColor = theme.colorScheme.onSurface;
      statusText = 'Processing';
    } else if (widget.isSuccess == true) {
      icon = Icon(
        Icons.check_circle,
        size: 16,
        color: theme.colorScheme.primary,
      );
      backgroundColor = theme.colorScheme.primaryContainer;
      textColor = theme.colorScheme.onPrimaryContainer;
      statusText = 'Success';
    } else {
      icon = Icon(
        Icons.error_outline,
        size: 16,
        color: theme.colorScheme.error,
      );
      backgroundColor = theme.colorScheme.errorContainer;
      textColor = theme.colorScheme.onErrorContainer;
      statusText = 'Failed';
    }

    return Align(
      alignment: Alignment.center,
      child: AnimatedBuilder(
        animation: _dismissController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: SizeTransition(
              sizeFactor: _heightAnimation,
              axisAlignment: -1.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: (Theme.of(context).brightness == Brightness.dark 
                          ? LinuColors.darkPrimaryText 
                          : LinuColors.lightPrimaryText).withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    icon,
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '$statusText: ${widget.actionLabel}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ).animate()
              .fadeIn(duration: AnimationDurations.medium)
              .slideY(
                begin: 0.3,
                end: 0,
                duration: AnimationDurations.slow,
                curve: Curves.easeOutCubic,
              ),
            ),
          );
        },
      ),
    );
  }
}
