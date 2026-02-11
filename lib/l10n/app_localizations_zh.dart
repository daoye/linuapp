// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '狸奴';

  @override
  String get conversationListTitle => '会话';

  @override
  String get settings => '设置';

  @override
  String get upgrade => '升级';

  @override
  String get upgradeToPremium => '升级到高级版';

  @override
  String get upgradeToViewAll => '升级查看全部';

  @override
  String get premium => '高级版';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get deviceToken => '设备令牌';

  @override
  String get deviceTokenDescription => '使用此令牌配置您的推送服务器';

  @override
  String get copy => '复制';

  @override
  String get copied => '已复制';

  @override
  String get appVersion => '应用版本';

  @override
  String get termsOfService => '服务条款';

  @override
  String get privacyPolicy => '隐私政策';

  @override
  String get systemLanguage => '系统语言';

  @override
  String get english => 'English';

  @override
  String get simplifiedChinese => '简体中文';

  @override
  String get systemTheme => '系统';

  @override
  String get lightTheme => '浅色';

  @override
  String get darkTheme => '深色';

  @override
  String get getStarted => '开始使用';

  @override
  String get monthly => '每月订阅';

  @override
  String get yearly => '每年订阅';

  @override
  String get lifetime => '永久购买';

  @override
  String get unlimitedMessages => '解锁无限消息';

  @override
  String get supportDevelopment => '支持开发';

  @override
  String get bestValue => '最超值';

  @override
  String get currentPlan => '当前方案';

  @override
  String get retry => '重试';

  @override
  String get error => '错误';

  @override
  String get loading => '加载中';

  @override
  String get waitingForPushPermission => '等待推送通知权限...';

  @override
  String get noMessages => '暂无消息';

  @override
  String get noMessagesDescription => '您的消息将显示在这里';

  @override
  String get quickStartTitle => '快速开始';

  @override
  String get quickStartStep1 => '在设置中复制您的设备令牌';

  @override
  String get quickStartStep2 => '使用令牌调用推送 API';

  @override
  String get quickStartStep3 => '消息将立即显示在这里';

  @override
  String get testPushButton => '发送测试消息';

  @override
  String get testPushTitle => '欢迎使用狸奴';

  @override
  String get testPushBody => '您的第一条通知已送达！🎉';

  @override
  String get testPushSent => '测试消息已发送！';

  @override
  String get testPushFailed => '发送失败';

  @override
  String get testPushNoToken => '未找到设备令牌';

  @override
  String get sending => '发送中...';

  @override
  String get pin => '置顶';

  @override
  String get unpin => '取消置顶';

  @override
  String get send => '发送';

  @override
  String get reply => '回复';

  @override
  String get messageTitle => '消息';

  @override
  String get noMessageId => '缺少消息 ID';

  @override
  String get conversationOptions => '操作';

  @override
  String get messageOptions => '消息选项';

  @override
  String get unpinInboxHint => '取消置顶后将按时间排序。';

  @override
  String get pinInboxHint => '置顶后将固定在收件箱顶部。';

  @override
  String get unpinGroupHint => '取消置顶后将按时间排序。';

  @override
  String get pinGroupHint => '置顶后将固定在该会话顶部。';

  @override
  String get groupConversationFallback => '会话';

  @override
  String get defaultGroupName => '群组';

  @override
  String get noMessagesInConversation => '暂无消息';

  @override
  String get noMessagesInConversationDescription => '此群组中的消息将显示在这里';

  @override
  String get emptyField => '无';

  @override
  String get delete => '删除';

  @override
  String get deleteComingSoon => '删除功能将在后续版本提供。';

  @override
  String get deleteConfirmation => '确定要删除吗？此操作无法撤销。';

  @override
  String get cancel => '取消';

  @override
  String get legal => '法律信息';

  @override
  String get about => '关于';

  @override
  String get yesterday => '昨天';

  @override
  String get unlockAllFeatures => '解锁全部会话与加密功能';

  @override
  String hiddenGroupsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '还有$count个群组',
      one: '还有1个群组',
    );
    return '$_temp0 • 升级查看';
  }

  @override
  String get e2eEncryption => '端到端消息加密';

  @override
  String get e2eEncryptionEmptyDescription => '还没有';

  @override
  String get setupKey => '设置密钥';

  @override
  String get e2ePremiumRequired => '需要高级版才能使用加密功能';

  @override
  String get e2eFaq => '常见问题';

  @override
  String get e2eFaqTitle => '关于端到端加密';

  @override
  String get generateKey => '生成密钥';

  @override
  String get generateKeyDescription => '创建一个新的加密密钥';

  @override
  String get importKey => '导入密钥';

  @override
  String get importKeyDescription => '粘贴您的 32 字节 AES 密钥（Base64）';

  @override
  String get exportKey => '导出密钥';

  @override
  String get deleteKey => '删除密钥';

  @override
  String get deleteKeyDescription => '删除后将无法解密已加密的消息';

  @override
  String get deleteKeyConfirm => '确定要删除加密密钥吗？删除后将无法解密已加密的消息。';

  @override
  String get keyGenerated => '密钥生成成功';

  @override
  String get keyImported => '密钥导入成功';

  @override
  String get keyDeleted => '密钥已删除';

  @override
  String get invalidKeyFormat => '密钥格式无效';

  @override
  String get selectAll => '全选';

  @override
  String get deselectAll => '取消全选';

  @override
  String get batchDelete => '批量删除';

  @override
  String get deleteSelected => '删除所选';

  @override
  String itemsSelected(int count) {
    return '已选择 $count 项';
  }

  @override
  String get share => '分享';

  @override
  String get openInBrowser => '在浏览器中打开';

  @override
  String get viewDetails => '查看详情';

  @override
  String get welcomeToPremium => '欢迎使用高级版！';

  @override
  String continueWith(String price) {
    return '以 $price 继续';
  }

  @override
  String get selectPlan => '选择方案';

  @override
  String get alreadyLifetime => '已是永久会员';

  @override
  String get restorePurchases => '恢复购买';

  @override
  String get terms => '条款';

  @override
  String get checkingPurchases => '正在检查之前的购买...';

  @override
  String get unlockFullPower => '解锁全部功能';

  @override
  String get unlockDescription => '解锁全部会话与\n端到端加密功能';

  @override
  String get unlimitedConversations => '无限会话';

  @override
  String get viewAllGroups => '查看所有消息群组';

  @override
  String get secureMessages => '保护您的敏感消息';

  @override
  String get helpKeepAlive => '帮助维持应用运营';

  @override
  String savePercent(int percent) {
    return '相比月付节省 $percent%';
  }

  @override
  String get oneTime => '一次性';

  @override
  String get lifetimePremium => '永久高级版';

  @override
  String get permanentAccess => '您已永久拥有所有功能';

  @override
  String get actions => '操作';

  @override
  String get multiSelect => '多选';

  @override
  String get authRequired => '需要身份认证';

  @override
  String get authReason => '请进行身份认证以访问您的加密密钥';

  @override
  String get authFailed => '身份认证失败，请重试';

  @override
  String get authNotAvailable => '此设备不支持身份认证';

  @override
  String get authCancelled => '身份认证已取消';

  @override
  String get authNoCredentials => '设备未设置锁屏密码，请在系统设置中设置密码或PIN码';

  @override
  String get viewKey => '查看密钥';

  @override
  String get encryptedMessages => '待解密消息';

  @override
  String get encryptedMessage => '加密消息';

  @override
  String get encryptedMessagesDescription => '管理解密失败的消息';

  @override
  String get noEncryptedMessages => '没有待解密的消息';

  @override
  String get allMessagesDecrypted => '所有消息已成功解密';

  @override
  String encryptedMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 条消息',
      one: '1 条消息',
    );
    return '$_temp0';
  }

  @override
  String encryptedMessagesWithCount(int count) {
    return '待解密消息 ($count)';
  }

  @override
  String get retryAll => '全部重试';

  @override
  String get deleteAll => '全部删除';

  @override
  String get retryAllMessages => '重试所有消息';

  @override
  String get retryAllMessagesConfirm => '确定要重试解密所有待解密消息吗？';

  @override
  String get confirm => '确定';

  @override
  String retryComplete(int success, int failed) {
    return '重试完成: 成功 $success, 失败 $failed';
  }

  @override
  String get decryptionSuccess => '解密成功';

  @override
  String get decryptionFailed => '解密失败，请检查密钥设置';

  @override
  String get encryptedMessageNotificationBody => '收到一条加密消息，暂时无法解密';

  @override
  String get deleteMessage => '删除消息';

  @override
  String get deleteMessageConfirm => '确定要删除这条待解密消息吗？删除后无法恢复。';

  @override
  String get messageDeleted => '消息已删除';

  @override
  String get deleteAllMessages => '删除所有消息';

  @override
  String get deleteAllMessagesConfirm => '确定要删除所有待解密消息吗？删除后无法恢复。';

  @override
  String get allMessagesDeleted => '所有消息已删除';

  @override
  String get receivedAt => '接收时间';

  @override
  String get retryCount => '重试次数';

  @override
  String get lastRetry => '最后重试';

  @override
  String get setupEncryption => '设置加密';

  @override
  String get faqQuestion1 => '什么是端到端加密？';

  @override
  String get faqAnswer1 =>
      '端到端加密意味着您的消息在发送前就被加密，直到到达接收方才会被解密。在整个传输过程中，包括服务器在内的任何中间环节都无法查看消息的原始内容，只有发送方和接收方能够阅读消息。';

  @override
  String get faqQuestion2 => '如果我丢失了密钥会怎样？';

  @override
  String get faqAnswer2 => '如果您丢失了加密密钥，您将无法解密任何未来的加密消息。请确保安全地备份您的密钥。';

  @override
  String get faqQuestion3 => '我可以更改我的密钥吗？';

  @override
  String get faqAnswer3 =>
      '是的，您可以随时生成新密钥或导入不同的密钥。消息在接收时会被解密，因此更改密钥不会影响之前接收的消息。';

  @override
  String get faqQuestion4 => '我的密钥是否存储在服务器上？';

  @override
  String get faqAnswer4 => '不会。您的加密密钥仅使用安全存储存储在您的设备上。服务器永远无法访问您的密钥。';

  @override
  String get faqQuestion5 => '使用什么加密算法？';

  @override
  String get faqAnswer5 =>
      '我们使用 AES-256-GCM（高级加密标准，256 位密钥，Galois/Counter 模式）算法。这是一种经过广泛验证的对称加密算法，提供了强大的安全性和数据完整性保护。';

  @override
  String get importKeyHint => '输入 Base64 编码的密钥...';

  @override
  String get loadFailed => '加载失败';

  @override
  String get deleteFailed => '删除失败';

  @override
  String get preview => '预览';

  @override
  String get audioManagement => '通知声音';

  @override
  String get notificationSound => '通知声音';

  @override
  String get systemRingtone => '系统铃声';

  @override
  String get systemDefault => '系统默认';

  @override
  String get customAudio => '自定义';

  @override
  String get customRingtones => '自定义铃声';

  @override
  String get manageCustomAudio => '管理自定义通知声音和铃声';

  @override
  String get importAudio => '导入通知声音';

  @override
  String get setAudioName => '设置通知声音名称';

  @override
  String get audioNameHint => '用于在发送消息时指定此声音';

  @override
  String get useDefaultName => '使用默认名称';

  @override
  String get confirmImport => '确认导入';

  @override
  String get trimAudio => '裁剪音频';

  @override
  String get trimAudioHint => '拖动选区调整裁剪范围';

  @override
  String get zoomLevel => '缩放';

  @override
  String get selectionDuration => '选区';

  @override
  String get audioDuration => '时长';

  @override
  String get startTime => '开始时间';

  @override
  String get endTime => '结束时间';

  @override
  String get maxDuration => '最长 30 秒';

  @override
  String get exceedsMaxDuration => '时长不能超过 30 秒';

  @override
  String get noCustomAudio => '暂无自定义通知声音';

  @override
  String get tapAddToImport => '点击右上角 + 导入通知声音';

  @override
  String get customSoundApiTitle => 'API 参数示例';

  @override
  String get customSoundApiDescription => '在推送请求中使用 sound 参数指定自定义声音：';

  @override
  String get viewDocs => '查看文档';

  @override
  String get deleteAudio => '删除通知声音';

  @override
  String get deleteAudioConfirm => '确定要删除此通知声音吗？';

  @override
  String get audioDeleted => '通知声音已删除';

  @override
  String get renameAudio => '重命名通知声音';

  @override
  String get audioName => '通知声音名称';

  @override
  String get enterAudioName => '请输入通知声音名称';

  @override
  String get renameSuccess => '重命名成功';

  @override
  String get renameFailed => '重命名失败';

  @override
  String get audioImported => '通知声音已导入';

  @override
  String get trimFailed => '裁剪失败';

  @override
  String get getAudioInfoFailed => '不支持此音频格式';

  @override
  String get previewFailed => '预览失败';

  @override
  String get systemDefaultCannotPreview => '系统默认铃声无法预览';

  @override
  String get storagePermissionDenied => '存储权限被拒绝';

  @override
  String get filePathNotAvailable => '文件路径不可用';

  @override
  String get loadingAudio => '正在加载通知声音...';

  @override
  String get stop => '停止';

  @override
  String totalDuration(String duration) {
    return '总时长：$duration';
  }

  @override
  String trimmedDuration(String duration) {
    return '裁剪后时长：$duration';
  }

  @override
  String get webhookToken => '伪装设备令牌';

  @override
  String get webhookTokenFaq => '了解更多';

  @override
  String get webhookTokenFaqTitle => '关于伪装设备令牌';

  @override
  String get webhookUsingPseudoToken => '伪装设备令牌';

  @override
  String get webhookUsingRealToken => '真实设备令牌';

  @override
  String get resetWebhookToken => '重置';

  @override
  String get resetWebhookTokenDescription => '生成新的伪装设备令牌';

  @override
  String get resetWebhookTokenConfirm =>
      '重置后，webhook 服务器将收到新的令牌。如果服务器依赖此令牌识别设备，可能需要重新配置。确定要重置吗？';

  @override
  String get webhookTokenReset => '伪装令牌已重置';

  @override
  String get switchToRealToken => '关闭伪装';

  @override
  String get switchToRealTokenDescription => '将真实设备令牌发送给 webhook 服务器';

  @override
  String get switchToRealTokenConfirm =>
      '真实设备令牌是敏感信息，可能被用于追踪您的设备。除非您信任 webhook 服务器，否则建议使用伪装设备令牌。确定要关闭吗？';

  @override
  String get switchedToRealToken => '已关闭伪装';

  @override
  String get usePseudoToken => '伪装设备令牌';

  @override
  String get usePseudoTokenDescription => '使用随机生成的令牌代替真实设备令牌';

  @override
  String get switchToPseudoToken => '开启伪装';

  @override
  String get switchToPseudoTokenDescription => '使用随机生成的令牌保护隐私';

  @override
  String get switchedToPseudoToken => '已开启伪装';

  @override
  String get webhookFaqQuestion1 => '什么是伪装设备令牌？';

  @override
  String get webhookFaqAnswer1 =>
      '点击消息中的操作按钮或发送回复时，应用会向 webhook 服务器发送请求。为了让服务器识别请求来源，请求中会携带设备令牌。伪装设备令牌是一个随机生成的标识符，可代替真实令牌使用，既能满足服务器识别需求，又能保护您的隐私。';

  @override
  String get webhookFaqQuestion2 => '为什么需要伪装设备令牌？';

  @override
  String get webhookFaqAnswer2 =>
      '真实的设备令牌（APNs/FCM Token）是敏感信息，可能被用于追踪您的设备或发送未经授权的推送通知。使用伪装设备令牌可以在保持功能的同时保护您的隐私。';

  @override
  String get webhookFaqQuestion3 => '什么时候需要使用真实令牌？';

  @override
  String get webhookFaqAnswer3 =>
      '如果您的 webhook 服务器需要使用设备令牌来发送推送通知（例如回复消息后向您推送确认），则需要关闭伪装使用真实令牌。否则，建议始终开启伪装。';

  @override
  String get webhookFaqQuestion4 => '重置伪装令牌会有什么影响？';

  @override
  String get webhookFaqAnswer4 =>
      '重置后，webhook 服务器将收到一个全新的令牌。如果服务器使用令牌来关联用户数据，可能需要重新建立关联。这不会影响推送通知的接收。';

  @override
  String get initializationFailed => '初始化失败';

  @override
  String get unknownError => '未知错误';

  @override
  String get splashTagline => '轻量却不简陋的消息终端';

  @override
  String get splashSubtitle => '为处理消息而生';

  @override
  String get learnMore => '了解更多：linu.aprilzz.com';

  @override
  String get replaceExistingKey => '替换现有密钥？';

  @override
  String get replaceKeyConfirm => '您已有一个加密密钥。导入新密钥将替换现有密钥。确定要继续吗？';

  @override
  String get replace => '替换';

  @override
  String get defaultNotification => '默认通知';

  @override
  String get pushNotificationChannel => '推送消息通知';

  @override
  String get newMessage => '新消息';

  @override
  String get decryptedMessageChannel => '解密消息';

  @override
  String get decryptedMessageChannelDescription => '解密成功的加密消息';

  @override
  String welcomeTo(String appName) {
    return '欢迎使用 $appName';
  }

  @override
  String get onboardingSubtitle => '您的个人消息中心';

  @override
  String get onboardingFeatureTokenTitle => '设备令牌';

  @override
  String get onboardingFeatureTokenDescription => '在设置中找到您的设备令牌，用于接收推送通知。';

  @override
  String get onboardingFeatureServerTitle => '服务器配置';

  @override
  String get onboardingFeatureServerDescription => '部署您自己的 Linu 服务器或使用我们的托管服务。';

  @override
  String get onboardingFeatureApiTitle => 'API 集成';

  @override
  String get onboardingFeatureApiDescription => '通过简单的 REST API 从任何系统或服务发送消息。';

  @override
  String get aboutLinuName => '名字由来';

  @override
  String get aboutLinuNameTitle => '为什么叫「狸奴」？';

  @override
  String get aboutLinuNameContent =>
      '「狸奴」是中国古代对猫的爱称，最早见于宋代诗人陆游的诗作。\n\n正如古时的狸奴默默守护家宅、带来温暖，如今的狸奴也将忠实地为您传递每一条重要通知——静默相伴，值得信赖。';

  @override
  String get ringingDefaultTitle => '注意';

  @override
  String get ringingDefaultBody => '重要消息';

  @override
  String get docs => '使用文档';
}
