import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/utils.dart';
import 'package:app/shared/constants.dart';

/// Toast 显示位置
enum ToastPosition {
  /// 屏幕中间
  center,

  /// 屏幕底部
  bottom,
}

/// Toast 状态
class ToastStatus {
  final String label;
  final bool isLoading;
  final bool? isSuccess;
  final ToastPosition position;
  final DateTime timestamp;
  final Color? backgroundColor;
  final IconData? icon;

  ToastStatus({
    required this.label,
    required this.isLoading,
    this.isSuccess,
    required this.position,
    this.backgroundColor,
    this.icon,
  }) : timestamp = DateTime.now();

  ToastStatus copyWith({
    String? label,
    bool? isLoading,
    bool? isSuccess,
    ToastPosition? position,
    Color? backgroundColor,
    IconData? icon,
  }) {
    return ToastStatus(
      label: label ?? this.label,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      position: position ?? this.position,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      icon: icon ?? this.icon,
    );
  }
}

/// 统一的 Toast 服务
/// - 支持 loading 状态（持续存在，不自动消失）
/// - 支持 success/failed 状态（自动消失）
/// - 支持自定义背景色和图标
class ToastService {
  static final ToastService _instance = ToastService._internal();
  static ToastService get instance => _instance;
  factory ToastService() => _instance;

  ToastService._internal();

  final _centerStatusController = StreamController<ToastStatus?>.broadcast();
  final _bottomStatusController = StreamController<ToastStatus?>.broadcast();

  Stream<ToastStatus?> get centerStatusStream =>
      _centerStatusController.stream;
  Stream<ToastStatus?> get bottomStatusStream => _bottomStatusController.stream;

  Timer? _centerAutoDismissTimer;
  Timer? _bottomAutoDismissTimer;

  /// 显示屏幕中间的 toast
  /// 
  /// [label] 显示的文本
  /// [isLoading] 是否为加载状态（true 时持续存在，false 时根据 isSuccess 自动消失）
  /// [isSuccess] 成功/失败状态（null 表示加载中，true 表示成功，false 表示失败）
  /// [backgroundColor] 自定义背景色（可选）
  /// [icon] 自定义图标（可选，如果不提供则根据状态自动选择）
  /// [duration] 自动消失时长（仅在非 loading 状态时有效，默认 3 秒）
  void showCenter(
    String label,
    bool isLoading, {
    bool? isSuccess,
    Color? backgroundColor,
    IconData? icon,
    Duration? duration,
  }) {
    _centerAutoDismissTimer?.cancel();

    final status = ToastStatus(
      label: label,
      isLoading: isLoading,
      isSuccess: isSuccess,
      position: ToastPosition.center,
      backgroundColor: backgroundColor,
      icon: icon,
    );
    _centerStatusController.add(status);

    // 非 loading 状态时自动消失
    if (!isLoading && isSuccess != null) {
      HapticFeedback.lightImpact();
      final dismissDuration = duration ?? const Duration(seconds: 3);
      _centerAutoDismissTimer = Timer(dismissDuration, () {
        _centerStatusController.add(null);
      });
    }
  }

  /// 显示屏幕底部的 toast
  /// 
  /// [label] 显示的文本
  /// [isLoading] 是否为加载状态（true 时持续存在，false 时根据 isSuccess 自动消失）
  /// [isSuccess] 成功/失败状态（null 表示加载中，true 表示成功，false 表示失败）
  /// [backgroundColor] 自定义背景色（可选）
  /// [icon] 自定义图标（可选，如果不提供则根据状态自动选择）
  /// [duration] 自动消失时长（仅在非 loading 状态时有效，默认 3 秒）
  void showBottom(
    String label,
    bool isLoading, {
    bool? isSuccess,
    Color? backgroundColor,
    IconData? icon,
    Duration? duration,
  }) {
    _bottomAutoDismissTimer?.cancel();

    final status = ToastStatus(
      label: label,
      isLoading: isLoading,
      isSuccess: isSuccess,
      position: ToastPosition.bottom,
      backgroundColor: backgroundColor,
      icon: icon,
    );
    _bottomStatusController.add(status);

    // 非 loading 状态时自动消失
    if (!isLoading && isSuccess != null) {
      HapticFeedback.lightImpact();
      final dismissDuration = duration ?? const Duration(seconds: 3);
      _bottomAutoDismissTimer = Timer(dismissDuration, () {
        _bottomStatusController.add(null);
      });
    }
  }

  /// 清除所有状态
  void clearAll() {
    _centerAutoDismissTimer?.cancel();
    _bottomAutoDismissTimer?.cancel();
    _centerStatusController.add(null);
    _bottomStatusController.add(null);
  }

  void dispose() {
    _centerAutoDismissTimer?.cancel();
    _bottomAutoDismissTimer?.cancel();
    _centerStatusController.close();
    _bottomStatusController.close();
  }
}

/// Toast Overlay Widget
/// 
/// 放在页面的顶层，监听 ToastService 的状态变化并显示浮动提示
class ToastOverlay extends StatefulWidget {
  final Widget child;

  /// 是否显示屏幕中间位置的 toast
  final bool showCenter;

  /// 是否显示屏幕底部位置的 toast
  final bool showBottom;

  /// 底部 toast 距离底部的偏移量（用于避开 bottomBar）
  final double bottomOffset;

  const ToastOverlay({
    super.key,
    required this.child,
    this.showCenter = true,
    this.showBottom = true,
    this.bottomOffset = 72,
  });

  @override
  State<ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<ToastOverlay> {
  ToastStatus? _centerStatus;
  ToastStatus? _bottomStatus;
  late StreamSubscription<ToastStatus?> _centerSubscription;
  late StreamSubscription<ToastStatus?> _bottomSubscription;

  @override
  void initState() {
    super.initState();
    _centerSubscription =
        ToastService.instance.centerStatusStream.listen((status) {
      setState(() => _centerStatus = status);
    });
    _bottomSubscription =
        ToastService.instance.bottomStatusStream.listen((status) {
      setState(() => _bottomStatus = status);
    });
  }

  @override
  void dispose() {
    _centerSubscription.cancel();
    _bottomSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // 屏幕中间位置
        if (widget.showCenter)
          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: AnimatedSwitcher(
                  duration: AnimationDurations.medium,
                  child: _centerStatus != null
                      ? _ToastStatusChip(
                          key: ValueKey(_centerStatus!.timestamp),
                          status: _centerStatus!,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        // 屏幕底部位置
        if (widget.showBottom)
          Positioned(
            left: 0,
            right: 0,
            bottom: widget.bottomOffset +
                MediaQuery.of(context).padding.bottom,
            child: IgnorePointer(
              child: Center(
                child: AnimatedSwitcher(
                  duration: AnimationDurations.medium,
                  child: _bottomStatus != null
                      ? _ToastStatusChip(
                          key: ValueKey(_bottomStatus!.timestamp),
                          status: _bottomStatus!,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Toast 状态提示 Chip
class _ToastStatusChip extends StatelessWidget {
  final ToastStatus status;

  const _ToastStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prefersReducedMotion = AppUtils.prefersReducedMotion(context);

    final Color backgroundColor;
    final Color foregroundColor;
    final IconData? icon;

    // 如果有自定义背景色，使用自定义的
    if (status.backgroundColor != null) {
      backgroundColor = status.backgroundColor!;
      foregroundColor = _getContrastColor(backgroundColor);
      icon = status.icon;
    } else {
      // 否则根据状态自动选择
      const successColor = LinuColors.unreadIndicator; // 淡绿色
      final errorColor = theme.colorScheme.error;

      if (status.isLoading) {
        backgroundColor = isDark
            ? LinuColors.darkCardSurface
            : LinuColors.lightCardSurface;
        foregroundColor = theme.colorScheme.onSurface;
        icon = null;
      } else if (status.isSuccess == true) {
        backgroundColor = successColor.withValues(alpha: 0.15);
        foregroundColor = successColor;
        icon = status.icon ?? Icons.check_circle_rounded;
      } else {
        backgroundColor = errorColor.withValues(alpha: 0.15);
        foregroundColor = errorColor;
        icon = status.icon ?? Icons.error_rounded;
      }
    }

    // 获取屏幕宽度，限制最大宽度
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth - 48; // 左右各留 24dp 边距

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: LinuSpacing.md,
              vertical: LinuSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: foregroundColor.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark
                          ? LinuColors.darkPrimaryText
                          : LinuColors.lightPrimaryText)
                      .withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status.isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: foregroundColor,
                    ),
                  )
                else if (icon != null)
                  Icon(icon, size: 16, color: foregroundColor),
                const SizedBox(width: LinuSpacing.xs),
                Flexible(
                  child: Text(
                    status.label,
                    style: LinuTextStyles.caption.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: prefersReducedMotion
              ? Duration.zero
              : AnimationDurations.medium,
        )
        .scale(
          begin: const Offset(0.9, 0.9),
          duration: prefersReducedMotion
              ? Duration.zero
              : AnimationDurations.medium,
        );
  }

  /// 根据背景色获取对比色（文本颜色）
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5
        ? LinuColors.lightPrimaryText
        : LinuColors.lightCardSurface;
  }
}
