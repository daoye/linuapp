import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:app/features/audio/models/audio_item.dart';
import 'package:app/features/audio/providers/audio_management_provider.dart';
import 'package:app/features/audio/services/audio_file_service.dart';
import 'package:app/features/audio/widgets/audio_name_dialog.dart';
import 'package:path/path.dart' as p;
import 'package:app/shared/local_notification_service.dart';
import 'package:app/shared/services/toast_service.dart';
import 'package:app/shared/widgets/confirm_dialog.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/l10n/app_localizations.dart';

class AudioListItem extends ConsumerWidget {
  final AudioItem audio;
  final VoidCallback onRefresh;

  const AudioListItem({
    super.key,
    required this.audio,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final currentPlaying = ref.watch(currentPlayingAudioProvider);
    final isPlaying = currentPlaying == audio.id;
    final playerState = ref.watch(audioPlayerStateProvider);
    
    final isActuallyPlaying = isPlaying && playerState.asData?.value == PlayerState.playing;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? LinuColors.darkCardSurface : LinuColors.lightCardSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? LinuColors.darkBorder : LinuColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText)
                .withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(LinuSpacing.md),
        child: Row(
          children: [
            _buildIcon(isDark),
            const SizedBox(width: LinuSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    audio.name,
                    style: LinuTextStyles.body,
                  ),
                  const SizedBox(height: LinuSpacing.xs),
                  Row(
                    children: [
                      _buildTypeLabel(l10n, isDark),
                      if (audio.duration != null) ...[
                        const SizedBox(width: LinuSpacing.sm),
                        Text(
                          _formatDuration(audio.duration!),
                          style: LinuTextStyles.caption,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: LinuSpacing.sm),
            _buildPlayButton(context, ref, isActuallyPlaying),
            if (audio.type == AudioType.custom) ...[
              const SizedBox(width: LinuSpacing.xs),
              _buildRenameButton(context, ref, l10n),
              _buildDeleteButton(context, ref, l10n),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(bool isDark) {
    final iconColor = isDark ? LinuColors.darkPrimaryAccent : LinuColors.lightPrimaryAccent;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: iconColor.withValues(alpha: 0.1),
      ),
      child: Icon(
        Icons.music_note_rounded,
        size: 20,
        color: iconColor,
      ),
    );
  }

  Widget _buildTypeLabel(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: LinuSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: (isDark ? LinuColors.darkPrimaryText : LinuColors.lightPrimaryText)
            .withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        l10n.customAudio,
        style: LinuTextStyles.caption.copyWith(fontSize: 10),
      ),
    );
  }

  Widget _buildPlayButton(BuildContext context, WidgetRef ref, bool isPlaying) {
    return IconButton(
      icon: Icon(
        isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded,
        size: 24,
      ),
      onPressed: () async {
        final controller = ref.read(audioPlaybackControllerProvider);
        await controller.play(audio);
      },
    );
  }

  Widget _buildRenameButton(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return IconButton(
      icon: const Icon(Icons.edit_outlined, size: 20),
      onPressed: () async {
        // 从文件路径中提取扩展名和文件名（不含扩展名）
        String? extension;
        String nameWithoutExtension = audio.name;
        
        if (audio.path != null) {
          extension = p.extension(audio.path!);
          if (extension.isEmpty) {
            extension = null;
          } else {
            // 从路径中提取不含扩展名的文件名，确保输入框不包含扩展名
            nameWithoutExtension = p.basenameWithoutExtension(audio.path!);
          }
        } else {
          // 如果没有路径，尝试从 name 中去除扩展名（如果存在）
          final nameExt = p.extension(audio.name);
          if (nameExt.isNotEmpty) {
            nameWithoutExtension = p.basenameWithoutExtension(audio.name);
            extension = nameExt;
          }
        }

        final confirmed = await AudioNameDialog.show(
          context,
          title: l10n.renameAudio,
          defaultName: nameWithoutExtension,
          extension: extension,
          maxLength: 30,
        );

        if (confirmed != null && confirmed.isNotEmpty && audio.path != null) {
          final fileService = ref.read(audioFileServiceProvider);
          final newPath = await fileService.renameAudioFile(audio.path!, confirmed);
          if (newPath != null) {
            final notificationService = ref.read(localNotificationServiceProvider);
            await notificationService.deleteSoundChannel(audio.name);
            await notificationService.createSoundChannel(confirmed, newPath);
          }
          if (context.mounted) {
            if (newPath != null) {
              ToastService.instance.showCenter(
                l10n.renameSuccess,
                false,
                isSuccess: true,
              );
              onRefresh();
            } else {
              ToastService.instance.showCenter(
                l10n.renameFailed,
                false,
                isSuccess: false,
              );
            }
          }
        }
      },
    );
  }

  Widget _buildDeleteButton(BuildContext context, WidgetRef ref, AppLocalizations l10n) {
    return IconButton(
      icon: const Icon(Icons.delete_outline_rounded, size: 20),
      onPressed: () async {
        final confirmed = await ConfirmDialog.showDelete(
          context,
          title: l10n.deleteAudio,
          content: l10n.deleteAudioConfirm,
        );

        if (confirmed == true && audio.path != null) {
          // 如果正在播放该音频，先停止播放
          final currentPlaying = ref.read(currentPlayingAudioProvider);
          if (currentPlaying == audio.id) {
            final controller = ref.read(audioPlaybackControllerProvider);
            await controller.stop();
          }
          
          // 删除文件
          final fileService = ref.read(audioFileServiceProvider);
          final success = await fileService.deleteAudioFile(audio.path!);
          if (success) {
            final notificationService = ref.read(localNotificationServiceProvider);
            await notificationService.deleteSoundChannel(audio.name);
          }
          if (context.mounted) {
            if (success) {
              ToastService.instance.showCenter(
                l10n.audioDeleted,
                false,
                isSuccess: true,
              );
              onRefresh();
            } else {
              ToastService.instance.showCenter(
                l10n.deleteFailed,
                false,
                isSuccess: false,
              );
            }
          }
        }
      },
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
