import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:app/features/audio/models/audio_item.dart';
import 'package:app/features/audio/services/audio_service.dart';

final audioListProvider = FutureProvider<List<AudioItem>>((ref) async {
  final audioService = ref.watch(audioServiceProvider);
  final customItems = <AudioItem>[];

  final customAudios = await audioService.getCustomAudios();
  for (final audio in customAudios) {
    final durationSeconds = audio['duration'] as double? ?? 0.0;
    final modifiedTimeMs = audio['modifiedTime'] as double? ?? 0.0;
    final modifiedTime = modifiedTimeMs > 0
        ? DateTime.fromMillisecondsSinceEpoch(modifiedTimeMs.toInt())
        : null;

    final path = audio['path'] ?? '';
    String nameWithoutExtension = audio['name'] ?? '';
    if (path.isNotEmpty) {
      nameWithoutExtension = p.basenameWithoutExtension(path);
    } else if (nameWithoutExtension.isNotEmpty) {
      nameWithoutExtension = p.basenameWithoutExtension(nameWithoutExtension);
    }

    customItems.add(AudioItem(
      id: path,
      name: nameWithoutExtension,
      type: AudioType.custom,
      path: path,
      duration: Duration(seconds: durationSeconds.toInt()),
      modifiedTime: modifiedTime,
    ));
  }

  customItems.sort((a, b) {
    if (a.modifiedTime == null && b.modifiedTime == null) return 0;
    if (a.modifiedTime == null) return 1;
    if (b.modifiedTime == null) return -1;
    return b.modifiedTime!.compareTo(a.modifiedTime!);
  });

  return customItems;
});

final audioPlayerProvider = Provider<AudioPlayer>((ref) {
  final player = AudioPlayer();
  ref.onDispose(() {
    player.dispose();
  });
  return player;
});

class CurrentPlayingAudioNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  
  void setPlaying(String? id) => state = id;
  void clear() => state = null;
}

final currentPlayingAudioProvider = NotifierProvider<CurrentPlayingAudioNotifier, String?>(
  CurrentPlayingAudioNotifier.new,
);

final audioPlayerStateProvider = StreamProvider<PlayerState>((ref) {
  final player = ref.watch(audioPlayerProvider);
  return player.onPlayerStateChanged;
});

final audioPositionProvider = StreamProvider<Duration>((ref) {
  final player = ref.watch(audioPlayerProvider);
  return player.onPositionChanged;
});

final audioDurationProvider = StreamProvider<Duration>((ref) {
  final player = ref.watch(audioPlayerProvider);
  return player.onDurationChanged;
});

class AudioPlaybackController {
  final Ref ref;
  
  AudioPlaybackController(this.ref);
  
  Future<void> play(AudioItem item) async {
    final player = ref.read(audioPlayerProvider);
    final currentPlaying = ref.read(currentPlayingAudioProvider);

    // 如果正在播放同一个音频，则停止
    if (currentPlaying == item.id) {
      await stop();
      return;
    }
    
    // 停止当前播放
    await player.stop();
    
    try {
      if (item.type == AudioType.custom && item.path != null) {
        await player.play(DeviceFileSource(item.path!));
        ref.read(currentPlayingAudioProvider.notifier).setPlaying(item.id);
      }
    } catch (e) {
      debugPrint('AudioPlaybackController: play error: $e');
    }
  }
  
  Future<void> stop() async {
    await ref.read(audioPlayerProvider).stop();
    ref.read(currentPlayingAudioProvider.notifier).clear();
  }
  
  Future<void> pause() async {
    final player = ref.read(audioPlayerProvider);
    await player.pause();
  }
  
  Future<void> resume() async {
    final player = ref.read(audioPlayerProvider);
    await player.resume();
  }
  
  Future<void> seek(Duration position) async {
    final player = ref.read(audioPlayerProvider);
    await player.seek(position);
  }
}

final audioPlaybackControllerProvider = Provider<AudioPlaybackController>((ref) {
  return AudioPlaybackController(ref);
});
