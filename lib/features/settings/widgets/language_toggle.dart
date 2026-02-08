import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/features/settings/settings_provider.dart';

class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final platform = theme.platform;

    // iOS/macOS: language is fully controlled by system settings
    final bool isCupertinoPlatform =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    // 获取当前实际使用的语言
    final currentLocale = Localizations.localeOf(context);
    
    String currentKey;
    if (isCupertinoPlatform) {
      // iOS/macOS 始终使用系统设置
      currentKey = 'system';
    } else {
      // Android: 如果用户设置了语言就用用户设置的，否则显示实际使用的语言
      if (settings.locale != null) {
        currentKey = settings.locale!.languageCode;
      } else {
        // 未设置语言时，显示系统
        currentKey = 'system';
      }
    }

    final currentLabel = _labelForKey(currentKey, currentLocale, l10n);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.language),
        title: Text(
          l10n.language,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(currentLabel),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _handleTap(context, ref, currentKey),
      ),
    );
  }

  String _labelForKey(String key, Locale currentLocale, AppLocalizations l10n) {
    switch (key) {
      case 'en':
        return l10n.english;
      case 'zh':
        return l10n.simplifiedChinese;
      case 'system':
        // 显示"系统 (实际语言)"
        final actualLang = currentLocale.languageCode == 'zh'
            ? l10n.simplifiedChinese
            : l10n.english;
        return actualLang;
      default:
        return l10n.systemLanguage;
    }
  }

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    String currentKey,
  ) async {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS || platform == TargetPlatform.macOS) {
      await _openSystemLanguageSettings();
    } else {
      await _showLanguageSheet(context, ref, currentKey);
    }
  }

  Future<void> _openSystemLanguageSettings() async {
    final uri = Uri.parse('app-settings:');
    try {
      await launchUrl(uri);
    } catch (_) {
      // Ignore failures silently; system settings may not be available.
    }
  }

  Future<void> _showLanguageSheet(
    BuildContext context,
    WidgetRef ref,
    String currentKey,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final selectedKey = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(l10n.systemLanguage),
                trailing: currentKey == 'system'
                    ? const Icon(Icons.check, size: 18)
                    : null,
                onTap: () => Navigator.of(context).pop('system'),
              ),
              ListTile(
                title: Text(l10n.english),
                trailing:
                    currentKey == 'en' ? const Icon(Icons.check, size: 18) : null,
                onTap: () => Navigator.of(context).pop('en'),
              ),
              ListTile(
                title: Text(l10n.simplifiedChinese),
                trailing:
                    currentKey == 'zh' ? const Icon(Icons.check, size: 18) : null,
                onTap: () => Navigator.of(context).pop('zh'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (selectedKey == null || selectedKey == currentKey) return;

    Locale? locale;
    if (selectedKey == 'en') {
      locale = const Locale('en');
    } else if (selectedKey == 'zh') {
      locale = const Locale('zh');
    } else {
      locale = null;
    }

    await ref.read(settingsProvider.notifier).setLocale(locale);
  }
}
