import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app/l10n/app_localizations.dart';

import 'package:app/theme/app_theme.dart';
import 'package:app/features/conversations/conversation_list.dart';
import 'package:app/features/conversations/group_conversation.dart';
import 'package:app/features/settings/settings_screen.dart';
import 'package:app/features/settings/settings_provider.dart';
import 'package:app/features/onboarding/onboarding_screen.dart';
import 'package:app/features/splash/splash_screen.dart';
import 'package:app/features/messages/encrypted_messages_page.dart';
import 'package:app/features/audio/pages/audio_management_page.dart';

// 全局 NavigatorKey（用于显示 Overlay）
final globalNavigatorKey = GlobalKey<NavigatorState>();

/// 安全读取 URI query 参数，避免 groupId/messageId 含非法 UTF-8 时 FormatException
String? _safeQueryParam(Uri uri, String name) {
  try {
    return uri.queryParameters[name];
  } on FormatException {
    return null;
  }
}

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: globalNavigatorKey,
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/splash',
      ),
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SplashScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/conversationlist',
        builder: (context, state) {
          final messageId = _safeQueryParam(state.uri, 'messageId');
          return ConversationList(highlightMessageId: messageId);
        },
        routes: [
          GoRoute(
            path: ':groupId',
            builder: (context, state) {
              final groupId = state.pathParameters['groupId'];
              final messageId = _safeQueryParam(state.uri, 'messageId');
              if (groupId == null) return const ConversationList();
              return GroupConversation(
                groupId: groupId,
                highlightMessageId: messageId,
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/encrypted-messages',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const EncryptedMessagesPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/audio-management',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const AudioManagementPage(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.02),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            key: state.pageKey,
            child: const OnboardingScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              final curved = CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              );
              return FadeTransition(
                opacity: curved,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(curved),
                  child: child,
                ),
              );
            },
          );
        },
      ),
    ],
  );
});

/// 应用主入口
/// 
/// 所有初始化逻辑已移至 SplashScreen，通过 AppInitializationService 执行。
/// 这样可以确保用户进入 ConversationList 时，所有服务已就绪，获得最佳体验。
class LinuApp extends ConsumerWidget {
  const LinuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsProvider);

    // For iOS/macOS we delegate language selection entirely to the system
    // (including per-app language in iOS Settings). Overriding `locale`
    // here would fight against the system-level language toggle.
    // On Android and other platforms we still honor the in-app locale.
    final bool isCupertinoPlatform =
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
    final Locale? effectiveLocale =
        isCupertinoPlatform ? null : settings.locale;

    return MaterialApp.router(
      title: 'Linu',
      theme: LinuTheme.light,
      darkTheme: LinuTheme.dark,
      themeMode: settings.themeMode,
      locale: effectiveLocale,
      routerConfig: router,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
