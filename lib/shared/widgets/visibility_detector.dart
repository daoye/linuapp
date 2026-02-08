import 'dart:async';
import 'package:flutter/material.dart';

/// 全局注册表，用于统一管理所有 DelayedVisibilityDetector
class _VisibilityDetectorRegistry {
  static final _VisibilityDetectorRegistry _instance =
      _VisibilityDetectorRegistry._internal();
  factory _VisibilityDetectorRegistry() => _instance;
  _VisibilityDetectorRegistry._internal();

  final Set<_DelayedVisibilityDetectorState> _detectors = {};

  void register(_DelayedVisibilityDetectorState detector) {
    _detectors.add(detector);
  }

  void unregister(_DelayedVisibilityDetectorState detector) {
    _detectors.remove(detector);
  }

  /// 检查所有注册的 detector 的可见性
  void checkAll() {
    for (final detector in _detectors.toList()) {
      if (detector.mounted) {
        detector._checkVisibility();
      }
    }
  }
}

/// 轻量的延迟可见检测器
/// - 利用全局注册表 + ScrollController 的滚动监听来触发检测
/// - 无周期性定时器，只有在滚动或首帧时检查
/// - 可见面积超过阈值并持续 visibleDuration 后触发 onVisible（只触发一次）
class DelayedVisibilityDetector extends StatefulWidget {
  final Widget child;
  final Duration visibleDuration;
  final VoidCallback? onVisible;
  final String detectorId;
  final double visibleThreshold;

  const DelayedVisibilityDetector({
    super.key,
    required this.child,
    required this.detectorId,
    this.visibleDuration = const Duration(seconds: 2),
    this.onVisible,
    this.visibleThreshold = 0.5, // 至少 50% 可见才计时
  });

  @override
  State<DelayedVisibilityDetector> createState() =>
      _DelayedVisibilityDetectorState();

  /// 手动触发所有 detector 的可见性检查（通常在滚动监听里调用）
  static void notifyVisibilityCheck() {
    _VisibilityDetectorRegistry().checkAll();
  }
}

class _DelayedVisibilityDetectorState extends State<DelayedVisibilityDetector> {
  final GlobalKey _key = GlobalKey();
  Timer? _timer;
  bool _hasTriggered = false;
  bool _isVisibleEnough = false;

  @override
  void initState() {
    super.initState();
    _VisibilityDetectorRegistry().register(this);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _VisibilityDetectorRegistry().unregister(this);
    super.dispose();
  }

  void _checkVisibility() {
    if (_hasTriggered || widget.onVisible == null) return;

    final renderObject = _key.currentContext?.findRenderObject();
    if (renderObject == null || !renderObject.attached) {
      if (_isVisibleEnough) {
        _isVisibleEnough = false;
        _timer?.cancel();
      }
      return;
    }

    final box = renderObject as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final size = box.size;

    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenHeight = screenSize.height;
    final paddingTop = mediaQuery.padding.top;
    final paddingBottom = mediaQuery.padding.bottom;

    final visibleHeight = _calcIntersectionExtent(
      start: position.dy,
      end: position.dy + size.height,
      min: paddingTop,
      max: screenHeight - paddingBottom,
    );
    final visibleWidth = _calcIntersectionExtent(
      start: position.dx,
      end: position.dx + size.width,
      min: 0,
      max: screenSize.width,
    );

    final visibleArea = (visibleHeight.clamp(0, size.height)) *
        (visibleWidth.clamp(0, size.width));
    final totalArea = size.width * size.height;
    final fraction =
        totalArea > 0 ? (visibleArea / totalArea).clamp(0.0, 1.0) : 0.0;
    final isEnough = fraction >= widget.visibleThreshold;

    if (isEnough && !_isVisibleEnough) {
      _isVisibleEnough = true;
      _timer?.cancel();
      _timer = Timer(widget.visibleDuration, () {
        if (!_hasTriggered) {
          _hasTriggered = true;
          widget.onVisible?.call();
        }
      });
    } else if (!isEnough && _isVisibleEnough) {
      _isVisibleEnough = false;
      _timer?.cancel();
    }
  }

  double _calcIntersectionExtent({
    required double start,
    required double end,
    required double min,
    required double max,
  }) {
    final intersectionStart = start.clamp(min, max);
    final intersectionEnd = end.clamp(min, max);
    return intersectionEnd - intersectionStart;
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });

    return Container(
      key: _key,
      child: widget.child,
    );
  }
}

