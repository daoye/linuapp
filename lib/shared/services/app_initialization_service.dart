import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/db/database_provider.dart';
import 'package:app/features/push/push_service.dart';
import 'package:app/features/settings/key_manager.dart';
import 'package:app/features/conversations/conversation_list_provider.dart';
import 'package:app/shared/local_notification_service.dart';

/// 初始化步骤枚举
enum InitializationStep {
  database,
  pushService,
  localNotification,
  conversationList,
}

/// 初始化状态
class InitializationState {
  final InitializationStep currentStep;
  final bool isComplete;
  final String? error;
  final double progress;

  const InitializationState({
    this.currentStep = InitializationStep.database,
    this.isComplete = false,
    this.error,
    this.progress = 0.0,
  });

  InitializationState copyWith({
    InitializationStep? currentStep,
    bool? isComplete,
    String? error,
    double? progress,
  }) {
    return InitializationState(
      currentStep: currentStep ?? this.currentStep,
      isComplete: isComplete ?? this.isComplete,
      error: error,
      progress: progress ?? this.progress,
    );
  }

  /// 获取当前步骤的本地化描述
  String get stepDescription {
    switch (currentStep) {
      case InitializationStep.database:
        return '正在初始化数据库...';
      case InitializationStep.pushService:
        return '正在配置推送服务...';
      case InitializationStep.localNotification:
        return '正在初始化通知服务...';
      case InitializationStep.conversationList:
        return '正在加载消息列表...';
    }
  }
}

/// 应用初始化服务
class AppInitializationNotifier extends Notifier<InitializationState> {
  @override
  InitializationState build() {
    return const InitializationState();
  }

  /// 执行所有初始化步骤
  Future<bool> initialize() async {
    try {
      final totalSteps = kDebugMode ? 5 : 4;
      int completedSteps = 0;

      void updateProgress(InitializationStep step) {
        completedSteps++;
        state = state.copyWith(
          currentStep: step,
          progress: completedSteps / totalSteps,
        );
      }

      // 1. 数据库初始化（通过 provider 自动完成，这里只是确保它已就绪）
      state = state.copyWith(
        currentStep: InitializationStep.database,
        progress: 0.0,
      );
      final db = ref.read(databaseProvider);
      // 简单读取一次确保数据库连接正常
      await db.getSetting('app_initialized');
      updateProgress(InitializationStep.database);

      // 2. Push Service 初始化（包括 token 获取）
      state = state.copyWith(currentStep: InitializationStep.pushService);
      await ref.read(pushServiceProvider).initialize();
      updateProgress(InitializationStep.pushService);

      // 3. Local Notification Service 初始化
      state = state.copyWith(currentStep: InitializationStep.localNotification);
      await ref.read(localNotificationServiceProvider).initialize();
      updateProgress(InitializationStep.localNotification);

      // 4. 预加载 Conversation List
      state = state.copyWith(currentStep: InitializationStep.conversationList);
      // 触发 provider 预加载数据
      final conversationListAsync = ref.read(conversationListProvider);
      // 等待数据加载完成
      await conversationListAsync.when(
        data: (_) async {},
        loading: () async {
          // 等待加载完成
          await Future.delayed(const Duration(milliseconds: 100));
        },
        error: (e, s) async {
          debugPrint('Conversation list preload error: $e');
        },
      );
      updateProgress(InitializationStep.conversationList);

      // 6. 注册 KeyManager callback（不再处理加密消息重试）
      final keyManager = ref.read(keyManagerProvider);
      keyManager.addOnKeyChangedCallback(() async {
        debugPrint('Key changed');
      });

      // 标记完成
      state = state.copyWith(isComplete: true, progress: 1.0);
      return true;
    } catch (e, stack) {
      debugPrint('App initialization error: $e\n$stack');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final appInitializationProvider =
    NotifierProvider<AppInitializationNotifier, InitializationState>(
  AppInitializationNotifier.new,
);

