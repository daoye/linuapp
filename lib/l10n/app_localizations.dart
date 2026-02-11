import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Linu'**
  String get appTitle;

  /// No description provided for @conversationListTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversationListTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @upgradeToViewAll.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to View All'**
  String get upgradeToViewAll;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @deviceToken.
  ///
  /// In en, this message translates to:
  /// **'Device Token'**
  String get deviceToken;

  /// No description provided for @deviceTokenDescription.
  ///
  /// In en, this message translates to:
  /// **'Use this token to configure your push server'**
  String get deviceTokenDescription;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'System Language'**
  String get systemLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @simplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get simplifiedChinese;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @unlimitedMessages.
  ///
  /// In en, this message translates to:
  /// **'Unlock Unlimited Messages'**
  String get unlimitedMessages;

  /// No description provided for @supportDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Support Development'**
  String get supportDevelopment;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @waitingForPushPermission.
  ///
  /// In en, this message translates to:
  /// **'Waiting for push notification permission...'**
  String get waitingForPushPermission;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessages;

  /// No description provided for @noMessagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Your messages will appear here'**
  String get noMessagesDescription;

  /// No description provided for @quickStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get quickStartTitle;

  /// No description provided for @quickStartStep1.
  ///
  /// In en, this message translates to:
  /// **'Copy your device token from Settings'**
  String get quickStartStep1;

  /// No description provided for @quickStartStep2.
  ///
  /// In en, this message translates to:
  /// **'Call the push API with your token'**
  String get quickStartStep2;

  /// No description provided for @quickStartStep3.
  ///
  /// In en, this message translates to:
  /// **'Your message will appear here instantly'**
  String get quickStartStep3;

  /// No description provided for @testPushButton.
  ///
  /// In en, this message translates to:
  /// **'Send Test Message'**
  String get testPushButton;

  /// No description provided for @testPushTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Linu'**
  String get testPushTitle;

  /// No description provided for @testPushBody.
  ///
  /// In en, this message translates to:
  /// **'Your first notification has arrived! 🎉'**
  String get testPushBody;

  /// No description provided for @testPushSent.
  ///
  /// In en, this message translates to:
  /// **'Test message sent!'**
  String get testPushSent;

  /// No description provided for @testPushFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to send'**
  String get testPushFailed;

  /// No description provided for @testPushNoToken.
  ///
  /// In en, this message translates to:
  /// **'Device token not found'**
  String get testPushNoToken;

  /// No description provided for @sending.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sending;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// No description provided for @unpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @messageTitle.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get messageTitle;

  /// No description provided for @noMessageId.
  ///
  /// In en, this message translates to:
  /// **'No message ID'**
  String get noMessageId;

  /// No description provided for @conversationOptions.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get conversationOptions;

  /// No description provided for @messageOptions.
  ///
  /// In en, this message translates to:
  /// **'Message options'**
  String get messageOptions;

  /// No description provided for @unpinInboxHint.
  ///
  /// In en, this message translates to:
  /// **'Unpin to let it follow normal sorting.'**
  String get unpinInboxHint;

  /// No description provided for @pinInboxHint.
  ///
  /// In en, this message translates to:
  /// **'Pin to keep it at the top of your conversationlist.'**
  String get pinInboxHint;

  /// No description provided for @unpinGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Unpin to let it follow normal sorting.'**
  String get unpinGroupHint;

  /// No description provided for @pinGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Pin to keep it at the top of this conversation.'**
  String get pinGroupHint;

  /// No description provided for @groupConversationFallback.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get groupConversationFallback;

  /// No description provided for @defaultGroupName.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get defaultGroupName;

  /// No description provided for @noMessagesInConversation.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get noMessagesInConversation;

  /// No description provided for @noMessagesInConversationDescription.
  ///
  /// In en, this message translates to:
  /// **'Messages in this group will appear here'**
  String get noMessagesInConversationDescription;

  /// No description provided for @emptyField.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get emptyField;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Delete will be available in a future version.'**
  String get deleteComingSoon;

  /// No description provided for @deleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item? This action cannot be undone.'**
  String get deleteConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @legal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get legal;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @unlockAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlock all conversations & encryption'**
  String get unlockAllFeatures;

  /// No description provided for @hiddenGroupsHint.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more group} other{{count} more groups}} • Upgrade'**
  String hiddenGroupsHint(int count);

  /// No description provided for @e2eEncryption.
  ///
  /// In en, this message translates to:
  /// **'End-to-End Encryption'**
  String get e2eEncryption;

  /// No description provided for @e2eEncryptionEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'The key has not been set. '**
  String get e2eEncryptionEmptyDescription;

  /// No description provided for @setupKey.
  ///
  /// In en, this message translates to:
  /// **'Set up key'**
  String get setupKey;

  /// No description provided for @e2ePremiumRequired.
  ///
  /// In en, this message translates to:
  /// **'Premium required to enable encryption'**
  String get e2ePremiumRequired;

  /// No description provided for @e2eFaq.
  ///
  /// In en, this message translates to:
  /// **'Frequently Asked Questions'**
  String get e2eFaq;

  /// No description provided for @e2eFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'About End-to-End Encryption'**
  String get e2eFaqTitle;

  /// No description provided for @generateKey.
  ///
  /// In en, this message translates to:
  /// **'Generate Key'**
  String get generateKey;

  /// No description provided for @generateKeyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a new encryption key'**
  String get generateKeyDescription;

  /// No description provided for @importKey.
  ///
  /// In en, this message translates to:
  /// **'Import Key'**
  String get importKey;

  /// No description provided for @importKeyDescription.
  ///
  /// In en, this message translates to:
  /// **'Paste your 32-byte AES key (Base64)'**
  String get importKeyDescription;

  /// No description provided for @exportKey.
  ///
  /// In en, this message translates to:
  /// **'Export Key'**
  String get exportKey;

  /// No description provided for @deleteKey.
  ///
  /// In en, this message translates to:
  /// **'Delete Key'**
  String get deleteKey;

  /// No description provided for @deleteKeyDescription.
  ///
  /// In en, this message translates to:
  /// **'Encrypted messages cannot be decrypted after deletion'**
  String get deleteKeyDescription;

  /// No description provided for @deleteKeyConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your encryption key? You will not be able to decrypt encrypted messages without it.'**
  String get deleteKeyConfirm;

  /// No description provided for @keyGenerated.
  ///
  /// In en, this message translates to:
  /// **'Key generated successfully'**
  String get keyGenerated;

  /// No description provided for @keyImported.
  ///
  /// In en, this message translates to:
  /// **'Key imported successfully'**
  String get keyImported;

  /// No description provided for @keyDeleted.
  ///
  /// In en, this message translates to:
  /// **'Key deleted'**
  String get keyDeleted;

  /// No description provided for @invalidKeyFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid key format'**
  String get invalidKeyFormat;

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get selectAll;

  /// No description provided for @deselectAll.
  ///
  /// In en, this message translates to:
  /// **'Deselect All'**
  String get deselectAll;

  /// No description provided for @batchDelete.
  ///
  /// In en, this message translates to:
  /// **'Batch Delete'**
  String get batchDelete;

  /// No description provided for @deleteSelected.
  ///
  /// In en, this message translates to:
  /// **'Delete Selected'**
  String get deleteSelected;

  /// No description provided for @itemsSelected.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String itemsSelected(int count);

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in Browser'**
  String get openInBrowser;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @welcomeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Premium!'**
  String get welcomeToPremium;

  /// No description provided for @continueWith.
  ///
  /// In en, this message translates to:
  /// **'Continue with {price}'**
  String continueWith(String price);

  /// No description provided for @selectPlan.
  ///
  /// In en, this message translates to:
  /// **'Select a plan'**
  String get selectPlan;

  /// No description provided for @alreadyLifetime.
  ///
  /// In en, this message translates to:
  /// **'Already Lifetime'**
  String get alreadyLifetime;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'Terms'**
  String get terms;

  /// No description provided for @checkingPurchases.
  ///
  /// In en, this message translates to:
  /// **'Checking for previous purchases...'**
  String get checkingPurchases;

  /// No description provided for @unlockFullPower.
  ///
  /// In en, this message translates to:
  /// **'Unlock Full Power'**
  String get unlockFullPower;

  /// No description provided for @unlockDescription.
  ///
  /// In en, this message translates to:
  /// **'Unlock all conversations and\nend-to-end encryption'**
  String get unlockDescription;

  /// No description provided for @unlimitedConversations.
  ///
  /// In en, this message translates to:
  /// **'Unlimited Conversations'**
  String get unlimitedConversations;

  /// No description provided for @viewAllGroups.
  ///
  /// In en, this message translates to:
  /// **'View all your message groups'**
  String get viewAllGroups;

  /// No description provided for @secureMessages.
  ///
  /// In en, this message translates to:
  /// **'Secure your sensitive messages'**
  String get secureMessages;

  /// No description provided for @helpKeepAlive.
  ///
  /// In en, this message translates to:
  /// **'Help keep the app alive'**
  String get helpKeepAlive;

  /// No description provided for @savePercent.
  ///
  /// In en, this message translates to:
  /// **'Save {percent}% compared to monthly'**
  String savePercent(int percent);

  /// No description provided for @oneTime.
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get oneTime;

  /// No description provided for @lifetimePremium.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Premium'**
  String get lifetimePremium;

  /// No description provided for @permanentAccess.
  ///
  /// In en, this message translates to:
  /// **'You have permanent access to all features'**
  String get permanentAccess;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @multiSelect.
  ///
  /// In en, this message translates to:
  /// **'Multi-select'**
  String get multiSelect;

  /// No description provided for @authRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get authRequired;

  /// No description provided for @authReason.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate to access your encryption key'**
  String get authReason;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed. Please try again.'**
  String get authFailed;

  /// No description provided for @authNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Authentication is not available on this device'**
  String get authNotAvailable;

  /// No description provided for @authCancelled.
  ///
  /// In en, this message translates to:
  /// **'Authentication was cancelled'**
  String get authCancelled;

  /// No description provided for @authNoCredentials.
  ///
  /// In en, this message translates to:
  /// **'No screen lock is set on this device. Please set up a password or PIN in system settings'**
  String get authNoCredentials;

  /// No description provided for @viewKey.
  ///
  /// In en, this message translates to:
  /// **'View Key'**
  String get viewKey;

  /// No description provided for @encryptedMessages.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Messages'**
  String get encryptedMessages;

  /// No description provided for @encryptedMessage.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Message'**
  String get encryptedMessage;

  /// No description provided for @encryptedMessagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage messages that failed to decrypt'**
  String get encryptedMessagesDescription;

  /// No description provided for @noEncryptedMessages.
  ///
  /// In en, this message translates to:
  /// **'No encrypted messages'**
  String get noEncryptedMessages;

  /// No description provided for @allMessagesDecrypted.
  ///
  /// In en, this message translates to:
  /// **'All messages have been successfully decrypted'**
  String get allMessagesDecrypted;

  /// No description provided for @encryptedMessagesCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 message} other{{count} messages}}'**
  String encryptedMessagesCount(int count);

  /// No description provided for @encryptedMessagesWithCount.
  ///
  /// In en, this message translates to:
  /// **'Encrypted Messages ({count})'**
  String encryptedMessagesWithCount(int count);

  /// No description provided for @retryAll.
  ///
  /// In en, this message translates to:
  /// **'Retry All'**
  String get retryAll;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All'**
  String get deleteAll;

  /// No description provided for @retryAllMessages.
  ///
  /// In en, this message translates to:
  /// **'Retry All Messages'**
  String get retryAllMessages;

  /// No description provided for @retryAllMessagesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to retry decrypting all encrypted messages?'**
  String get retryAllMessagesConfirm;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @retryComplete.
  ///
  /// In en, this message translates to:
  /// **'Retry complete: {success} succeeded, {failed} failed'**
  String retryComplete(int success, int failed);

  /// No description provided for @decryptionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Decryption successful'**
  String get decryptionSuccess;

  /// No description provided for @decryptionFailed.
  ///
  /// In en, this message translates to:
  /// **'Decryption failed, please check your key settings'**
  String get decryptionFailed;

  /// No description provided for @encryptedMessageNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'You have a new encrypted message that could not be decrypted'**
  String get encryptedMessageNotificationBody;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete Message'**
  String get deleteMessage;

  /// No description provided for @deleteMessageConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this encrypted message? This action cannot be undone.'**
  String get deleteMessageConfirm;

  /// No description provided for @messageDeleted.
  ///
  /// In en, this message translates to:
  /// **'Message deleted'**
  String get messageDeleted;

  /// No description provided for @deleteAllMessages.
  ///
  /// In en, this message translates to:
  /// **'Delete All Messages'**
  String get deleteAllMessages;

  /// No description provided for @deleteAllMessagesConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all encrypted messages? This action cannot be undone.'**
  String get deleteAllMessagesConfirm;

  /// No description provided for @allMessagesDeleted.
  ///
  /// In en, this message translates to:
  /// **'All messages deleted'**
  String get allMessagesDeleted;

  /// No description provided for @receivedAt.
  ///
  /// In en, this message translates to:
  /// **'Received At'**
  String get receivedAt;

  /// No description provided for @retryCount.
  ///
  /// In en, this message translates to:
  /// **'Retry Count'**
  String get retryCount;

  /// No description provided for @lastRetry.
  ///
  /// In en, this message translates to:
  /// **'Last Retry'**
  String get lastRetry;

  /// No description provided for @setupEncryption.
  ///
  /// In en, this message translates to:
  /// **'Set Up Encryption'**
  String get setupEncryption;

  /// No description provided for @faqQuestion1.
  ///
  /// In en, this message translates to:
  /// **'What is end-to-end encryption?'**
  String get faqQuestion1;

  /// No description provided for @faqAnswer1.
  ///
  /// In en, this message translates to:
  /// **'End-to-end encryption means your messages are encrypted before sending and only decrypted when they reach the recipient. Throughout the entire transmission process, including servers and any intermediate nodes, no one can view the original message content. Only the sender and recipient can read the messages.'**
  String get faqAnswer1;

  /// No description provided for @faqQuestion2.
  ///
  /// In en, this message translates to:
  /// **'What happens if I lose my key?'**
  String get faqQuestion2;

  /// No description provided for @faqAnswer2.
  ///
  /// In en, this message translates to:
  /// **'If you lose your encryption key, you will not be able to decrypt any future encrypted messages. Make sure to back up your key securely.'**
  String get faqAnswer2;

  /// No description provided for @faqQuestion3.
  ///
  /// In en, this message translates to:
  /// **'Can I change my key?'**
  String get faqQuestion3;

  /// No description provided for @faqAnswer3.
  ///
  /// In en, this message translates to:
  /// **'Yes, you can generate a new key or import a different one at any time. Messages are decrypted when received, so changing your key will not affect previously received messages.'**
  String get faqAnswer3;

  /// No description provided for @faqQuestion4.
  ///
  /// In en, this message translates to:
  /// **'Is my key stored on the server?'**
  String get faqQuestion4;

  /// No description provided for @faqAnswer4.
  ///
  /// In en, this message translates to:
  /// **'No. Your encryption key is stored only on your device using secure storage. The server never has access to your key.'**
  String get faqAnswer4;

  /// No description provided for @faqQuestion5.
  ///
  /// In en, this message translates to:
  /// **'What encryption algorithm is used?'**
  String get faqQuestion5;

  /// No description provided for @faqAnswer5.
  ///
  /// In en, this message translates to:
  /// **'We use AES-256-GCM (Advanced Encryption Standard with 256-bit keys in Galois/Counter Mode). This is a widely validated symmetric encryption algorithm that provides strong security and data integrity protection.'**
  String get faqAnswer5;

  /// No description provided for @importKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Enter Base64 encoded key...'**
  String get importKeyHint;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get loadFailed;

  /// No description provided for @deleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Delete failed'**
  String get deleteFailed;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @audioManagement.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get audioManagement;

  /// No description provided for @notificationSound.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound'**
  String get notificationSound;

  /// No description provided for @systemRingtone.
  ///
  /// In en, this message translates to:
  /// **'System Ringtone'**
  String get systemRingtone;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @customAudio.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get customAudio;

  /// No description provided for @customRingtones.
  ///
  /// In en, this message translates to:
  /// **'Custom Ringtones'**
  String get customRingtones;

  /// No description provided for @manageCustomAudio.
  ///
  /// In en, this message translates to:
  /// **'Manage custom notification sounds and ringtones'**
  String get manageCustomAudio;

  /// No description provided for @importAudio.
  ///
  /// In en, this message translates to:
  /// **'Import Notification Sound'**
  String get importAudio;

  /// No description provided for @setAudioName.
  ///
  /// In en, this message translates to:
  /// **'Set Notification Sound Name'**
  String get setAudioName;

  /// No description provided for @audioNameHint.
  ///
  /// In en, this message translates to:
  /// **'Used to specify this sound when sending messages'**
  String get audioNameHint;

  /// No description provided for @useDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Use Default Name'**
  String get useDefaultName;

  /// No description provided for @confirmImport.
  ///
  /// In en, this message translates to:
  /// **'Confirm Import'**
  String get confirmImport;

  /// No description provided for @trimAudio.
  ///
  /// In en, this message translates to:
  /// **'Trim Audio'**
  String get trimAudio;

  /// No description provided for @trimAudioHint.
  ///
  /// In en, this message translates to:
  /// **'Drag selection to adjust trim range'**
  String get trimAudioHint;

  /// No description provided for @zoomLevel.
  ///
  /// In en, this message translates to:
  /// **'Zoom'**
  String get zoomLevel;

  /// No description provided for @selectionDuration.
  ///
  /// In en, this message translates to:
  /// **'Selection'**
  String get selectionDuration;

  /// No description provided for @audioDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get audioDuration;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get endTime;

  /// No description provided for @maxDuration.
  ///
  /// In en, this message translates to:
  /// **'Max 30 seconds'**
  String get maxDuration;

  /// No description provided for @exceedsMaxDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration cannot exceed 30 seconds'**
  String get exceedsMaxDuration;

  /// No description provided for @noCustomAudio.
  ///
  /// In en, this message translates to:
  /// **'No custom notification sound'**
  String get noCustomAudio;

  /// No description provided for @tapAddToImport.
  ///
  /// In en, this message translates to:
  /// **'Tap + to import notification sound'**
  String get tapAddToImport;

  /// No description provided for @customSoundApiTitle.
  ///
  /// In en, this message translates to:
  /// **'API Parameter Example'**
  String get customSoundApiTitle;

  /// No description provided for @customSoundApiDescription.
  ///
  /// In en, this message translates to:
  /// **'Use the sound parameter in push request to specify custom sound:'**
  String get customSoundApiDescription;

  /// No description provided for @viewDocs.
  ///
  /// In en, this message translates to:
  /// **'Docs'**
  String get viewDocs;

  /// No description provided for @deleteAudio.
  ///
  /// In en, this message translates to:
  /// **'Delete Notification Sound'**
  String get deleteAudio;

  /// No description provided for @deleteAudioConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this notification sound?'**
  String get deleteAudioConfirm;

  /// No description provided for @audioDeleted.
  ///
  /// In en, this message translates to:
  /// **'Notification sound deleted'**
  String get audioDeleted;

  /// No description provided for @renameAudio.
  ///
  /// In en, this message translates to:
  /// **'Rename Notification Sound'**
  String get renameAudio;

  /// No description provided for @audioName.
  ///
  /// In en, this message translates to:
  /// **'Notification Sound Name'**
  String get audioName;

  /// No description provided for @enterAudioName.
  ///
  /// In en, this message translates to:
  /// **'Enter notification sound name'**
  String get enterAudioName;

  /// No description provided for @renameSuccess.
  ///
  /// In en, this message translates to:
  /// **'Renamed successfully'**
  String get renameSuccess;

  /// No description provided for @renameFailed.
  ///
  /// In en, this message translates to:
  /// **'Rename failed'**
  String get renameFailed;

  /// No description provided for @audioImported.
  ///
  /// In en, this message translates to:
  /// **'Notification sound imported'**
  String get audioImported;

  /// No description provided for @trimFailed.
  ///
  /// In en, this message translates to:
  /// **'Trim failed'**
  String get trimFailed;

  /// No description provided for @getAudioInfoFailed.
  ///
  /// In en, this message translates to:
  /// **'Unsupported audio format'**
  String get getAudioInfoFailed;

  /// No description provided for @previewFailed.
  ///
  /// In en, this message translates to:
  /// **'Preview failed'**
  String get previewFailed;

  /// No description provided for @systemDefaultCannotPreview.
  ///
  /// In en, this message translates to:
  /// **'System default ringtone cannot be previewed'**
  String get systemDefaultCannotPreview;

  /// No description provided for @storagePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Storage permission denied'**
  String get storagePermissionDenied;

  /// No description provided for @filePathNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'File path not available'**
  String get filePathNotAvailable;

  /// No description provided for @loadingAudio.
  ///
  /// In en, this message translates to:
  /// **'Loading notification sound...'**
  String get loadingAudio;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// Total duration of audio
  ///
  /// In en, this message translates to:
  /// **'Total duration: {duration}'**
  String totalDuration(String duration);

  /// Trimmed duration of audio
  ///
  /// In en, this message translates to:
  /// **'Trimmed duration: {duration}'**
  String trimmedDuration(String duration);

  /// No description provided for @webhookToken.
  ///
  /// In en, this message translates to:
  /// **'Pseudo Device Token'**
  String get webhookToken;

  /// No description provided for @webhookTokenFaq.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get webhookTokenFaq;

  /// No description provided for @webhookTokenFaqTitle.
  ///
  /// In en, this message translates to:
  /// **'About Pseudo Device Token'**
  String get webhookTokenFaqTitle;

  /// No description provided for @webhookUsingPseudoToken.
  ///
  /// In en, this message translates to:
  /// **'Pseudo device token'**
  String get webhookUsingPseudoToken;

  /// No description provided for @webhookUsingRealToken.
  ///
  /// In en, this message translates to:
  /// **'Real device token'**
  String get webhookUsingRealToken;

  /// No description provided for @resetWebhookToken.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get resetWebhookToken;

  /// No description provided for @resetWebhookTokenDescription.
  ///
  /// In en, this message translates to:
  /// **'Generate a new pseudo device token'**
  String get resetWebhookTokenDescription;

  /// No description provided for @resetWebhookTokenConfirm.
  ///
  /// In en, this message translates to:
  /// **'After reset, the webhook server will receive a new token. If the server relies on this token to recognize your device, you may need to reconfigure it. Are you sure?'**
  String get resetWebhookTokenConfirm;

  /// No description provided for @webhookTokenReset.
  ///
  /// In en, this message translates to:
  /// **'Pseudo token has been reset'**
  String get webhookTokenReset;

  /// No description provided for @switchToRealToken.
  ///
  /// In en, this message translates to:
  /// **'Disable Pseudo Token'**
  String get switchToRealToken;

  /// No description provided for @switchToRealTokenDescription.
  ///
  /// In en, this message translates to:
  /// **'Send real device token to webhook server'**
  String get switchToRealTokenDescription;

  /// No description provided for @switchToRealTokenConfirm.
  ///
  /// In en, this message translates to:
  /// **'The real device token is sensitive information that could be used to track your device. Unless you trust the webhook server, it\'s recommended to use a pseudo device token. Are you sure?'**
  String get switchToRealTokenConfirm;

  /// No description provided for @switchedToRealToken.
  ///
  /// In en, this message translates to:
  /// **'Pseudo token disabled'**
  String get switchedToRealToken;

  /// No description provided for @usePseudoToken.
  ///
  /// In en, this message translates to:
  /// **'Pseudo Device Token'**
  String get usePseudoToken;

  /// No description provided for @usePseudoTokenDescription.
  ///
  /// In en, this message translates to:
  /// **'Use a randomly generated token instead of real device token'**
  String get usePseudoTokenDescription;

  /// No description provided for @switchToPseudoToken.
  ///
  /// In en, this message translates to:
  /// **'Enable Pseudo Token'**
  String get switchToPseudoToken;

  /// No description provided for @switchToPseudoTokenDescription.
  ///
  /// In en, this message translates to:
  /// **'Use a randomly generated token for privacy'**
  String get switchToPseudoTokenDescription;

  /// No description provided for @switchedToPseudoToken.
  ///
  /// In en, this message translates to:
  /// **'Pseudo token enabled'**
  String get switchedToPseudoToken;

  /// No description provided for @webhookFaqQuestion1.
  ///
  /// In en, this message translates to:
  /// **'What is a Pseudo Device Token?'**
  String get webhookFaqQuestion1;

  /// No description provided for @webhookFaqAnswer1.
  ///
  /// In en, this message translates to:
  /// **'When you tap action buttons or send replies, the app sends requests to webhook servers. To identify the request source, a device token is included. The pseudo device token is a randomly generated identifier that can replace your real token, allowing the server to identify your device while protecting your privacy.'**
  String get webhookFaqAnswer1;

  /// No description provided for @webhookFaqQuestion2.
  ///
  /// In en, this message translates to:
  /// **'Why use a pseudo device token?'**
  String get webhookFaqQuestion2;

  /// No description provided for @webhookFaqAnswer2.
  ///
  /// In en, this message translates to:
  /// **'The real device token (APNs/FCM Token) is sensitive information that could be used to track your device or send unauthorized push notifications. Using a pseudo device token protects your privacy while maintaining functionality.'**
  String get webhookFaqAnswer2;

  /// No description provided for @webhookFaqQuestion3.
  ///
  /// In en, this message translates to:
  /// **'When should I use the real token?'**
  String get webhookFaqQuestion3;

  /// No description provided for @webhookFaqAnswer3.
  ///
  /// In en, this message translates to:
  /// **'If your webhook server needs the device token to send push notifications (e.g., sending confirmation after you reply), you need to disable the pseudo token. Otherwise, it\'s recommended to always keep it enabled.'**
  String get webhookFaqAnswer3;

  /// No description provided for @webhookFaqQuestion4.
  ///
  /// In en, this message translates to:
  /// **'What happens when I reset the pseudo token?'**
  String get webhookFaqQuestion4;

  /// No description provided for @webhookFaqAnswer4.
  ///
  /// In en, this message translates to:
  /// **'After reset, the webhook server will receive a completely new token. If the server uses the token to associate user data, you may need to re-establish the association. This won\'t affect receiving push notifications.'**
  String get webhookFaqAnswer4;

  /// No description provided for @initializationFailed.
  ///
  /// In en, this message translates to:
  /// **'Initialization Failed'**
  String get initializationFailed;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Lightweight yet powerful message terminal'**
  String get splashTagline;

  /// No description provided for @splashSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Built for handling messages'**
  String get splashSubtitle;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more at linu.aprilzz.com'**
  String get learnMore;

  /// No description provided for @replaceExistingKey.
  ///
  /// In en, this message translates to:
  /// **'Replace existing key?'**
  String get replaceExistingKey;

  /// No description provided for @replaceKeyConfirm.
  ///
  /// In en, this message translates to:
  /// **'You already have an encryption key. Importing a new key will replace the existing one. Are you sure you want to continue?'**
  String get replaceKeyConfirm;

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @defaultNotification.
  ///
  /// In en, this message translates to:
  /// **'Default Notification'**
  String get defaultNotification;

  /// No description provided for @pushNotificationChannel.
  ///
  /// In en, this message translates to:
  /// **'Push message notifications'**
  String get pushNotificationChannel;

  /// No description provided for @newMessage.
  ///
  /// In en, this message translates to:
  /// **'New Message'**
  String get newMessage;

  /// No description provided for @decryptedMessageChannel.
  ///
  /// In en, this message translates to:
  /// **'Decrypted Messages'**
  String get decryptedMessageChannel;

  /// No description provided for @decryptedMessageChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Successfully decrypted encrypted messages'**
  String get decryptedMessageChannelDescription;

  /// No description provided for @welcomeTo.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {appName}'**
  String welcomeTo(String appName);

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your personal message hub'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingFeatureTokenTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Token'**
  String get onboardingFeatureTokenTitle;

  /// No description provided for @onboardingFeatureTokenDescription.
  ///
  /// In en, this message translates to:
  /// **'Find your unique device token in Settings to receive push notifications.'**
  String get onboardingFeatureTokenDescription;

  /// No description provided for @onboardingFeatureServerTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Setup'**
  String get onboardingFeatureServerTitle;

  /// No description provided for @onboardingFeatureServerDescription.
  ///
  /// In en, this message translates to:
  /// **'Deploy your own Linu server or use our hosted service.'**
  String get onboardingFeatureServerDescription;

  /// No description provided for @onboardingFeatureApiTitle.
  ///
  /// In en, this message translates to:
  /// **'API Integration'**
  String get onboardingFeatureApiTitle;

  /// No description provided for @onboardingFeatureApiDescription.
  ///
  /// In en, this message translates to:
  /// **'Send messages via our simple REST API from any system or service.'**
  String get onboardingFeatureApiDescription;

  /// No description provided for @aboutLinuName.
  ///
  /// In en, this message translates to:
  /// **'About the Name'**
  String get aboutLinuName;

  /// No description provided for @aboutLinuNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Why \"Linu\"?'**
  String get aboutLinuNameTitle;

  /// No description provided for @aboutLinuNameContent.
  ///
  /// In en, this message translates to:
  /// **'\"Linu\" (狸奴) is an ancient Chinese term of endearment for cats, first appearing in the poetry of Lu You, a Song Dynasty poet.\n\nJust as cats once quietly guarded homes and brought warmth, Linu now faithfully delivers your important notifications — always by your side, quiet yet reliable.'**
  String get aboutLinuNameContent;

  /// No description provided for @ringingDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get ringingDefaultTitle;

  /// No description provided for @ringingDefaultBody.
  ///
  /// In en, this message translates to:
  /// **'Important message'**
  String get ringingDefaultBody;

  /// No description provided for @docs.
  ///
  /// In en, this message translates to:
  /// **'Documentation'**
  String get docs;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
