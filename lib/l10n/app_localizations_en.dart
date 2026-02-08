// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Linu';

  @override
  String get conversationListTitle => 'Conversations';

  @override
  String get settings => 'Settings';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get upgradeToViewAll => 'Upgrade to View All';

  @override
  String get premium => 'Premium';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get deviceToken => 'Device Token';

  @override
  String get deviceTokenDescription =>
      'Use this token to configure your push server';

  @override
  String get copy => 'Copy';

  @override
  String get copied => 'Copied';

  @override
  String get appVersion => 'App Version';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get systemLanguage => 'System Language';

  @override
  String get english => 'English';

  @override
  String get simplifiedChinese => 'Simplified Chinese';

  @override
  String get systemTheme => 'System';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get getStarted => 'Get Started';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get lifetime => 'Lifetime';

  @override
  String get unlimitedMessages => 'Unlock Unlimited Messages';

  @override
  String get supportDevelopment => 'Support Development';

  @override
  String get bestValue => 'Best Value';

  @override
  String get currentPlan => 'Current Plan';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading';

  @override
  String get waitingForPushPermission =>
      'Waiting for push notification permission...';

  @override
  String get noMessages => 'No messages yet';

  @override
  String get noMessagesDescription => 'Your messages will appear here';

  @override
  String get quickStartTitle => 'Quick Start';

  @override
  String get quickStartStep1 => 'Copy your device token from Settings';

  @override
  String get quickStartStep2 => 'Call the push API with your token';

  @override
  String get quickStartStep3 => 'Your message will appear here instantly';

  @override
  String get testPushButton => 'Send Test Message';

  @override
  String get testPushTitle => 'Welcome to Linu';

  @override
  String get testPushBody => 'Your first notification has arrived! 🎉';

  @override
  String get testPushSent => 'Test message sent!';

  @override
  String get testPushFailed => 'Failed to send';

  @override
  String get testPushNoToken => 'Device token not found';

  @override
  String get sending => 'Sending...';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get send => 'Send';

  @override
  String get reply => 'Reply';

  @override
  String get messageTitle => 'Message';

  @override
  String get noMessageId => 'No message ID';

  @override
  String get conversationOptions => 'Options';

  @override
  String get messageOptions => 'Message options';

  @override
  String get unpinInboxHint => 'Unpin to let it follow normal sorting.';

  @override
  String get pinInboxHint =>
      'Pin to keep it at the top of your conversationlist.';

  @override
  String get unpinGroupHint => 'Unpin to let it follow normal sorting.';

  @override
  String get pinGroupHint => 'Pin to keep it at the top of this conversation.';

  @override
  String get groupConversationFallback => 'Conversation';

  @override
  String get defaultGroupName => 'Group';

  @override
  String get noMessagesInConversation => 'No messages yet';

  @override
  String get noMessagesInConversationDescription =>
      'Messages in this group will appear here';

  @override
  String get emptyField => '(None)';

  @override
  String get delete => 'Delete';

  @override
  String get deleteComingSoon =>
      'Delete will be available in a future version.';

  @override
  String get deleteConfirmation =>
      'Are you sure you want to delete this item? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get legal => 'Legal';

  @override
  String get about => 'About';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get unlockAllFeatures => 'Unlock all conversations & encryption';

  @override
  String hiddenGroupsHint(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more groups',
      one: '1 more group',
    );
    return '$_temp0 • Upgrade';
  }

  @override
  String get e2eEncryption => 'End-to-End Encryption';

  @override
  String get e2eEncryptionEmptyDescription => 'The key has not been set. ';

  @override
  String get setupKey => 'Set up key';

  @override
  String get e2ePremiumRequired => 'Premium required to enable encryption';

  @override
  String get e2eFaq => 'Frequently Asked Questions';

  @override
  String get e2eFaqTitle => 'About End-to-End Encryption';

  @override
  String get generateKey => 'Generate Key';

  @override
  String get generateKeyDescription => 'Create a new encryption key';

  @override
  String get importKey => 'Import Key';

  @override
  String get importKeyDescription => 'Paste your 32-byte AES key (Base64)';

  @override
  String get exportKey => 'Export Key';

  @override
  String get deleteKey => 'Delete Key';

  @override
  String get deleteKeyDescription =>
      'Encrypted messages cannot be decrypted after deletion';

  @override
  String get deleteKeyConfirm =>
      'Are you sure you want to delete your encryption key? You will not be able to decrypt encrypted messages without it.';

  @override
  String get keyGenerated => 'Key generated successfully';

  @override
  String get keyImported => 'Key imported successfully';

  @override
  String get keyDeleted => 'Key deleted';

  @override
  String get invalidKeyFormat => 'Invalid key format';

  @override
  String get selectAll => 'Select All';

  @override
  String get deselectAll => 'Deselect All';

  @override
  String get batchDelete => 'Batch Delete';

  @override
  String get deleteSelected => 'Delete Selected';

  @override
  String itemsSelected(int count) {
    return '$count selected';
  }

  @override
  String get share => 'Share';

  @override
  String get openInBrowser => 'Open in Browser';

  @override
  String get viewDetails => 'View Details';

  @override
  String get welcomeToPremium => 'Welcome to Premium!';

  @override
  String continueWith(String price) {
    return 'Continue with $price';
  }

  @override
  String get selectPlan => 'Select a plan';

  @override
  String get alreadyLifetime => 'Already Lifetime';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get terms => 'Terms';

  @override
  String get checkingPurchases => 'Checking for previous purchases...';

  @override
  String get unlockFullPower => 'Unlock Full Power';

  @override
  String get unlockDescription =>
      'Unlock all conversations and\nend-to-end encryption';

  @override
  String get unlimitedConversations => 'Unlimited Conversations';

  @override
  String get viewAllGroups => 'View all your message groups';

  @override
  String get secureMessages => 'Secure your sensitive messages';

  @override
  String get helpKeepAlive => 'Help keep the app alive';

  @override
  String savePercent(int percent) {
    return 'Save $percent% compared to monthly';
  }

  @override
  String get oneTime => 'One-time';

  @override
  String get lifetimePremium => 'Lifetime Premium';

  @override
  String get permanentAccess => 'You have permanent access to all features';

  @override
  String get actions => 'Actions';

  @override
  String get multiSelect => 'Multi-select';

  @override
  String get authRequired => 'Authentication Required';

  @override
  String get authReason => 'Please authenticate to access your encryption key';

  @override
  String get authFailed => 'Authentication failed. Please try again.';

  @override
  String get authNotAvailable =>
      'Authentication is not available on this device';

  @override
  String get authCancelled => 'Authentication was cancelled';

  @override
  String get authNoCredentials =>
      'No screen lock is set on this device. Please set up a password or PIN in system settings';

  @override
  String get viewKey => 'View Key';

  @override
  String get encryptedMessages => 'Encrypted Messages';

  @override
  String get encryptedMessage => 'Encrypted Message';

  @override
  String get encryptedMessagesDescription =>
      'Manage messages that failed to decrypt';

  @override
  String get noEncryptedMessages => 'No encrypted messages';

  @override
  String get allMessagesDecrypted =>
      'All messages have been successfully decrypted';

  @override
  String encryptedMessagesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count messages',
      one: '1 message',
    );
    return '$_temp0';
  }

  @override
  String encryptedMessagesWithCount(int count) {
    return 'Encrypted Messages ($count)';
  }

  @override
  String get retryAll => 'Retry All';

  @override
  String get deleteAll => 'Delete All';

  @override
  String get retryAllMessages => 'Retry All Messages';

  @override
  String get retryAllMessagesConfirm =>
      'Are you sure you want to retry decrypting all encrypted messages?';

  @override
  String get confirm => 'Confirm';

  @override
  String retryComplete(int success, int failed) {
    return 'Retry complete: $success succeeded, $failed failed';
  }

  @override
  String get decryptionSuccess => 'Decryption successful';

  @override
  String get decryptionFailed =>
      'Decryption failed, please check your key settings';

  @override
  String get encryptedMessageNotificationBody =>
      'You have a new encrypted message that could not be decrypted';

  @override
  String get deleteMessage => 'Delete Message';

  @override
  String get deleteMessageConfirm =>
      'Are you sure you want to delete this encrypted message? This action cannot be undone.';

  @override
  String get messageDeleted => 'Message deleted';

  @override
  String get deleteAllMessages => 'Delete All Messages';

  @override
  String get deleteAllMessagesConfirm =>
      'Are you sure you want to delete all encrypted messages? This action cannot be undone.';

  @override
  String get allMessagesDeleted => 'All messages deleted';

  @override
  String get receivedAt => 'Received At';

  @override
  String get retryCount => 'Retry Count';

  @override
  String get lastRetry => 'Last Retry';

  @override
  String get setupEncryption => 'Set Up Encryption';

  @override
  String get faqQuestion1 => 'What is end-to-end encryption?';

  @override
  String get faqAnswer1 =>
      'End-to-end encryption means your messages are encrypted before sending and only decrypted when they reach the recipient. Throughout the entire transmission process, including servers and any intermediate nodes, no one can view the original message content. Only the sender and recipient can read the messages.';

  @override
  String get faqQuestion2 => 'What happens if I lose my key?';

  @override
  String get faqAnswer2 =>
      'If you lose your encryption key, you will not be able to decrypt any future encrypted messages. Make sure to back up your key securely.';

  @override
  String get faqQuestion3 => 'Can I change my key?';

  @override
  String get faqAnswer3 =>
      'Yes, you can generate a new key or import a different one at any time. Messages are decrypted when received, so changing your key will not affect previously received messages.';

  @override
  String get faqQuestion4 => 'Is my key stored on the server?';

  @override
  String get faqAnswer4 =>
      'No. Your encryption key is stored only on your device using secure storage. The server never has access to your key.';

  @override
  String get faqQuestion5 => 'What encryption algorithm is used?';

  @override
  String get faqAnswer5 =>
      'We use AES-256-GCM (Advanced Encryption Standard with 256-bit keys in Galois/Counter Mode). This is a widely validated symmetric encryption algorithm that provides strong security and data integrity protection.';

  @override
  String get importKeyHint => 'Enter Base64 encoded key...';

  @override
  String get loadFailed => 'Load failed';

  @override
  String get deleteFailed => 'Delete failed';

  @override
  String get preview => 'Preview';

  @override
  String get audioManagement => 'Notification Sound';

  @override
  String get notificationSound => 'Notification Sound';

  @override
  String get systemRingtone => 'System Ringtone';

  @override
  String get systemDefault => 'System Default';

  @override
  String get customAudio => 'Custom';

  @override
  String get customRingtones => 'Custom Ringtones';

  @override
  String get manageCustomAudio =>
      'Manage custom notification sounds and ringtones';

  @override
  String get importAudio => 'Import Notification Sound';

  @override
  String get setAudioName => 'Set Notification Sound Name';

  @override
  String get audioNameHint =>
      'Used to specify this sound when sending messages';

  @override
  String get useDefaultName => 'Use Default Name';

  @override
  String get confirmImport => 'Confirm Import';

  @override
  String get trimAudio => 'Trim Audio';

  @override
  String get trimAudioHint => 'Drag selection to adjust trim range';

  @override
  String get zoomLevel => 'Zoom';

  @override
  String get selectionDuration => 'Selection';

  @override
  String get audioDuration => 'Duration';

  @override
  String get startTime => 'Start Time';

  @override
  String get endTime => 'End Time';

  @override
  String get maxDuration => 'Max 30 seconds';

  @override
  String get exceedsMaxDuration => 'Duration cannot exceed 30 seconds';

  @override
  String get noCustomAudio => 'No custom notification sound';

  @override
  String get tapAddToImport => 'Tap + to import notification sound';

  @override
  String get customSoundApiTitle => 'API Parameter Example';

  @override
  String get customSoundApiDescription =>
      'Use the sound parameter in push request to specify custom sound:';

  @override
  String get viewDocs => 'Docs';

  @override
  String get deleteAudio => 'Delete Notification Sound';

  @override
  String get deleteAudioConfirm =>
      'Are you sure you want to delete this notification sound?';

  @override
  String get audioDeleted => 'Notification sound deleted';

  @override
  String get renameAudio => 'Rename Notification Sound';

  @override
  String get audioName => 'Notification Sound Name';

  @override
  String get enterAudioName => 'Enter notification sound name';

  @override
  String get renameSuccess => 'Renamed successfully';

  @override
  String get renameFailed => 'Rename failed';

  @override
  String get audioImported => 'Notification sound imported';

  @override
  String get trimFailed => 'Trim failed';

  @override
  String get getAudioInfoFailed => 'Unsupported audio format';

  @override
  String get previewFailed => 'Preview failed';

  @override
  String get systemDefaultCannotPreview =>
      'System default ringtone cannot be previewed';

  @override
  String get storagePermissionDenied => 'Storage permission denied';

  @override
  String get filePathNotAvailable => 'File path not available';

  @override
  String get loadingAudio => 'Loading notification sound...';

  @override
  String get stop => 'Stop';

  @override
  String totalDuration(String duration) {
    return 'Total duration: $duration';
  }

  @override
  String trimmedDuration(String duration) {
    return 'Trimmed duration: $duration';
  }

  @override
  String get webhookToken => 'Pseudo Device Token';

  @override
  String get webhookTokenFaq => 'Learn more';

  @override
  String get webhookTokenFaqTitle => 'About Pseudo Device Token';

  @override
  String get webhookUsingPseudoToken => 'Pseudo device token';

  @override
  String get webhookUsingRealToken => 'Real device token';

  @override
  String get resetWebhookToken => 'Reset';

  @override
  String get resetWebhookTokenDescription =>
      'Generate a new pseudo device token';

  @override
  String get resetWebhookTokenConfirm =>
      'After reset, the webhook server will receive a new token. If the server relies on this token to recognize your device, you may need to reconfigure it. Are you sure?';

  @override
  String get webhookTokenReset => 'Pseudo token has been reset';

  @override
  String get switchToRealToken => 'Disable Pseudo Token';

  @override
  String get switchToRealTokenDescription =>
      'Send real device token to webhook server';

  @override
  String get switchToRealTokenConfirm =>
      'The real device token is sensitive information that could be used to track your device. Unless you trust the webhook server, it\'s recommended to use a pseudo device token. Are you sure?';

  @override
  String get switchedToRealToken => 'Pseudo token disabled';

  @override
  String get usePseudoToken => 'Pseudo Device Token';

  @override
  String get usePseudoTokenDescription =>
      'Use a randomly generated token instead of real device token';

  @override
  String get switchToPseudoToken => 'Enable Pseudo Token';

  @override
  String get switchToPseudoTokenDescription =>
      'Use a randomly generated token for privacy';

  @override
  String get switchedToPseudoToken => 'Pseudo token enabled';

  @override
  String get webhookFaqQuestion1 => 'What is a Pseudo Device Token?';

  @override
  String get webhookFaqAnswer1 =>
      'When you tap action buttons or send replies, the app sends requests to webhook servers. To identify the request source, a device token is included. The pseudo device token is a randomly generated identifier that can replace your real token, allowing the server to identify your device while protecting your privacy.';

  @override
  String get webhookFaqQuestion2 => 'Why use a pseudo device token?';

  @override
  String get webhookFaqAnswer2 =>
      'The real device token (APNs/FCM Token) is sensitive information that could be used to track your device or send unauthorized push notifications. Using a pseudo device token protects your privacy while maintaining functionality.';

  @override
  String get webhookFaqQuestion3 => 'When should I use the real token?';

  @override
  String get webhookFaqAnswer3 =>
      'If your webhook server needs the device token to send push notifications (e.g., sending confirmation after you reply), you need to disable the pseudo token. Otherwise, it\'s recommended to always keep it enabled.';

  @override
  String get webhookFaqQuestion4 =>
      'What happens when I reset the pseudo token?';

  @override
  String get webhookFaqAnswer4 =>
      'After reset, the webhook server will receive a completely new token. If the server uses the token to associate user data, you may need to re-establish the association. This won\'t affect receiving push notifications.';

  @override
  String get initializationFailed => 'Initialization Failed';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get splashTagline => 'Lightweight yet powerful message terminal';

  @override
  String get splashSubtitle => 'Built for handling messages';

  @override
  String get learnMore => 'Learn more at linu.aprilzz.com';

  @override
  String get replaceExistingKey => 'Replace existing key?';

  @override
  String get replaceKeyConfirm =>
      'You already have an encryption key. Importing a new key will replace the existing one. Are you sure you want to continue?';

  @override
  String get replace => 'Replace';

  @override
  String get defaultNotification => 'Default Notification';

  @override
  String get pushNotificationChannel => 'Push message notifications';

  @override
  String get newMessage => 'New Message';

  @override
  String get decryptedMessageChannel => 'Decrypted Messages';

  @override
  String get decryptedMessageChannelDescription =>
      'Successfully decrypted encrypted messages';

  @override
  String welcomeTo(String appName) {
    return 'Welcome to $appName';
  }

  @override
  String get onboardingSubtitle => 'Your personal message hub';

  @override
  String get onboardingFeatureTokenTitle => 'Device Token';

  @override
  String get onboardingFeatureTokenDescription =>
      'Find your unique device token in Settings to receive push notifications.';

  @override
  String get onboardingFeatureServerTitle => 'Server Setup';

  @override
  String get onboardingFeatureServerDescription =>
      'Deploy your own Linu server or use our hosted service.';

  @override
  String get onboardingFeatureApiTitle => 'API Integration';

  @override
  String get onboardingFeatureApiDescription =>
      'Send messages via our simple REST API from any system or service.';

  @override
  String get aboutLinuName => 'About the Name';

  @override
  String get aboutLinuNameTitle => 'Why \"Linu\"?';

  @override
  String get aboutLinuNameContent =>
      '\"Linu\" (狸奴) is an ancient Chinese term of endearment for cats, first appearing in the poetry of Lu You, a Song Dynasty poet.\n\nJust as cats once quietly guarded homes and brought warmth, Linu now faithfully delivers your important notifications — always by your side, quiet yet reliable.';

  @override
  String get ringingDefaultTitle => 'Attention';

  @override
  String get ringingDefaultBody => 'Important message';
}
