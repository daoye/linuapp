import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final audioFileServiceProvider = Provider((ref) => AudioFileService());

/// 音频文件管理服务
class AudioFileService {
  /// 获取音频存储目录
  ///
  /// iOS: App Group 的 Library/Sounds 目录
  /// Android: 使用 getApplicationSupportDirectory + sounds，与后台 isolate 路径一致
  Future<Directory> getAudioDirectory() async {
    if (Platform.isIOS) {
      final appGroupId = 'group.com.aprilzz.linu';
      final appGroupPath = '/var/mobile/Containers/Shared/AppGroup/$appGroupId/Library/Sounds';
      final dir = Directory(appGroupPath);
      if (!await dir.exists()) {
        final docsDir = await getApplicationDocumentsDirectory();
        final soundsDir = Directory(p.join(docsDir.path, 'sounds'));
        if (!await soundsDir.exists()) {
          await soundsDir.create(recursive: true);
        }
        return soundsDir;
      }
      return dir;
    } else {
      // 与后台 FCM handler 一致，避免 isolate 下 getApplicationDocumentsDirectory 路径不同
      final supportDir = await getApplicationSupportDirectory();
      final soundsDir = Directory(p.join(supportDir.path, 'sounds'));
      if (!await soundsDir.exists()) {
        await soundsDir.create(recursive: true);
      }
      return soundsDir;
    }
  }

  /// 删除音频文件
  /// 
  /// [filePath] 文件路径
  /// 
  /// 返回是否删除成功
  Future<bool> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('AudioFileService: deleted file: $filePath');
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('AudioFileService: deleteAudioFile error: $e');
      return false;
    }
  }

  /// 扫描音频目录，返回文件列表
  /// 
  /// 返回文件路径列表
  Future<List<String>> scanAudioFiles() async {
    try {
      final dir = await getAudioDirectory();
      if (!await dir.exists()) {
        return [];
      }

      final files = await dir.list().where((entity) {
        if (entity is! File) return false;
        final extension = p.extension(entity.path).toLowerCase();
        return ['.mp3', '.wav', '.caf', '.m4a', '.aac', '.ogg'].contains(extension);
      }).map((entity) => entity.path).toList();

      debugPrint('AudioFileService: found ${files.length} audio files');
      return files;
    } catch (e) {
      debugPrint('AudioFileService: scanAudioFiles error: $e');
      return [];
    }
  }

  /// 获取音频信息
  /// 
  /// [filePath] 文件路径
  /// 
  /// 返回 Map 包含：
  /// - name: 文件名
  /// - size: 文件大小（字节）
  /// - extension: 文件扩展名
  Future<Map<String, dynamic>?> getAudioInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) return null;

      final stat = await file.stat();
      return {
        'name': p.basename(filePath),
        'size': stat.size,
        'extension': p.extension(filePath),
        'path': filePath,
      };
    } catch (e) {
      debugPrint('AudioFileService: getAudioInfo error: $e');
      return null;
    }
  }

  /// 生成唯一的文件名
  /// 
  /// [extension] 文件扩展名（含点，如 '.caf'）
  /// 
  /// 返回文件名（不含路径）
  String generateUniqueFileName(String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'audio_$timestamp$extension';
  }

  /// 生成友好的默认音频名称
  /// 
  /// [originalFileName] 原始文件名（可以包含扩展名）
  /// 
  /// 返回友好的名称（不含扩展名，最多20个字符）
  String generateFriendlyAudioName(String originalFileName) {
    // 去除扩展名
    String nameWithoutExt = p.basenameWithoutExtension(originalFileName);
    
    // 清理特殊字符，只保留中文、英文、数字、空格、下划线、连字符
    nameWithoutExt = nameWithoutExt.replaceAll(RegExp(r'[^\w\s\u4e00-\u9fa5-]'), '');
    
    // 去除首尾空格
    nameWithoutExt = nameWithoutExt.trim();
    
    // 将多个连续空格替换为单个空格
    nameWithoutExt = nameWithoutExt.replaceAll(RegExp(r'\s+'), ' ');
    
    // 限制长度（最多20个字符）
    if (nameWithoutExt.length > 20) {
      nameWithoutExt = nameWithoutExt.substring(0, 20);
    }
    
    // 如果名称太短或无效，使用默认名称
    if (nameWithoutExt.isEmpty || nameWithoutExt.length < 2) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return '自定义音频_${timestamp.toString().substring(timestamp.toString().length - 6)}';
    }
    
    return nameWithoutExt;
  }

  /// 重命名音频文件
  /// 
  /// [oldPath] 原文件路径
  /// [newName] 新文件名（不含扩展名）
  /// 
  /// 返回新文件路径，失败返回 null
  /// 如果文件名已存在，会自动添加数字后缀（如 _1, _2 等）
  Future<String?> renameAudioFile(String oldPath, String newName) async {
    try {
      final file = File(oldPath);
      if (!await file.exists()) return null;

      // 获取扩展名
      final extension = p.extension(oldPath);
      final directory = file.parent;
      
      // 构建新文件路径
      String baseName = newName;
      String newPath = p.join(directory.path, '$baseName$extension');
      
      // 如果文件名已存在，自动添加数字后缀
      int suffix = 1;
      while (await File(newPath).exists()) {
        baseName = '${newName}_$suffix';
        newPath = p.join(directory.path, '$baseName$extension');
        suffix++;
        
        // 防止无限循环（最多尝试1000次）
        if (suffix > 1000) {
          debugPrint('AudioFileService: too many duplicate names, giving up');
          return null;
        }
      }

      // 重命名文件
      final newFile = await file.rename(newPath);
      debugPrint('AudioFileService: renamed $oldPath to $newPath');
      return newFile.path;
    } catch (e) {
      debugPrint('AudioFileService: renameAudioFile error: $e');
      return null;
    }
  }
}
