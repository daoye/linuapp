import 'dart:convert';
import 'package:flutter/foundation.dart';

/// group_id 最大长度，超长视为非法
const int kMaxGroupIdLength = 32;

/// 校验 group_id 长度，超长返回 false
bool validateGroupId(String groupId) {
  if (groupId.length > kMaxGroupIdLength) {
    debugPrint('Group ID too long (${groupId.length} chars) - discarding message');
    return false;
  }
  return true;
}

/// 消息优先级
enum MessagePriority {
  normal,
  silent,
  ringing, // 持续响铃（如来电）
  critical, // 紧急（突破勿扰模式）
}

/// 媒体类型
enum MediaType {
  image,
  video,
}

/// Webhook HTTP 方法
enum WebhookMethod {
  get,  // 0 = GET (default)
  post, // 1 = POST
}

/// Webhook 配置（URL + 方法）
class Webhook {
  final String url;
  final WebhookMethod method;

  const Webhook({
    required this.url,
    this.method = WebhookMethod.get,
  });

  /// 从 Map 解析
  factory Webhook.fromMap(Map<String, dynamic> map) {
    final url = (map['url'] ?? map['callback'])?.toString() ?? '';
    return Webhook(url: url, method: _parseMethod(map['method']));
  }

  /// 序列化为 Map
  Map<String, dynamic> toMap() => {
        'url': url,
        'method': method == WebhookMethod.post ? 'POST' : 'GET',
      };

  /// 从 JSON 字符串解析
  static Webhook? fromJson(String? str) {
    if (str == null || str.isEmpty) return null;
    return Webhook.fromMap(jsonDecode(str) as Map<String, dynamic>);
  }

  /// 序列化为 JSON 字符串
  String toJson() => jsonEncode(toMap());

  /// 从数组解析: [url, method]
  /// method: 0 = GET, 1 = POST
  static Webhook? fromArray(List data) {
    if (data.isEmpty) return null;
    final url = data[0]?.toString() ?? '';
    if (url.isEmpty) return null;
    return Webhook(url: url, method: _parseMethod(data.length > 1 ? data[1] : 0));
  }

  /// 解析推送消息中的 webhook 数据
  /// 支持多种格式：
  /// - 字符串: "http://..." (默认 GET 方法)
  /// - 数组: [url, method]
  /// - Map: {url: "...", method: "..."}
  static Webhook? parse(dynamic data) {
    if (data == null) return null;
    if (data is String) {
      // 纯字符串格式，默认使用 GET 方法
      if (data.isEmpty) return null;
      return Webhook(url: data, method: WebhookMethod.get);
    }
    if (data is List) return fromArray(data);
    if (data is Map) return Webhook.fromMap(Map<String, dynamic>.from(data));
    return null;
  }

  static WebhookMethod _parseMethod(dynamic value) {
    if (value == 1 || value == '1' || value == 'POST' || value == 'post') {
      return WebhookMethod.post;
    }
    return WebhookMethod.get;
  }
}


// ============================================================
// 子对象定义
// ============================================================

/// 媒体内容
class MediaContent {
  final MediaType type;
  final String url;
  final String? thumbnailUrl;

  const MediaContent({
    required this.type,
    required this.url,
    this.thumbnailUrl,
  });

  /// 从 Map 解析（支持 Map&lt;Object?, Object?&gt; 和 Map&lt;String, dynamic&gt;）
  static MediaContent? fromMap(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final type = _parseMediaType(data['type']);
      final url = data['url']?.toString() ?? '';
      if (url.isEmpty) return null;

      return MediaContent(
        type: type,
        url: url,
        thumbnailUrl: data['thumbnail_url']?.toString(),
      );
    }

    return null;
  }

  /// 从数组解析: [type(0/1), url, thumbnail_url?]
  static MediaContent? fromArray(dynamic data) {
    if (data == null) return null;

    if (data is List && data.length >= 2) {
      final url = data[1]?.toString() ?? '';
      if (url.isEmpty) return null;

      return MediaContent(
        type: _parseMediaTypeFromInt(data[0]),
        url: url,
        thumbnailUrl: data.length > 2 ? data[2]?.toString() : null,
      );
    }

    return null;
  }

  /// 统一解析入口（自动识别格式）
  static MediaContent? parse(dynamic data) {
    if (data == null) return null;
    if (data is List) return fromArray(data);
    if (data is Map) return fromMap(data);
    return null;
  }

  static MediaType _parseMediaType(dynamic value) {
    if (value == null) return MediaType.image;
    final str = value.toString().toLowerCase();
    return str == 'video' ? MediaType.video : MediaType.image;
  }

  static MediaType _parseMediaTypeFromInt(dynamic value) {
    if (value == 1 || value == '1') return MediaType.video;
    return MediaType.image;
  }

  /// 获取用于通知显示的图片 URL（视频使用缩略图）
  String? get displayImageUrl {
    if (type == MediaType.video) {
      return thumbnailUrl?.isNotEmpty == true ? thumbnailUrl : null;
    }
    return url.isNotEmpty ? url : null;
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
        'type': type == MediaType.video ? 'video' : 'image',
        'url': url,
        if (thumbnailUrl != null) 'thumbnail_url': thumbnailUrl,
      };
}

/// 消息动作
class MessageAction {
  final String label;
  final Webhook callback;
  final dynamic payload;
  final List<MessageAction> children;

  const MessageAction({
    required this.label,
    required this.callback,
    this.payload,
    this.children = const [],
  });

  /// 从 Map 解析
  static MessageAction? fromMap(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final label = data['label']?.toString() ?? '';
      final callbackUrl = data['callback']?.toString() ?? '';
      if (label.isEmpty || callbackUrl.isEmpty) return null;

      // 解析 method（默认 GET）
      final methodStr = data['method']?.toString().toLowerCase() ?? '';
      final method = methodStr == 'post' ? WebhookMethod.post : WebhookMethod.get;

      // 解析 children（递归）
      final rawChildren = data['children'];
      final List<MessageAction> children = rawChildren is List
          ? rawChildren
              .map((c) => parse(c))
              .where((action) => action != null)
              .cast<MessageAction>()
              .toList()
          : [];

      return MessageAction(
        label: label,
        callback: Webhook(url: callbackUrl, method: method),
        payload: data['payload'],
        children: children,
      );
    }

    return null;
  }

  /// 从数组解析: [label, callback, payload?, children?]
  /// callback 可以是字符串或数组 [url, method]
  /// method: 0 = GET (default), 1 = POST
  static MessageAction? fromArray(dynamic data) {
    if (data == null) return null;

    if (data is List && data.length >= 2) {
      final label = data[0]?.toString() ?? '';
      
      // 解析 callback（可能是字符串或数组）
      final callbackData = data[1];
      final Webhook? callback = Webhook.parse(callbackData);
      if (label.isEmpty || callback == null) return null;

      // 解析 payload（第 3 个元素，可选）
      final payload = data.length > 2 ? data[2] : null;

      // 解析 children（第 4 个元素，可选）
      final rawChildren = data.length > 3 ? data[3] : null;
      final List<MessageAction> children = rawChildren is List
          ? rawChildren
              .map((c) => parse(c))
              .where((action) => action != null)
              .cast<MessageAction>()
              .toList()
          : [];

      return MessageAction(
        label: label,
        callback: callback,
        payload: payload,
        children: children,
      );
    }

    return null;
  }

  /// 统一解析入口（自动识别格式）
  static MessageAction? parse(dynamic data) {
    if (data == null) return null;
    if (data is List) return fromArray(data);
    if (data is Map) return fromMap(data);
    return null;
  }

  /// 解析动作列表
  static List<MessageAction> parseList(dynamic data) {
    if (data == null) return [];
    if (data is! List) return [];

    return data
        .map((item) => parse(item))
        .where((action) => action != null)
        .cast<MessageAction>()
        .toList();
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
        'label': label,
        'callback': callback.url,
        'method': callback.method == WebhookMethod.post ? 'POST' : 'GET',
        if (payload != null) 'payload': payload,
        if (children.isNotEmpty) 'children': children.map((c) => c.toJson()).toList(),
      };
}

/// 详情页配置
class DetailConfig {
  final String url;

  const DetailConfig({
    required this.url,
  });

  /// 从 Map 解析
  static DetailConfig? fromMap(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      final url = data['url']?.toString() ?? '';
      if (url.isEmpty) return null;

      return DetailConfig(
        url: url,
      );
    }

    return null;
  }

  /// 从数组解析: [url]
  static DetailConfig? fromArray(dynamic data) {
    if (data == null) return null;

    if (data is List && data.isNotEmpty) {
      final url = data[0]?.toString() ?? '';
      if (url.isEmpty) return null;

      return DetailConfig(
        url: url,
      );
    }

    return null;
  }

  /// 统一解析入口（自动识别格式）
  static DetailConfig? parse(dynamic data) {
    if (data == null) return null;
    if (data is List) return fromArray(data);
    if (data is Map) return fromMap(data);
    return null;
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
        'url': url,
      };
}

/// 群组配置
class GroupConfig {
  final String? name;
  final Webhook? replyWebhook;
  final String? iconUrl;
  final List<MessageAction> actions;
  
  final bool _hasReplyWebhook;
  final bool _hasName;
  final bool _hasIconUrl;
  final bool _hasActions;

  const GroupConfig({
    this.name,
    this.replyWebhook,
    this.iconUrl,
    this.actions = const [],
    bool hasReplyWebhook = false,
    bool hasName = false,
    bool hasIconUrl = false,
    bool hasActions = false,
  }) : _hasReplyWebhook = hasReplyWebhook,
       _hasName = hasName,
       _hasIconUrl = hasIconUrl,
       _hasActions = hasActions;
  
  bool get hasReplyWebhook => _hasReplyWebhook;
  bool get hasName => _hasName;
  bool get hasIconUrl => _hasIconUrl;
  bool get hasActions => _hasActions;

  /// 从 Map 解析
  static GroupConfig? fromMap(dynamic data) {
    if (data == null) return null;

    if (data is Map) {
      return GroupConfig(
        name: data['name']?.toString(),
        replyWebhook: Webhook.parse(data['reply_callback']),
        iconUrl: data['icon_url']?.toString(),
        actions: MessageAction.parseList(data['actions']),
        hasName: data.containsKey('name'),
        hasReplyWebhook: data.containsKey('reply_callback'),
        hasIconUrl: data.containsKey('icon_url'),
        hasActions: data.containsKey('actions'),
      );
    }

    return null;
  }

  /// 从数组解析: [name, reply_callback, icon_url, actions]
  /// reply_callback 可以是字符串或数组 [url, method]
  static GroupConfig? fromArray(dynamic data) {
    if (data == null) return null;

    if (data is List) {
      return GroupConfig(
        name: data.isNotEmpty ? data[0]?.toString() : null,
        replyWebhook: data.length > 1 ? Webhook.parse(data[1]) : null,
        iconUrl: data.length > 2 ? data[2]?.toString() : null,
        actions: data.length > 3 ? MessageAction.parseList(data[3]) : [],
        hasName: data.isNotEmpty,
        hasReplyWebhook: data.length > 1 && data[1] != null,
        hasIconUrl: data.length > 2,
        hasActions: data.length > 3,
      );
    }

    return null;
  }

  /// 统一解析入口（自动识别格式）
  static GroupConfig? parse(dynamic data) {
    if (data == null) return null;
    if (data is List) return fromArray(data);
    if (data is Map) return fromMap(data);
    return null;
  }

  /// 兼容旧代码：从 JSON Map 解析
  factory GroupConfig.fromJson(Map<String, dynamic> json) {
    return GroupConfig(
      name: json['name']?.toString(),
      replyWebhook: Webhook.parse(json['reply_callback']),
      iconUrl: json['icon_url']?.toString(),
      actions: MessageAction.parseList(json['actions']),
      hasName: json.containsKey('name'),
      hasReplyWebhook: json.containsKey('reply_callback'),
      hasIconUrl: json.containsKey('icon_url'),
      hasActions: json.containsKey('actions'),
    );
  }

  /// 序列化 actions 为 JSON 字符串（兼容旧代码）
  String? get actionsJson {
    if (actions.isEmpty) return null;
    return jsonEncode(actions.map((a) => a.toJson()).toList());
  }

  /// 序列化为 JSON
  Map<String, dynamic> toJson() => {
        if (name != null) 'name': name,
        if (replyWebhook != null) 'reply_callback': replyWebhook!.toJson(),
        if (iconUrl != null) 'icon_url': iconUrl,
        if (actions.isNotEmpty) 'actions': actions.map((a) => a.toJson()).toList(),
      };
}

// ============================================================
// 主消息类
// ============================================================

/// 解析后的消息数据（统一数据结构）
class ParsedMessage {
  String title = '';
  String text = '';
  String sound = '';
  String groupId = '';
  MessagePriority priority = MessagePriority.normal;

  MediaContent? media;
  List<MessageAction> actions = [];
  DetailConfig? detail;
  GroupConfig? groupConfig;

  ParsedMessage();

  // ============================================================
  // 兼容旧代码的 getter/setter
  // ============================================================

  String get mediaType => media?.type == MediaType.video ? 'video' : (media != null ? 'image' : '');
  set mediaType(String value) {
    if (value.isEmpty) {
      media = null;
    } else if (media != null) {
      media = MediaContent(
        type: value == 'video' ? MediaType.video : MediaType.image,
        url: media!.url,
        thumbnailUrl: media!.thumbnailUrl,
      );
    }
  }

  String get mediaUrl => media?.url ?? '';
  set mediaUrl(String value) {
    if (value.isEmpty && media == null) return;
    media = MediaContent(
      type: media?.type ?? MediaType.image,
      url: value,
      thumbnailUrl: media?.thumbnailUrl,
    );
  }

  String get thumbnailUrl => media?.thumbnailUrl ?? '';
  set thumbnailUrl(String value) {
    if (media == null && value.isEmpty) return;
    media = MediaContent(
      type: media?.type ?? MediaType.image,
      url: media?.url ?? '',
      thumbnailUrl: value.isEmpty ? null : value,
    );
  }

  String get actionsJson {
    if (actions.isEmpty) return '';
    return jsonEncode(actions.map((a) => a.toJson()).toList());
  }

  set actionsJson(String value) {
    if (value.isEmpty) {
      actions = [];
      return;
    }
    try {
      final list = jsonDecode(value) as List<dynamic>;
      actions = MessageAction.parseList(list);
    } catch (_) {
      actions = [];
    }
  }

  String get detailUrl => detail?.url ?? '';
  set detailUrl(String value) {
    if (value.isEmpty) {
      detail = null;
    } else {
      detail = DetailConfig(
        url: value,
      );
    }
  }


  // ============================================================
  // 解析方法
  // ============================================================

  /// 从解密后的 JSON 解析
  factory ParsedMessage.fromJson(Map<String, dynamic> json) {
    final msg = ParsedMessage()
      ..title = json['title']?.toString() ?? ''
      ..text = json['text']?.toString() ?? ''
      ..sound = json['sound']?.toString() ?? ''
      ..groupId = json['group_id']?.toString() ?? ''
      ..priority = _parsePriority(json['priority']);

    // 使用统一解析方法
    msg.media = MediaContent.parse(json['media']);
    msg.actions = MessageAction.parseList(json['actions']);
    msg.detail = DetailConfig.parse(json['detail']);
    msg.groupConfig = GroupConfig.parse(json['group_config']);

    return msg;
  }

  /// 从 x 数组格式解析: [version, group_id, media, actions, detail, group_config]
  static ParsedMessage? fromXArray(String xPayload) {
    try {
      final arr = jsonDecode(xPayload) as List<dynamic>;
      if (arr.isEmpty || arr[0] != 1) return null;

      final msg = ParsedMessage()
        ..groupId = arr.length > 1 ? (arr[1]?.toString() ?? '') : '';

      // 使用统一解析方法（数组格式）
      if (arr.length > 2) msg.media = MediaContent.fromArray(arr[2]);
      if (arr.length > 3) msg.actions = MessageAction.parseList(arr[3]);
      if (arr.length > 4) msg.detail = DetailConfig.fromArray(arr[4]);
      if (arr.length > 5) msg.groupConfig = GroupConfig.fromArray(arr[5]);

      return msg;
    } catch (e) {
      return null;
    }
  }

  /// 获取用于通知显示的图片 URL（视频使用缩略图）
  String? get imageUrl => media?.displayImageUrl;

  /// 从外部数据填充 title/text/sound/priority（仅当当前值为空/默认时）
  /// 用于明文消息（x 格式），因为 x 数组不包含这些字段
  void fillFromMessageData(Map<String, dynamic> data) {
    if (title.isEmpty) {
      title = data['title']?.toString() ?? '';
    }
    if (text.isEmpty) {
      text = data['body']?.toString() ?? data['text']?.toString() ?? '';
    }
    if (sound.isEmpty) {
      sound = data['sound']?.toString() ?? '';
    }
    if (priority == MessagePriority.normal) {
      priority = _parsePriorityFromData(data);
    }
  }

  /// 加密消息解析后，用 FCM data 仅填充 sound、priority（不覆盖 title/text）
  void fillEncryptedMetadataFromData(Map<String, dynamic> data) {
    if (sound.isEmpty) {
      sound = data['sound']?.toString() ?? '';
    }
    if (priority == MessagePriority.normal) {
      priority = _parsePriorityFromData(data);
    }
  }

  // ============================================================
  // 优先级解析
  // ============================================================

  static MessagePriority _parsePriority(dynamic value) {
    if (value == null) return MessagePriority.normal;

    // 数值格式
    if (value is int) return _parsePriorityFromInt(value);

    // 字符串格式
    final str = value.toString().toLowerCase();
    switch (str) {
      case 'ringing':
        return MessagePriority.ringing;
      case 'critical':
        return MessagePriority.critical;
      case 'silent':
        return MessagePriority.silent;
      default:
        // 尝试解析为数值
        final intValue = int.tryParse(str);
        if (intValue != null) return _parsePriorityFromInt(intValue);
        return MessagePriority.normal;
    }
  }

  static MessagePriority _parsePriorityFromInt(int value) {
    switch (value) {
      case 1:
        return MessagePriority.silent;
      case 2:
        return MessagePriority.ringing;
      case 3:
        return MessagePriority.critical;
      default:
        return MessagePriority.normal;
    }
  }

  static MessagePriority _parsePriorityFromData(Map<String, dynamic> data) {
    // 优先从 'p' 字段读取
    if (data.containsKey('p')) {
      final pValue = data['p'];
      if (pValue is int) return _parsePriorityFromInt(pValue);
      if (pValue is String) {
        final pInt = int.tryParse(pValue);
        if (pInt != null) return _parsePriorityFromInt(pInt);
    }
    }
    // 从 'priority' 字符串字段解析
    return _parsePriority(data['priority']);
  }

  /// 是否需要持续响铃（只有 ringing 优先级需要持续响铃）
  bool get shouldRing => priority == MessagePriority.ringing;

  /// 是否需要 30s 来电式响铃（ringing 或 critical，由 Flutter 解密后调 Android 播放）
  bool get needRingingAlert =>
      priority == MessagePriority.ringing || priority == MessagePriority.critical;

  /// 解析优先级字符串（兼容旧代码）
  static MessagePriority parsePriority(String value) => _parsePriority(value);

  /// 从数值解析优先级（0=normal, 1=silent, 2=ringing, 3=critical）
  static MessagePriority parsePriorityFromInt(int value) => _parsePriorityFromInt(value);

  /// 从 data 映射解析优先级（优先读 'p'，其次 'priority'）
  static MessagePriority parsePriorityFromData(Map<String, dynamic> data) => _parsePriorityFromData(data);
}
