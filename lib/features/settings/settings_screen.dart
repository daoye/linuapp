import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/features/settings/widgets/device_token_widget.dart';
import 'package:app/features/settings/widgets/theme_toggle.dart';
import 'package:app/features/settings/widgets/language_toggle.dart';
import 'package:app/features/settings/widgets/key_management_widget.dart';
import 'package:app/features/settings/widgets/audio_management_widget.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/services/toast_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  PackageInfo? _packageInfo;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() => _packageInfo = info);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ToastOverlay(
        showCenter: true,
        showBottom: false,
        child: ListView(
          padding: EdgeInsets.only(
            left: LinuSpacing.lg,
            right: LinuSpacing.lg,
            top: LinuSpacing.md,
            bottom: LinuSpacing.xl + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            // ========== 基础设置 ==========
            // Language
            const LanguageToggle(),
            const SizedBox(height: LinuSpacing.md),

            // Theme
            const ThemeToggle(),
            const SizedBox(height: LinuSpacing.md),

            // Audio Management
            const AudioManagementWidget(),

            const SizedBox(height: LinuSpacing.xl),

            // ========== 推送与安全 ==========
            _buildSectionTitle(theme, l10n.deviceToken),
            const SizedBox(height: LinuSpacing.sm),
            const DeviceTokenWidget(),
            const SizedBox(height: LinuSpacing.md),

            // Key Management (端到端消息加密)
            const KeyManagementWidget(),

            const SizedBox(height: LinuSpacing.xl),

            // ========== 法律信息 ==========
            _buildSectionTitle(theme, l10n.legal),
            const SizedBox(height: LinuSpacing.sm),
            Card(
              child: Column(
                children: [

                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(l10n.termsOfService),
                    trailing: const Icon(Icons.open_in_new, size: 16),
                    onTap: () => _openUrl('https://linu.aprilzz.com/agreement'),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(l10n.privacyPolicy),
                    trailing: const Icon(Icons.open_in_new, size: 16),
                    onTap: () => _openUrl('https://linu.aprilzz.com/privacy'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: LinuSpacing.xl),

            // ========== 关于 ==========
            _buildSectionTitle(theme, l10n.about),
            const SizedBox(height: LinuSpacing.sm),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: Text(l10n.docs),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => context.push('/docs'),
                  ),
                  const Divider(height: 1),
                  // App Version
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text(l10n.appVersion),
                    subtitle: _packageInfo != null
                        ? Text(
                            '${_packageInfo!.version} (${_packageInfo!.buildNumber})')
                        : Text(l10n.loading),
                  ),
                  const Divider(height: 1),
                  // About Name
                  ListTile(
                    leading: const Icon(Icons.pets_outlined),
                    title: Text(l10n.aboutLinuName),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => _showAboutNameSheet(context, l10n, theme),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建分组标题
  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: LinuSpacing.xs),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


  Future<void> _openUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ToastService.instance.showCenter(
          'Could not open $urlString',
          false,
          isSuccess: false,
          backgroundColor: Theme.of(context).colorScheme.error,
          icon: Icons.error,
        );
      }
    }
  }

  void _showAboutNameSheet(
    BuildContext context,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final isDark = theme.brightness == Brightness.dark;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(LinuRadius.xlarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: LinuSpacing.md),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  LinuSpacing.xl,
                  LinuSpacing.xl,
                  LinuSpacing.xl,
                  LinuSpacing.xl + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/icon/logo.png',
                        width: 80,
                        height: 80,
                      ),
                    ),
                    
                    const SizedBox(height: LinuSpacing.lg),
                    
                    // Title
                    Text(
                      l10n.aboutLinuNameTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: LinuSpacing.lg),
                    
                    // Content
                    Container(
                      padding: const EdgeInsets.all(LinuSpacing.lg),
                      decoration: BoxDecoration(
                        color: isDark
                            ? LinuColors.darkElevatedSurface
                            : LinuColors.lightChatBackground,
                        borderRadius: BorderRadius.circular(LinuRadius.large),
                      ),
                      child: Text(
                        l10n.aboutLinuNameContent,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    
                    const SizedBox(height: LinuSpacing.xl),
                    
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(l10n.confirm),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
