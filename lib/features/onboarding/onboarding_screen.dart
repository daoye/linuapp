import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app/l10n/app_localizations.dart';
import 'package:app/db/database_provider.dart';
import 'package:app/shared/widgets/primary_button.dart';
import 'package:app/shared/constants.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/utils.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final prefersReducedMotion = AppUtils.prefersReducedMotion(context);

    return Scaffold(
      backgroundColor: isDark
          ? LinuColors.darkListBackground
          : LinuColors.lightListBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: LinuSpacing.xl,
            vertical: LinuSpacing.lg,
          ),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Logo with rounded corners
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/icon/logo.png',
                  width: 100,
                  height: 100,
                ),
              )
                  .animate()
                  .fadeIn(
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    curve: Curves.easeOut,
                  )
                  .scale(
                    begin: const Offset(0.9, 0.9),
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: LinuSpacing.xl),

              // Welcome Title
              Text(
                l10n.welcomeTo(l10n.appTitle),
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    delay: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.delayStandard,
                  )
                  .slideY(
                    begin: 0.15,
                    end: 0,
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: LinuSpacing.sm),

              // Subtitle
              Text(
                l10n.onboardingSubtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? LinuColors.darkSecondaryText
                      : LinuColors.lightSecondaryText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    delay: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.delayLong,
                  ),

              const Spacer(flex: 1),

              // Feature Cards
              _FeatureCard(
                icon: Icons.fingerprint_outlined,
                title: l10n.onboardingFeatureTokenTitle,
                description: l10n.onboardingFeatureTokenDescription,
                isDark: isDark,
              ).animate().fadeIn(
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    delay: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.delaySequence2,
                  ).slideX(
                    begin: -0.05,
                    end: 0,
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: LinuSpacing.md),

              _FeatureCard(
                icon: Icons.dns_outlined,
                title: l10n.onboardingFeatureServerTitle,
                description: l10n.onboardingFeatureServerDescription,
                isDark: isDark,
              ).animate().fadeIn(
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    delay: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.delaySequence3,
                  ).slideX(
                    begin: -0.05,
                    end: 0,
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: LinuSpacing.md),

              _FeatureCard(
                icon: Icons.code_outlined,
                title: l10n.onboardingFeatureApiTitle,
                description: l10n.onboardingFeatureApiDescription,
                isDark: isDark,
              ).animate().fadeIn(
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    delay: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.delaySequence4,
                  ).slideX(
                    begin: -0.05,
                    end: 0,
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    curve: Curves.easeOutCubic,
                  ),

              const Spacer(flex: 2),

              // Get Started Button
              PrimaryButton(
                label: l10n.getStarted,
                onPressed: () => _completeOnboarding(context, ref),
              ).animate().fadeIn(
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    delay: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.delaySequence5,
                  ).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.medium,
                    curve: Curves.easeOutCubic,
                  ),

              const SizedBox(height: LinuSpacing.md),

              // Learn More Link
              TextButton(
                onPressed: () => _openDocumentation(),
                style: TextButton.styleFrom(
                  foregroundColor: isDark
                      ? LinuColors.darkTertiaryText
                      : LinuColors.lightTertiaryText,
                ),
                child: Text(
                  l10n.learnMore,
                  style: LinuTextStyles.caption,
                ),
              ).animate().fadeIn(
                    duration: prefersReducedMotion
                        ? 0.ms
                        : AnimationDurations.fast,
                    delay: prefersReducedMotion
                        ? Duration.zero
                        : AnimationDurations.delaySequence6,
                  ),

              const SizedBox(height: LinuSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeOnboarding(BuildContext context, WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    await db.setSetting('onboarding_completed', 'true');
    if (context.mounted) {
      context.go('/conversationlist');
    }
  }

  Future<void> _openDocumentation() async {
    final uri = Uri.parse('https://linu.aprilzz.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Feature Card Widget
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isDark;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(LinuSpacing.lg),
      decoration: BoxDecoration(
        color: isDark
            ? LinuColors.darkCardSurface
            : LinuColors.lightCardSurface,
        borderRadius: BorderRadius.circular(LinuRadius.large),
        border: Border.all(
          color: isDark
              ? LinuColors.darkBorder.withValues(alpha: 0.5)
              : LinuColors.lightBorder.withValues(alpha: 0.8),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? LinuColors.darkChatBackground
                  : LinuColors.lightChatBackground,
              borderRadius: BorderRadius.circular(LinuRadius.medium),
            ),
            child: Icon(
              icon,
              color: isDark
                  ? LinuColors.darkPrimaryText
                  : LinuColors.lightPrimaryText,
              size: 22,
            ),
          ),
          const SizedBox(width: LinuSpacing.lg),
          // Text Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: LinuSpacing.xs),
                Text(
                  description,
                  style: LinuTextStyles.caption.copyWith(
                    color: isDark
                        ? LinuColors.darkSecondaryText
                        : LinuColors.lightSecondaryText,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
