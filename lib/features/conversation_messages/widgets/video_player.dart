import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/l10n/app_localizations.dart';

/// 视频播放器状态
enum VideoPlayerStatus {
  /// 初始化中
  loading,

  /// 播放就绪
  ready,

  /// 发生错误
  error,
}

/// 应用视频播放器组件
///
/// 支持网络视频播放，包含完善的错误处理：
/// - 网络错误
/// - 视频格式不支持
/// - 初始化超时
class AppVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;

  /// 初始化超时时间
  final Duration timeout;

  const AppVideoPlayer({
    super.key,
    required this.videoUrl,
    this.autoPlay = false,
    this.timeout = const Duration(seconds: 15),
  });

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  VideoPlayerStatus _status = VideoPlayerStatus.loading;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant AppVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 如果 URL 改变，重新初始化
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeControllers();
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    if (!mounted) return;

    setState(() {
      _status = VideoPlayerStatus.loading;
      _errorMessage = null;
    });

    try {
      final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );
      _videoPlayerController = controller;

      // 带超时的初始化
      await controller.initialize().timeout(
        widget.timeout,
        onTimeout: () {
          throw Exception('Video loading timeout');
        },
      );

      // 检查是否有错误
      if (controller.value.hasError) {
        throw Exception(controller.value.errorDescription ?? 'Unknown error');
      }

      if (!mounted) {
        controller.dispose();
        return;
      }

    _chewieController = ChewieController(
        videoPlayerController: controller,
      autoPlay: widget.autoPlay,
      looping: false,
        aspectRatio: controller.value.aspectRatio,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        placeholder: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            return Container(
              color: isDark ? LinuColors.darkChatBackground : LinuColors.lightChatBackground,
              child: Center(
                child: CircularProgressIndicator(
                  color: isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
        errorBuilder: (context, errorMessage) {
          return _buildErrorWidget(errorMessage);
      },
    );

    if (mounted) {
        setState(() {
          _status = VideoPlayerStatus.ready;
        });
    }
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = VideoPlayerStatus.error;
          _errorMessage = _parseErrorMessage(e);
        });
      }
    }
  }

  /// 解析错误信息为用户友好的文本
  String _parseErrorMessage(dynamic error) {
    final message = error.toString().toLowerCase();

    if (message.contains('timeout')) {
      return 'Video loading timeout. Please check your network.';
    }
    if (message.contains('network') || message.contains('connection')) {
      return 'Network error. Please check your connection.';
    }
    if (message.contains('format') || message.contains('codec')) {
      return 'Unsupported video format.';
    }
    if (message.contains('404') || message.contains('not found')) {
      return 'Video not found.';
    }
    if (message.contains('403') || message.contains('forbidden')) {
      return 'Access denied.';
    }

    return 'Failed to load video.';
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _chewieController = null;
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return switch (_status) {
      VideoPlayerStatus.loading => _buildLoadingWidget(),
      VideoPlayerStatus.ready => _buildPlayerWidget(),
      VideoPlayerStatus.error => _buildErrorWidget(_errorMessage),
    };
  }

  Widget _buildLoadingWidget() {
      return AspectRatio(
        aspectRatio: 16 / 9,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          return Container(
            color: isDark ? LinuColors.darkChatBackground : LinuColors.lightChatBackground,
            child: Center(
              child: CircularProgressIndicator(
                color: isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText,
                strokeWidth: 2,
              ),
            ),
          );
        },
      ),
      );
    }

  Widget _buildPlayerWidget() {
    final controller = _chewieController;
    final videoController = _videoPlayerController;

    if (controller == null || videoController == null) {
      return _buildErrorWidget('Player not initialized');
    }

    if (!videoController.value.isInitialized) {
      return _buildLoadingWidget();
    }

    return AspectRatio(
      aspectRatio: videoController.value.aspectRatio,
      child: Chewie(controller: controller),
    );
  }

  Widget _buildErrorWidget(String? message) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: isDark ? LinuColors.darkChatBackground : LinuColors.lightChatBackground,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: theme.colorScheme.error.withValues(alpha: 0.8),
              ),
              const SizedBox(height: LinuSpacing.md),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: LinuSpacing.xl),
                child: Text(
                  message ?? 'Failed to load video',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark 
                        ? LinuColors.darkSecondaryText 
                        : LinuColors.lightSecondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: LinuSpacing.lg),
              TextButton.icon(
                onPressed: _initializePlayer,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(AppLocalizations.of(context)!.retry),
                style: TextButton.styleFrom(
                  foregroundColor: isDark 
                      ? LinuColors.darkPrimaryText 
                      : LinuColors.lightPrimaryText,
                  backgroundColor: (isDark 
                      ? LinuColors.darkPrimaryText 
                      : LinuColors.lightPrimaryText).withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: LinuSpacing.lg,
                    vertical: LinuSpacing.sm,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
