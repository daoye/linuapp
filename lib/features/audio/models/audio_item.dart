enum AudioType {
  custom,
}

class AudioItem {
  final String id;
  final String name;
  final AudioType type;
  final String? path;
  final String? uri;
  final Duration? duration;
  final DateTime? modifiedTime; // 修改时间，用于排序

  AudioItem({
    required this.id,
    required this.name,
    required this.type,
    this.path,
    this.uri,
    this.duration,
    this.modifiedTime,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          type == other.type &&
          path == other.path &&
          uri == other.uri &&
          duration == other.duration &&
          modifiedTime == other.modifiedTime;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      path.hashCode ^
      uri.hashCode ^
      duration.hashCode ^
      modifiedTime.hashCode;
}
