import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:app/features/audio/services/audio_service.dart';
import 'package:app/features/audio/services/audio_file_service.dart';
import 'package:app/shared/services/toast_service.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/l10n/app_localizations.dart';

class AudioTrimDialog extends ConsumerStatefulWidget {
  final String sourcePath;
  final String originalFileName; // 原始文件名，用于生成默认名称
  final Function(String trimmedFilePath)? onComplete; // 返回裁剪后的文件路径

  const AudioTrimDialog({
    super.key,
    required this.sourcePath,
    required this.originalFileName,
    this.onComplete,
  });

  @override
  ConsumerState<AudioTrimDialog> createState() => _AudioTrimDialogState();
}

class _AudioTrimDialogState extends ConsumerState<AudioTrimDialog> {
  // 波形图控制器（仅用于显示波形，不播放）
  late PlayerController _waveformController;
  // 独立的播放器（用于实际播放音频）
  late audio.AudioPlayer _audioPlayer;
  double? _totalDuration;
  double _startTime = 0;
  double _endTime = 30;
  bool _isLoading = true;
  bool _isTrimming = false;
  bool _isPlaying = false;
  
  // 转码任务跟踪
  String? _trimmingOutputPath; // 正在转码的输出文件路径
  
  // 波形图缩放和滚动状态
  double _waveformZoom = 1.0; // 波形图缩放倍数 (1.0 - 5.0)
  double _waveformOffset = 0.0; // 波形图滚动偏移 (0.0 - 1.0)
  
  // 拖拽状态
  bool? _isDraggingSelection; // null: 未拖拽, true: 拖拽选区, false: 拖拽波形图
  double _dragStartX = 0.0; // 拖拽开始时的X坐标
  double _dragStartTime = 0.0; // 拖拽开始时的起始时间
  double _dragStartOffset = 0.0; // 拖拽开始时的视图偏移
  
  // 播放位置监听
  StreamSubscription<Duration>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _waveformController = PlayerController();
    _audioPlayer = audio.AudioPlayer();
    _initializeAudio();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    
    // 先停止播放，再释放资源
    _stopPlayback().catchError((e) {
      debugPrint('AudioTrimDialog: error stopping playback in dispose: $e');
    });
    
    // 安全释放波形图控制器（audio_waveforms 插件有已知的 MediaCodec 状态问题）
    _disposeWaveformController();
    
    // 安全释放音频播放器
    try {
      _audioPlayer.dispose();
    } catch (e) {
      debugPrint('AudioTrimDialog: error disposing audio player: $e');
    }
    
    // 如果正在转码，清理临时文件（异步执行，不等待完成）
    if (_trimmingOutputPath != null) {
      _cleanupTrimmedFile().catchError((e) {
        debugPrint('AudioTrimDialog: error in dispose cleanup: $e');
      });
    }
    
    super.dispose();
  }
  
  /// 安全释放波形图控制器
  /// audio_waveforms 插件在 dispose 时可能抛出 IllegalStateException
  void _disposeWaveformController() {
    try {
      // 先尝试停止播放器（如果正在运行）
      _waveformController.stopPlayer().catchError((e) {
        // 忽略停止错误，继续释放
        debugPrint('AudioTrimDialog: error stopping waveform player: $e');
      });
    } catch (e) {
      // 忽略停止错误，继续释放
      debugPrint('AudioTrimDialog: error calling stopPlayer: $e');
    }
    
    // 延迟一小段时间，让 MediaCodec 完成清理
    // 注意：dispose 是同步的，所以这里只是尝试，不能保证完全解决问题
    try {
      _waveformController.dispose();
    } catch (e) {
      // 捕获所有异常，避免崩溃
      // audio_waveforms 插件在 MediaCodec 状态不正确时可能抛出异常
      debugPrint('AudioTrimDialog: error disposing waveform controller (ignored): $e');
    }
  }
  
  /// 清理转码产生的临时文件
  Future<void> _cleanupTrimmedFile() async {
    if (_trimmingOutputPath != null) {
      final pathToClean = _trimmingOutputPath;
      _trimmingOutputPath = null;
      
      try {
        final file = File(pathToClean!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('AudioTrimDialog: cleaned up temp file: $pathToClean');
        }
      } catch (e) {
        debugPrint('AudioTrimDialog: failed to cleanup temp file: $e');
      }
    }
  }
  
  /// 清理指定路径的文件（用于转码完成后发现对话框已关闭的情况）
  Future<void> _cleanupFile(String? filePath) async {
    if (filePath != null) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('AudioTrimDialog: cleaned up file: $filePath');
        }
      } catch (e) {
        debugPrint('AudioTrimDialog: failed to cleanup file: $e');
      }
    }
  }
  
  /// 确保裁剪区域在可见范围内
  void _ensureSelectionVisible() {
    if (_totalDuration == null) return;
    
    final visibleDuration = _totalDuration! / _waveformZoom;
    final visibleStartTime = _waveformOffset * _totalDuration!;
    final visibleEndTime = visibleStartTime + visibleDuration;
    
    // 如果裁剪区域不在可见范围内，调整视图偏移
    if (_startTime < visibleStartTime) {
      // 裁剪区域超出左边界，调整视图使裁剪区域左边界对齐
      _waveformOffset = (_startTime / _totalDuration!).clamp(0.0, 1.0);
    } else if (_endTime > visibleEndTime) {
      // 裁剪区域超出右边界，调整视图使裁剪区域右边界对齐
      final newVisibleStart = _endTime - visibleDuration;
      _waveformOffset = (newVisibleStart / _totalDuration!).clamp(0.0, 1.0);
    }
  }
  
  /// 停止播放并清理资源
  Future<void> _stopPlayback() async {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    await _audioPlayer.stop();
    if (mounted) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  /// 开始播放指定区域
  Future<void> _startPlayback() async {
    if (_totalDuration == null) return;
    
    try {
      // 确保裁剪区域在可见范围内
      if (mounted) {
        setState(() {
          _ensureSelectionVisible();
        });
      }
      
      // 停止当前播放（如果有）
      await _audioPlayer.stop();
      
      // 设置播放源并开始播放
      final source = audio.DeviceFileSource(widget.sourcePath);
      await _audioPlayer.play(source);
      
      // 等待播放器准备好后，定位到起始位置
      await Future.delayed(const Duration(milliseconds: 100));
      await _audioPlayer.seek(Duration(milliseconds: (_startTime * 1000).toInt()));
      
      if (mounted) {
        setState(() {
          _isPlaying = true;
        });
      }
      
      // 监听播放位置
      _positionSubscription?.cancel();
      _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
        final positionSeconds = position.inMilliseconds / 1000.0;
        
        // 到达结束时间自动停止
        if (positionSeconds >= _endTime) {
          _stopPlayback();
        }
      });
    } catch (e) {
      debugPrint('Error starting playback: $e');
      await _stopPlayback();
      if (mounted) {
        ToastService.instance.showCenter(
          AppLocalizations.of(context)!.previewFailed,
          false,
          isSuccess: false,
        );
      }
    }
  }

  /// 更新播放位置以匹配当前截取区域
  /// 当用户调整剪切位置时，如果正在播放，需要更新播放位置
  Future<void> _updatePlaybackPosition() async {
    if (!_isPlaying || _totalDuration == null) return;
    
    try {
      final currentPosition = await _audioPlayer.getCurrentPosition();
      if (currentPosition == null) return;
      
      final currentTime = currentPosition.inMilliseconds / 1000.0;
      
      // 如果当前位置不在新的截取区域内，重新定位到起始位置
      if (currentTime < _startTime || currentTime >= _endTime) {
        await _audioPlayer.seek(Duration(milliseconds: (_startTime * 1000).toInt()));
      }
    } catch (e) {
      debugPrint('Error updating playback position: $e');
    }
  }

  Future<void> _initializeAudio() async {
    try {
      // 准备波形图控制器（仅用于显示波形，不播放）
      // 如果波形图准备失败，仍然尝试继续（可能音频文件本身可以播放）
      try {
        await _waveformController.preparePlayer(
          path: widget.sourcePath,
          shouldExtractWaveform: true,
          volume: 0.0, // 静音，因为我们不会用它播放
        );
      } catch (e) {
        debugPrint('Error preparing waveform controller: $e');
      }
      
      // 获取音频时长（通过 audioService）
      // 注意：文件已经在显示对话框之前验证过，这里应该能成功
      final audioService = ref.read(audioServiceProvider);
      final duration = await audioService.getAudioDuration(widget.sourcePath);
      
      if (duration == null || duration <= 0 || !mounted) {
        if (mounted) {
          Navigator.of(context).pop();
          ToastService.instance.showCenter(
            AppLocalizations.of(context)!.getAudioInfoFailed,
            false,
            isSuccess: false,
          );
        }
        return;
      }
      
      // 提前预加载播放器：播放然后立即暂停，这样播放器就会加载音频文件
      try {
        final source = audio.DeviceFileSource(widget.sourcePath);
        await _audioPlayer.play(source);
        await _audioPlayer.pause();
        await _audioPlayer.seek(Duration.zero); // 重置到开头
      } catch (e) {
        debugPrint('Error preloading audio player: $e');
      }
      
      if (!mounted) return;
      
      // 监听播放状态变化
      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == audio.PlayerState.playing;
          });
        }
      });
      
      // 监听播放完成
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      });
      
      if (mounted) {
        setState(() {
          _totalDuration = duration;
          _endTime = min(duration, 30.0);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing audio: $e');
      if (mounted) {
        Navigator.of(context).pop();
        ToastService.instance.showCenter(
          AppLocalizations.of(context)!.getAudioInfoFailed,
          false,
          isSuccess: false,
        );
      }
    }
  }

  Future<void> _togglePreview() async {
    if (_isPlaying) {
      await _stopPlayback();
    } else {
      await _startPlayback();
    }
  }

  Future<void> _handleTrim() async {
    // 防止重复点击
    if (_isTrimming) {
      return;
    }
    
    final l10n = AppLocalizations.of(context)!;
    
    // 先停止播放，避免资源冲突
    await _stopPlayback();
    
    setState(() {
      _isTrimming = true;
      _trimmingOutputPath = null;
    });

    try {
      final audioService = ref.read(audioServiceProvider);
      final fileService = ref.read(audioFileServiceProvider);
      
      // 生成输出文件名（不含扩展名）
      final outputName = fileService.generateUniqueFileName('').replaceAll('.', '');
      
      // 裁剪音频
      final outputPath = await audioService.trimAudio(
        sourcePath: widget.sourcePath,
        startTime: _startTime,
        endTime: _endTime,
        outputPath: outputName,
      );

      // 检查是否已取消或对话框已关闭
      final wasCancelled = !_isTrimming;
      final isUnmounted = !mounted;
      
      if (outputPath != null) {
        // 如果已取消或对话框已关闭，清理文件
        if (wasCancelled || isUnmounted) {
          await _cleanupFile(outputPath);
          return;
        }
        
        // 转码成功且未取消，清除跟踪路径（文件将被使用）
        setState(() {
          _trimmingOutputPath = null;
        });
        
        widget.onComplete?.call(outputPath);
        if (mounted) {
          Navigator.of(context).pop(outputPath);
        }
      } else {
        // 转码失败
        if (mounted) {
          setState(() {
            _isTrimming = false;
            _trimmingOutputPath = null;
          });
          ToastService.instance.showCenter(
            l10n.trimFailed,
            false,
            isSuccess: false,
          );
        }
      }
    } catch (e) {
      debugPrint('Error in _handleTrim: $e');
      
      // 检查是否已取消
      final wasCancelled = !_isTrimming;
      final isUnmounted = !mounted;
      
      if (mounted && !wasCancelled) {
        setState(() {
          _isTrimming = false;
          _trimmingOutputPath = null;
        });
        ToastService.instance.showCenter(
          l10n.trimFailed,
          false,
          isSuccess: false,
        );
      }
      
      // 如果已取消或对话框已关闭，尝试清理可能已创建的文件
      // 注意：由于无法获取实际文件路径，这里只能清理跟踪的路径
      if (wasCancelled || isUnmounted) {
        await _cleanupTrimmedFile();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // 用户取消，标记转码为已取消
          if (_isTrimming) {
            setState(() {
              _isTrimming = false;
            });
            // 异步清理临时文件（不等待完成）
            _cleanupTrimmedFile().catchError((e) {
              debugPrint('AudioTrimDialog: error in onPopInvoked cleanup: $e');
            });
          }
        }
      },
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: LinuSpacing.lg, vertical: LinuSpacing.xl),
        child: Container(
        width: min(screenWidth - 32, 600),
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(LinuSpacing.lg),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题栏
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.trimAudio,
                        style: theme.textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () async {
                          if (_isPlaying) {
                            await _audioPlayer.stop();
                          }
                          // 如果正在转码，标记为已取消，转码完成后会自动清理
                          if (_isTrimming) {
                            setState(() {
                              _isTrimming = false;
                            });
                            // 异步清理临时文件（不等待完成）
                            _cleanupTrimmedFile().catchError((e) {
                              debugPrint('AudioTrimDialog: error in close button cleanup: $e');
                            });
                          }
                          if (!mounted) return;
                          Navigator.of(context).pop();
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: LinuSpacing.xs),
                  
                  // 操作提示
                  Text(
                    l10n.trimAudioHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  const SizedBox(height: LinuSpacing.md),
                  
                  // 音频信息
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.totalDuration(_formatDuration(_totalDuration!)),
                        style: LinuTextStyles.caption,
                      ),
                      Text(
                        l10n.trimmedDuration(_formatDuration(_endTime - _startTime)),
                        style: LinuTextStyles.caption.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: LinuSpacing.lg),
                  
                  // 波形图缩放轴
                  _buildZoomAxis(theme, l10n),
                  
                  const SizedBox(height: LinuSpacing.sm),
                  
                  // 波形图和选择器
                  _buildWaveformSelector(theme),
                  
                  const SizedBox(height: LinuSpacing.sm),
                  
                  // 选区时长调节轴
                  _buildSelectionAxis(theme, l10n),
                  
                  const SizedBox(height: LinuSpacing.lg),
                  
                  // 操作按钮
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 18,
                          ),
                          label: Text(_isPlaying ? l10n.stop : l10n.preview),
                          onPressed: _togglePreview,
                        ),
                      ),
                      const SizedBox(width: LinuSpacing.sm),
                      Expanded(
                        child: FilledButton.icon(
                          icon: _isTrimming
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check, size: 18),
                          label: Text(l10n.confirm),
                          onPressed: (_isTrimming || (_endTime - _startTime) >= 30.01)
                              ? null
                              : _handleTrim,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  // 波形图缩放轴
  Widget _buildZoomAxis(ThemeData theme, AppLocalizations l10n) {
    final isDark = theme.brightness == Brightness.dark;
    
    return Row(
      children: [
        // 标签
        SizedBox(
          width: 64,
          child: Text(
            l10n.zoomLevel,
            style: LinuTextStyles.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.remove_rounded,
            size: 18,
            color: _waveformZoom > 1.0
                ? (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText)
                : (isDark ? LinuColors.darkSecondaryText : LinuColors.lightSecondaryText),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          onPressed: _waveformZoom > 1.0
              ? () {
                  setState(() {
                    _waveformZoom = max(1.0, _waveformZoom - 0.5);
                    _adjustWaveformOffsetForZoom();
                  });
                }
              : null,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: _waveformZoom,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              onChanged: (value) {
                setState(() {
                  _waveformZoom = value;
                  _adjustWaveformOffsetForZoom();
                });
              },
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add_rounded,
            size: 18,
            color: _waveformZoom < 5.0
                ? (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText)
                : (isDark ? LinuColors.darkSecondaryText : LinuColors.lightSecondaryText),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          onPressed: _waveformZoom < 5.0
              ? () {
                  setState(() {
                    _waveformZoom = min(5.0, _waveformZoom + 0.5);
                    _adjustWaveformOffsetForZoom();
                  });
                }
              : null,
        ),
        SizedBox(
          width: 32,
          child: Text(
            '${_waveformZoom.toStringAsFixed(1)}x',
            style: LinuTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
  
  /// 缩放时调整视图偏移，保持截取区域在视野中
  void _adjustWaveformOffsetForZoom() {
    if (_totalDuration == null) return;
    
    final selectionCenter = (_startTime + _endTime) / 2;
    final visibleDuration = _totalDuration! / _waveformZoom;
    
    final newVisibleStart = selectionCenter - visibleDuration / 2;
    _waveformOffset = (newVisibleStart / _totalDuration!).clamp(0.0, 1.0);
    
    final visibleStartTime = _waveformOffset * _totalDuration!;
    final visibleEndTime = visibleStartTime + visibleDuration;
    
    if (_startTime < visibleStartTime) {
      _waveformOffset = (_startTime / _totalDuration!).clamp(0.0, 1.0);
    } else if (_endTime > visibleEndTime) {
      final adjustedVisibleStart = _endTime - visibleDuration;
      _waveformOffset = (adjustedVisibleStart / _totalDuration!).clamp(0.0, 1.0);
    }
  }

  // 选区时长调节轴
  Widget _buildSelectionAxis(ThemeData theme, AppLocalizations l10n) {
    final isDark = theme.brightness == Brightness.dark;
    final currentDuration = _endTime - _startTime;
    final maxAllowedDuration = min(_totalDuration ?? 30, 30.0);
    
    return Row(
      children: [
        // 标签
        SizedBox(
          width: 64,
          child: Text(
            l10n.selectionDuration,
            style: LinuTextStyles.caption.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            maxLines: 1,
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.remove_rounded,
            size: 18,
            color: currentDuration > 1.0
                ? (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText)
                : (isDark ? LinuColors.darkSecondaryText : LinuColors.lightSecondaryText),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          onPressed: currentDuration > 1.0
              ? () => _adjustSelectionDuration(-1.0)
              : null,
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
            ),
            child: Slider(
              value: currentDuration.clamp(1.0, maxAllowedDuration),
              min: 1.0,
              max: maxAllowedDuration,
              divisions: ((maxAllowedDuration - 1.0) * 2).toInt(),
              onChanged: (value) {
                _setSelectionDuration(value);
              },
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.add_rounded,
            size: 18,
            color: currentDuration < maxAllowedDuration
                ? (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText)
                : (isDark ? LinuColors.darkSecondaryText : LinuColors.lightSecondaryText),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
          onPressed: currentDuration < maxAllowedDuration
              ? () => _adjustSelectionDuration(1.0)
              : null,
        ),
        SizedBox(
          width: 32,
          child: Text(
            _formatDuration(currentDuration),
            style: LinuTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
  
  /// 调整选区时长
  void _adjustSelectionDuration(double delta) {
    final currentDuration = _endTime - _startTime;
    final maxAllowedDuration = min(_totalDuration ?? 30, 30.0);
    final newDuration = (currentDuration + delta).clamp(1.0, maxAllowedDuration);
    _setSelectionDuration(newDuration);
  }
  
  /// 设置选区时长
  void _setSelectionDuration(double duration) {
    setState(() {
      final center = (_startTime + _endTime) / 2;
      _startTime = (center - duration / 2).clamp(0.0, _totalDuration!);
      _endTime = (_startTime + duration).clamp(0.0, _totalDuration!);
      
      if (_endTime > _totalDuration!) {
        _endTime = _totalDuration!;
        _startTime = (_endTime - duration).clamp(0.0, _totalDuration!);
      }
    });
    if (_isPlaying) {
      _updatePlaybackPosition();
    }
  }

  Widget _buildWaveformSelector(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    
    // 计算当前可见的时间范围
    final visibleDuration = (_totalDuration ?? 0) / _waveformZoom;
    final visibleStartTime = _waveformOffset * (_totalDuration ?? 0);
    final visibleEndTime = visibleStartTime + visibleDuration;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 波形图可见区域时间标记
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(visibleStartTime),
                style: LinuTextStyles.caption.copyWith(
                  color: isDark ? LinuColors.darkSecondaryText : LinuColors.lightSecondaryText,
                  fontSize: 10,
                ),
              ),
              if (_waveformZoom > 1.0)
                Text(
                  '${(_totalDuration! / _waveformZoom).toStringAsFixed(1)}s',
                  style: LinuTextStyles.caption.copyWith(
                    color: isDark ? LinuColors.darkSecondaryText : LinuColors.lightSecondaryText,
                    fontSize: 10,
                  ),
                ),
              Text(
                _formatDuration(visibleEndTime),
                style: LinuTextStyles.caption.copyWith(
                  color: isDark ? LinuColors.darkSecondaryText : LinuColors.lightSecondaryText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // 波形图容器
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: (isDark ? LinuColors.darkCardSurface : LinuColors.lightCardSurface),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDark ? LinuColors.darkBorder : LinuColors.lightBorder,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                
                return GestureDetector(
              onPanStart: (details) {
                if (_totalDuration == null) return;
                
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                
                // 计算当前可见的时间范围
                final visibleDuration = _totalDuration! / _waveformZoom;
                final visibleStartTime = _waveformOffset * _totalDuration!;
                
                // 计算选区在屏幕上的位置
                final selectionStartX = (((_startTime - visibleStartTime) / visibleDuration) * width).clamp(0.0, width);
                final selectionEndX = (((_endTime - visibleStartTime) / visibleDuration) * width).clamp(0.0, width);
                
                // 判断是否在选区内（增加容差）
                final isInSelection = localPosition.dx >= selectionStartX - 20 && 
                                     localPosition.dx <= selectionEndX + 20;
                
                setState(() {
                  _isDraggingSelection = isInSelection;
                  _dragStartX = localPosition.dx;
                  _dragStartTime = _startTime;
                  _dragStartOffset = _waveformOffset;
                });
              },
              onPanUpdate: (details) {
                if (_totalDuration == null || _isDraggingSelection == null) return;
                
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localPosition = box.globalToLocal(details.globalPosition);
                final deltaX = localPosition.dx - _dragStartX;
                
                // 计算当前可见的时间范围
                final visibleDuration = _totalDuration! / _waveformZoom;
                
                setState(() {
                  if (_isDraggingSelection == true) {
                    // 拖动选区：改变截取区的时间位置
                    final deltaTime = (deltaX / width) * visibleDuration;
                    final duration = _endTime - _startTime;
                    final newStartTime = (_dragStartTime + deltaTime).clamp(0.0, _totalDuration! - duration);
                    final newEndTime = newStartTime + duration;
                    
                    _startTime = newStartTime;
                    _endTime = newEndTime;
                    
                    // 确保选区在可见范围内，如果超出则调整视图偏移
                    final visibleStartTime = _waveformOffset * _totalDuration!;
                    final visibleEndTime = visibleStartTime + visibleDuration;
                    
                    if (_startTime < visibleStartTime) {
                      // 选区超出左边界，调整视图使选区左边界对齐
                      _waveformOffset = (_startTime / _totalDuration!).clamp(0.0, 1.0);
                    } else if (_endTime > visibleEndTime) {
                      // 选区超出右边界，调整视图使选区右边界对齐
                      final newVisibleStart = _endTime - visibleDuration;
                      _waveformOffset = (newVisibleStart / _totalDuration!).clamp(0.0, 1.0);
                    }
                    
                    // 如果正在播放，更新播放位置
                    if (_isPlaying) {
                      _updatePlaybackPosition();
                    }
                  } else {
                    // 拖动波形图视图
                    if (_waveformZoom > 1.0) {
                      final deltaTime = -(deltaX / width) * visibleDuration;
                      final visibleStartTime = _dragStartOffset * _totalDuration!;
                      final newVisibleStart = visibleStartTime + deltaTime;
                      
                      // 先计算视图可以自由移动的范围
                      final minVisibleStart = 0.0;
                      final maxVisibleStart = _totalDuration! - visibleDuration;
                      
                      // 限制视图偏移在有效范围内
                      final clampedVisibleStart = newVisibleStart.clamp(minVisibleStart, maxVisibleStart);
                      _waveformOffset = (clampedVisibleStart / _totalDuration!).clamp(0.0, 1.0);
                      
                      // 计算新的可见范围
                      final newVisibleEndTime = clampedVisibleStart + visibleDuration;
                      final selectionDuration = _endTime - _startTime;
                      
                      // 如果截取区域超出可见范围，则带动截取区域一起移动
                      if (_startTime < clampedVisibleStart) {
                        // 截取区域超出左边界，将截取区域左边界对齐到可见区域左边界
                        _startTime = clampedVisibleStart;
                        _endTime = _startTime + selectionDuration;
                        // 确保不超出总时长
                        if (_endTime > _totalDuration!) {
                          _endTime = _totalDuration!;
                          _startTime = _endTime - selectionDuration;
                        }
                      } else if (_endTime > newVisibleEndTime) {
                        // 截取区域超出右边界，将截取区域右边界对齐到可见区域右边界
                        _endTime = newVisibleEndTime;
                        _startTime = _endTime - selectionDuration;
                        // 确保不小于0
                        if (_startTime < 0) {
                          _startTime = 0;
                          _endTime = selectionDuration;
                        }
                      }
                      
                      // 如果正在播放，更新播放位置
                      if (_isPlaying) {
                        _updatePlaybackPosition();
                      }
                    }
                  }
                });
              },
              onPanEnd: (_) {
                setState(() {
                  _isDraggingSelection = null;
                });
              },
              onPanCancel: () {
                setState(() {
                  _isDraggingSelection = null;
                });
              },
              child: Stack(
                children: [
                  // 波形图
                  Transform.translate(
                    offset: Offset(-_waveformOffset * width * (_waveformZoom - 1), 0),
                    child: Transform.scale(
                      scaleX: _waveformZoom,
                      alignment: Alignment.centerLeft,
                      child: AudioFileWaveforms(
                        size: Size(width, 160),
                        playerController: _waveformController,
                        waveformType: WaveformType.long,
                        enableSeekGesture: false,
                        playerWaveStyle: PlayerWaveStyle(
                          fixedWaveColor: (isDark 
                              ? LinuColors.darkSecondaryText 
                              : LinuColors.lightSecondaryText).withValues(alpha: 0.3),
                          liveWaveColor: isDark 
                              ? LinuColors.darkPrimaryAccent 
                              : LinuColors.lightPrimaryAccent,
                          spacing: 4,
                          showSeekLine: false,
                        ),
                      ),
                    ),
                  ),
                  
                  // 选择区域覆盖层
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _WaveformSelectorPainter(
                        startTime: _startTime,
                        endTime: _endTime,
                        totalDuration: _totalDuration!,
                        waveformZoom: _waveformZoom,
                        waveformOffset: _waveformOffset,
                        waveformWidth: width,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ],
              ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// 波形选择器绘制器
class _WaveformSelectorPainter extends CustomPainter {
  final double startTime;
  final double endTime;
  final double totalDuration;
  final double waveformZoom;
  final double waveformOffset;
  final double waveformWidth;
  final bool isDark;

  _WaveformSelectorPainter({
    required this.startTime,
    required this.endTime,
    required this.totalDuration,
    required this.waveformZoom,
    required this.waveformOffset,
    required this.waveformWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 计算当前可见的时间范围
    final visibleDuration = totalDuration / waveformZoom;
    final visibleStartTime = waveformOffset * totalDuration;
    
    // 计算选区在可见范围内的相对位置
    final startX = ((startTime - visibleStartTime) / visibleDuration) * waveformWidth;
    final endX = ((endTime - visibleStartTime) / visibleDuration) * waveformWidth;
    
    // 绘制未选中区域的遮罩
    final maskPaint = Paint()
      ..color = (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7);
    
    // 左侧遮罩
    if (startX > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, min(startX, size.width), size.height),
        maskPaint,
      );
    }
    
    // 右侧遮罩
    if (endX < size.width) {
      canvas.drawRect(
        Rect.fromLTWH(max(endX, 0), 0, size.width - max(endX, 0), size.height),
        maskPaint,
      );
    }
    
    // 只在选区可见时绘制边框和手柄
    if (endX > 0 && startX < size.width) {
      // 绘制选择区域的边框
      final borderPaint = Paint()
        ..color = isDark ? LinuColors.darkPrimaryAccent : LinuColors.lightPrimaryAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      
      final visibleStartX = startX.clamp(0.0, size.width);
      final visibleEndX = endX.clamp(0.0, size.width);
      
      canvas.drawRect(
        Rect.fromLTRB(visibleStartX, 0, visibleEndX, size.height),
        borderPaint,
      );
      
      // 绘制时间标记
      final textPainter = TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      
      final textStyle = TextStyle(
        color: isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      );
      
      // 左侧时间标记
      if (startX >= 0 && startX <= size.width) {
        textPainter.text = TextSpan(
          text: _formatTime(startTime),
          style: textStyle,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            (startX - textPainter.width / 2).clamp(4.0, size.width - textPainter.width - 4),
            8,
          ),
        );
      }
      
      // 右侧时间标记
      if (endX >= 0 && endX <= size.width) {
        textPainter.text = TextSpan(
          text: _formatTime(endTime),
          style: textStyle,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            (endX - textPainter.width / 2).clamp(4.0, size.width - textPainter.width - 4),
            size.height - textPainter.height - 8,
          ),
        );
      }
    }
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  bool shouldRepaint(covariant _WaveformSelectorPainter oldDelegate) {
    return oldDelegate.startTime != startTime ||
        oldDelegate.endTime != endTime ||
        oldDelegate.totalDuration != totalDuration ||
        oldDelegate.waveformZoom != waveformZoom ||
        oldDelegate.waveformOffset != waveformOffset ||
        oldDelegate.isDark != isDark;
  }
}
