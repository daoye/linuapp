import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:app/features/audio/providers/audio_management_provider.dart';
import 'package:app/features/audio/services/audio_file_service.dart';
import 'package:app/features/audio/services/audio_service.dart';
import 'package:app/features/audio/widgets/audio_list_item.dart';
import 'package:app/features/audio/widgets/audio_name_dialog.dart';
import 'package:app/features/audio/widgets/audio_trim_dialog.dart';
import 'package:app/shared/local_notification_service.dart';
import 'package:app/shared/services/toast_service.dart';
import 'package:app/shared/constants.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/l10n/app_localizations.dart';

class AudioManagementPage extends ConsumerWidget {
  const AudioManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final audioListAsync = ref.watch(audioListProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? LinuColors.darkListBackground : LinuColors.lightListBackground,
      appBar: AppBar(
        title: Text(l10n.audioManagement),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: l10n.importAudio,
            onPressed: () => _handleImportAudio(context, ref),
          ),
        ],
      ),
      body: ToastOverlay(
        showCenter: true,
        showBottom: false,
        child: audioListAsync.when(
          data: (audioList) {
            if (audioList.isEmpty) {
              return _buildEmptyState(l10n, theme);
            }
            return ListView.separated(
              padding: EdgeInsets.only(
                left: LinuSpacing.md,
                right: LinuSpacing.md,
                top: LinuSpacing.md,
                bottom: LinuSpacing.md + MediaQuery.of(context).padding.bottom,
              ),
              itemCount: audioList.length,
              separatorBuilder: (context, index) => const SizedBox(height: LinuSpacing.sm),
              itemBuilder: (context, index) {
                final audio = audioList[index];
                return AudioListItem(
                  audio: audio,
                  onRefresh: () {
                    ref.invalidate(audioListProvider);
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 64,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: LinuSpacing.md),
                Text(
                  l10n.loadFailed,
                  style: LinuTextStyles.body.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: LinuSpacing.lg,
          vertical: LinuSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? LinuColors.darkPrimaryAccent : LinuColors.lightPrimaryAccent)
                    .withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.music_note_rounded,
                size: 48,
                color: isDark ? LinuColors.darkPrimaryAccent : LinuColors.lightPrimaryAccent,
              ),
            ),
            const SizedBox(height: LinuSpacing.lg),
            Text(
              l10n.noCustomAudio,
              style: LinuTextStyles.body,
            ),
            const SizedBox(height: LinuSpacing.xs),
            Text(
              l10n.tapAddToImport,
              style: LinuTextStyles.caption,
            ),
            const SizedBox(height: LinuSpacing.xl),
            // API 示例卡片
            _buildApiExampleCard(l10n, theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildApiExampleCard(AppLocalizations l10n, ThemeData theme, bool isDark) {
    final cardColor = isDark
        ? LinuColors.darkCardSurface
        : LinuColors.lightCardSurface;
    
    final borderColor = isDark
        ? LinuColors.darkBorder.withValues(alpha: 0.5)
        : LinuColors.lightBorder.withValues(alpha: 0.5);

    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(LinuSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(LinuRadius.large),
        border: Border.all(color: borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.code_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: LinuSpacing.sm),
              Text(
                l10n.customSoundApiTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: LinuSpacing.sm),
          Text(
            l10n.customSoundApiDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: LinuSpacing.md),
          // API 示例代码
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(LinuSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? LinuColors.darkElevatedSurface
                  : LinuColors.lightChatBackground,
              borderRadius: BorderRadius.circular(LinuRadius.medium),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: LinuSpacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: LinuColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'GET',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: LinuColors.success,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(width: LinuSpacing.sm),
                Expanded(
                  child: SelectableText(
                    '${ApiConstants.pushPath}/ios/{token}?sound=my-sound',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: LinuSpacing.md),
          // 查看文档按钮
          Center(
            child: GestureDetector(
              onTap: () => launchUrl(Uri.parse(ApiConstants.docsUrl)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.viewDocs,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleImportAudio(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    
    // 请求存储权限（Android）
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        if (context.mounted) {
          ToastService.instance.showCenter(
            l10n.storagePermissionDenied,
            false,
            isSuccess: false,
          );
        }
        return;
      }
    }

    try {
      // 选择文件（允许音频和视频文件，因为可以从视频中提取音频）
      // iOS 上使用 FileType.custom 并指定扩展名，避免 FileType.audio 的崩溃问题
      // 对于 iCloud 文件，使用 withData: true 来确保文件被下载
      final result = await FilePicker.platform.pickFiles(
        type: Platform.isIOS ? FileType.custom : FileType.any,
        allowedExtensions: Platform.isIOS ? ['mp3', 'wav', 'm4a', 'aac', 'caf', 'aiff', 'ogg', 'mp4', 'mov', 'avi'] : null,
        allowMultiple: false,
        withData: Platform.isIOS, // iOS 上需要加载数据以确保 iCloud 文件被下载
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.first;
      final originalFileName = file.name; // 保存原始文件名

      String? sourcePath = file.path;

      // iOS 上如果 path 为 null（可能是 iCloud 文件），尝试使用临时文件
      if (Platform.isIOS && sourcePath == null && file.bytes != null) {
        // 将文件数据保存到临时文件
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${file.name}');
        await tempFile.writeAsBytes(file.bytes!);
        sourcePath = tempFile.path;
      }

      if (sourcePath == null || sourcePath.isEmpty) {
        if (context.mounted) {
          ToastService.instance.showCenter(
            l10n.filePathNotAvailable,
            false,
            isSuccess: false,
          );
        }
        return;
      }

      // 在显示对话框之前，先验证文件是否可以处理
      if (context.mounted) {
        ToastService.instance.showCenter(
          l10n.loadingAudio,
          true, // 持续显示
          isSuccess: true,
        );
      }

      // 此时 sourcePath 已经确保不为 null（前面已验证）
      final validSourcePath = sourcePath;

      try {
        final audioService = ref.read(audioServiceProvider);
        final duration = await audioService.getAudioDuration(validSourcePath);
        
        if (duration == null || duration <= 0) {
          if (context.mounted) {
            ToastService.instance.clearAll();
            ToastService.instance.showCenter(
              l10n.getAudioInfoFailed,
              false,
              isSuccess: false,
            );
          }
          return;
        }
      } catch (e) {
        debugPrint('Error validating audio file: $e');
        if (context.mounted) {
          ToastService.instance.clearAll();
          ToastService.instance.showCenter(
            l10n.getAudioInfoFailed,
            false,
            isSuccess: false,
          );
        }
        return;
      }

      // 隐藏加载指示器
      if (context.mounted) {
        ToastService.instance.clearAll();
      }

      // 显示裁剪对话框（内部已有 loading 状态）
      if (context.mounted) {
        final trimmedFilePath = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AudioTrimDialog(
            sourcePath: validSourcePath,
            originalFileName: originalFileName,
            onComplete: (path) {
              // onComplete 会在 AudioTrimDialog 内部调用，这里不需要再次 pop
            },
          ),
        );

        // 裁剪完成后，显示名称设置对话框
        if (trimmedFilePath != null && context.mounted) {
          await _showNameDialog(context, ref, trimmedFilePath, originalFileName);
        }
      }
    } catch (e) {
      debugPrint('AudioManagementPage: _handleImportAudio error: $e');
      if (context.mounted) {
        ToastService.instance.showCenter(
          l10n.filePathNotAvailable,
          false,
          isSuccess: false,
        );
      }
    }
  }

  /// 显示名称设置对话框
  Future<void> _showNameDialog(
    BuildContext context,
    WidgetRef ref,
    String trimmedFilePath,
    String originalFileName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final fileService = ref.read(audioFileServiceProvider);
    
    // 从文件路径中提取扩展名
    final fileExtension = p.extension(trimmedFilePath);
    
    // 生成友好的默认名称（不含扩展名）
    final defaultName = fileService.generateFriendlyAudioName(originalFileName);

    final confirmed = await AudioNameDialog.show(
      context,
      title: l10n.setAudioName,
      hint: l10n.audioNameHint,
      defaultName: defaultName,
      extension: fileExtension,
      maxLength: 30,
    );

    if (confirmed != null && confirmed.isNotEmpty && context.mounted) {
      // 重命名文件
      final newPath = await fileService.renameAudioFile(trimmedFilePath, confirmed);
      
      if (newPath != null) {
        // Android：为该铃音创建通知 channel，推送时按 sound name 使用
        final notificationService = ref.read(localNotificationServiceProvider);
        await notificationService.createSoundChannel(confirmed, newPath);
        // 刷新列表
        ref.invalidate(audioListProvider);
        
        ToastService.instance.showCenter(
          l10n.audioImported,
          false,
          isSuccess: true,
        );
      } else {
        // 重命名失败，清理临时文件
        await _cleanupTempFile(trimmedFilePath);
        ToastService.instance.showCenter(
          l10n.renameFailed,
          false,
          isSuccess: false,
        );
      }
    } else {
      // 用户取消或输入为空，删除临时文件
      if (context.mounted) {
        await _cleanupTempFile(trimmedFilePath);
      }
    }
  }
  
  /// 清理临时文件
  Future<void> _cleanupTempFile(String filePath) async {
    try {
      final tempFile = File(filePath);
      if (await tempFile.exists()) {
        await tempFile.delete();
        debugPrint('AudioManagementPage: cleaned up temp file: $filePath');
      }
    } catch (e) {
      debugPrint('AudioManagementPage: failed to cleanup temp file: $e');
    }
  }
}
