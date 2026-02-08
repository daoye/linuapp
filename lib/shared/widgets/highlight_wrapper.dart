import 'package:flutter/material.dart';

/// 高亮包装组件
///
/// 用于包装需要高亮显示的消息，实现脉冲发光效果
class HighlightWrapper extends StatefulWidget {
  final Widget child;
  final bool highlight;
  final VoidCallback? onHighlightEnd;

  const HighlightWrapper({
    super.key,
    required this.child,
    this.highlight = false,
    this.onHighlightEnd,
  });

  @override
  State<HighlightWrapper> createState() => _HighlightWrapperState();
}

class _HighlightWrapperState extends State<HighlightWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // 总时长 1.2 秒，2 次脉冲
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 脉冲动画：0 -> 1 -> 0 -> 1 -> 0
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onHighlightEnd?.call();
      }
    });

    if (widget.highlight) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(HighlightWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.highlight && !oldWidget.highlight) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAnimating = _controller.isAnimating || _controller.status == AnimationStatus.forward;
    if (!widget.highlight && !isAnimating) {
      return widget.child;
    }

    final theme = Theme.of(context);
    final highlightColor = theme.colorScheme.primary;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final value = _pulseAnimation.value;
        
        // 缩放效果：1.0 -> 1.02 -> 1.0
        final scale = 1.0 + (value * 0.015);
        
        // 边框发光效果
        final glowOpacity = value * 0.05;
        final glowSpread = value * 4;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: highlightColor.withValues(alpha: glowOpacity),
                  blurRadius: 8 + glowSpread,
                  spreadRadius: glowSpread,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
