import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/db/database.dart';
import 'package:app/db/database_provider.dart';
import 'package:app/shared/encrypted_message_retry_service.dart';

/// 待解密消息列表 Provider
final encryptedMessagesProvider = StreamProvider<List<EncryptedMessage>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.select(db.encryptedMessages).watch();
});

/// 待解密消息数量 Provider
final encryptedMessagesCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchPendingEncryptedMessagesCount();
});

/// 重试状态
class RetryState {
  final bool isRetrying;
  final RetryResult? lastResult;
  final String? error;

  const RetryState({
    this.isRetrying = false,
    this.lastResult,
    this.error,
  });

  RetryState copyWith({
    bool? isRetrying,
    RetryResult? lastResult,
    String? error,
  }) {
    return RetryState(
      isRetrying: isRetrying ?? this.isRetrying,
      lastResult: lastResult ?? this.lastResult,
      error: error,
    );
  }
}

/// 重试状态管理 Provider
final retryStateProvider = NotifierProvider<RetryStateNotifier, RetryState>(
  RetryStateNotifier.new,
);

class RetryStateNotifier extends Notifier<RetryState> {
  @override
  RetryState build() => const RetryState();

  EncryptedMessageRetryService get _retryService =>
      ref.read(encryptedMessageRetryServiceProvider);

  /// 重试所有消息
  Future<void> retryAll() async {
    if (state.isRetrying) return;

    state = state.copyWith(isRetrying: true, error: null);

    try {
      final result = await _retryService.retryAll();
      state = state.copyWith(isRetrying: false, lastResult: result);
    } catch (e) {
      state = state.copyWith(isRetrying: false, error: e.toString());
    }
  }

  /// 重试单条消息
  Future<bool> retrySingle(String id) async {
    try {
      return await _retryService.retrySingle(id);
    } catch (e) {
      return false;
    }
  }
}

