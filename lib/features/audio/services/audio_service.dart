import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioServiceProvider = Provider((ref) => AudioService());

/// 音频服务
/// 
/// 通过 MethodChannel 与原生代码通信，实现音频相关功能
class AudioService {
  static const _channel = MethodChannel('com.aprilzz.linu/ringtone');

  /// 获取自定义音频列表
  /// 
  /// 返回 Map 列表，每个 Map 包含：
  /// - path: 文件路径
  /// - name: 文件名
  /// - duration: 时长（秒）
  Future<List<Map<String, dynamic>>> getCustomAudios() async {
    try {
      final result = await _channel.invokeMethod<List<Object?>>('getCustomAudios');
      if (result == null) return [];

      return result.map((item) {
        final map = item as Map<Object?, Object?>;
        return {
          'path': map['path']?.toString() ?? '',
          'name': map['name']?.toString() ?? '',
          'duration': (map['duration'] as num?)?.toDouble() ?? 0.0,
        };
      }).toList();
    } catch (e) {
      debugPrint('AudioService: getCustomAudios error: $e');
      return [];
    }
  }

  /// 裁剪音频
  /// 
  /// [sourcePath] 源文件路径
  /// [startTime] 开始时间（秒）
  /// [endTime] 结束时间（秒）
  /// [outputPath] 输出文件路径（不含扩展名）
  /// 
  /// 返回裁剪后的文件路径，失败返回 null
  Future<String?> trimAudio({
    required String sourcePath,
    required double startTime,
    required double endTime,
    required String outputPath,
  }) async {
    try {
      final result = await _channel.invokeMethod<String>('trimAudio', {
        'sourcePath': sourcePath,
        'startTime': startTime,
        'endTime': endTime,
        'outputPath': outputPath,
      });
      debugPrint('AudioService: trimAudio completed: $result');
      return result;
    } catch (e) {
      debugPrint('AudioService: trimAudio error: $e');
      return null;
    }
  }

  /// 获取音频时长
  /// 
  /// [filePath] 文件路径
  /// 
  /// 返回时长（秒），失败返回 null
  Future<double?> getAudioDuration(String filePath) async {
    try {
      final result = await _channel.invokeMethod<double>('getAudioDuration', {
        'filePath': filePath,
      });
      return result;
    } catch (e) {
      debugPrint('AudioService: getAudioDuration error: $e');
      return null;
    }
  }

  /// 启动 30s 来电式响铃（仅 Android）
  /// 由 Flutter 解密/解析后根据 priority 调用，sound 为解密后的名称。
  Future<bool> startRinging({
    required String title,
    required String body,
    String? sound,
  }) async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await _channel.invokeMethod<bool>('startRinging', {
        'title': title,
        'body': body,
        if (sound != null && sound.isNotEmpty) 'sound': sound,
      });
      return result ?? false;
    } catch (e) {
      debugPrint('AudioService: startRinging error: $e');
      return false;
    }
  }

  /// 停止 30s 响铃（仅 Android）
  Future<bool> stopRinging() async {
    if (!Platform.isAndroid) return false;
    try {
      final result = await _channel.invokeMethod<bool>('stopRinging');
      return result ?? false;
    } catch (e) {
      debugPrint('AudioService: stopRinging error: $e');
      return false;
    }
  }
}
