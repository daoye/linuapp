/// 与后台 handler、主应用统一的 Android 通知 channel ID 规则
/// 添加/删除音频时在此创建/删除 channel，handler 仅按 sound name 使用对应 channel
String notificationChannelIdForSound(String soundName) {
  if (soundName.isEmpty) return 'default';
  final safe = soundName
      .replaceAll(RegExp(r'[^\w\-.]'), '_')
      .replaceFirst(RegExp(r'^\.'), '_');
  final trimmed = safe.length > 30 ? safe.substring(0, 30) : safe;
  return 'default_$trimmed';
}
