import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:app/db/database_provider.dart';
import 'package:app/shared/constants.dart';
import 'package:app/shared/services/app_initialization_service.dart';
import 'package:app/theme/app_theme.dart';
import 'package:app/shared/utils.dart';
import 'package:app/l10n/app_localizations.dart';

/// Splash screen that displays the app tagline and performs initialization
/// 
/// Requirements:
/// - Display tagline "轻量却不简陋的消息终端、为处理消息而生" prominently
/// - Communicate value within 3 seconds (Value Clarity requirement)
/// - Minimalist design with subtle motion
/// - Execute all initialization tasks before navigation
/// - Transition to onboarding (first launch) or conversationlist (returning user)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 移除原生 splash，显示 Flutter splash
    FlutterNativeSplash.remove();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    // 先显示动画，然后开始初始化
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted) return;

    // 执行所有初始化任务
    final success = await ref.read(appInitializationProvider.notifier).initialize();

    if (!mounted) return;

    if (success) {
      // 检查 onboarding 状态
    final database = ref.read(databaseProvider);
    final onboardingCompleted = await database.getSetting('onboarding_completed');
    
    if (!mounted) return;

    if (onboardingCompleted == 'true') {
      context.go('/conversationlist');
      } else {
        context.go('/onboarding');
      }
    } else {
      // 初始化失败，显示错误
      _showInitializationError();
    }
  }

  void _showInitializationError() {
    final initState = ref.read(appInitializationProvider);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LinuRadius.large),
        ),
        title: Text(l10n.initializationFailed),
        content: Text(initState.error ?? l10n.unknownError),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startInitialization();
            },
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final prefersReducedMotion = AppUtils.prefersReducedMotion(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo with subtle scale animation
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(
                    'assets/icon/logo.png',
                    width: 140,
                    height: 140,
                  ),
                )
                    .animate()
                    .scale(
                      duration: prefersReducedMotion
                          ? 0.ms
                          : AnimationDurations.medium,
                      curve: Curves.easeOutCubic,
                    )
                    .fadeIn(
                      duration: prefersReducedMotion
                          ? 0.ms
                          : AnimationDurations.medium,
                    ),

                const SizedBox(height: 48),

                // Tagline - Primary value proposition
                Text(
                  l10n.splashTagline,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                    height: 1.3,
                  ),
                )
                    .animate(
                      delay: prefersReducedMotion
                          ? Duration.zero
                          : AnimationDurations.delayLong,
                    )
                    .fadeIn(
                      duration: prefersReducedMotion
                          ? Duration.zero
                          : AnimationDurations.medium,
                      curve: Curves.easeOut,
                    )
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: prefersReducedMotion
                          ? Duration.zero
                          : AnimationDurations.medium,
                      curve: Curves.easeOutCubic,
                    ),

                const SizedBox(height: 16),

                // Subtitle - Secondary value proposition
                Text(
                  l10n.splashSubtitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                )
                    .animate(
                      delay: prefersReducedMotion
                          ? Duration.zero
                          : AnimationDurations.delaySequence2,
                    )
                    .fadeIn(
                      duration: prefersReducedMotion
                          ? 0.ms
                          : AnimationDurations.medium,
                      curve: Curves.easeOut,
                    )
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: prefersReducedMotion
                          ? 0.ms
                          : AnimationDurations.medium,
                      curve: Curves.easeOutCubic,
                    ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
