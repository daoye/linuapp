import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/shared/services/biometric_auth_service.dart';

/// 身份认证异常
class AuthenticationException implements Exception {
  final AuthErrorType errorType;
  final String message;

  AuthenticationException(this.errorType, this.message);

  @override
  String toString() => message;
}

final keyManagerProvider = Provider((ref) => KeyManager(ref));

final encryptionKeyProvider = FutureProvider<SecretKey?>((ref) async {
  final manager = ref.watch(keyManagerProvider);
  return manager.getEncryptionKey();
});

/// 密钥变更回调类型
typedef OnKeyChanged = Future<void> Function();

class KeyManager {
  // ignore: unused_field - 保留以便将来使用
  final Ref _ref;

  final _storage = const FlutterSecureStorage(
    iOptions: IOSOptions(
      groupId: 'group.com.aprilzz.linu',  // Keychain Access Group
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
    aOptions: AndroidOptions(),
  );
  
  final _algorithm = AesGcm.with256bits();
  static const _keyStorageKey = 'e2ee_aes_key';
  
  /// 密钥变更后的回调列表
  final List<OnKeyChanged> _onKeyChangedCallbacks = [];

  /// 身份认证服务
  final _authService = BiometricAuthService();

  KeyManager(this._ref);

  /// 注册密钥变更回调
  void addOnKeyChangedCallback(OnKeyChanged callback) {
    _onKeyChangedCallbacks.add(callback);
  }

  /// 移除密钥变更回调
  void removeOnKeyChangedCallback(OnKeyChanged callback) {
    _onKeyChangedCallbacks.remove(callback);
  }

  /// 触发密钥变更回调
  Future<void> _notifyKeyChanged() async {
    debugPrint('KeyManager: Notifying ${_onKeyChangedCallbacks.length} callbacks about key change');
    for (final callback in _onKeyChangedCallbacks) {
      try {
        await callback();
      } catch (e) {
        debugPrint('KeyManager: Callback error: $e');
      }
    }
  }

  /// 获取当前加密密钥
  Future<SecretKey?> getEncryptionKey() async {
    final keyBase64 = await _storage.read(key: _keyStorageKey);
    if (keyBase64 == null) {
      return null;
    }

    final keyBytes = base64Decode(keyBase64);
    return SecretKey(keyBytes);
  }

  /// 生成新的 AES-256 密钥
  /// 
  /// 需要身份认证
  Future<SecretKey> generateKey({String? authReason}) async {
    // 执行身份认证
    final result = await _authService.authenticateWithError(
      reason: authReason ?? 'Please authenticate to generate a new encryption key',
    );
    if (!result.isSuccess) {
      throw AuthenticationException(
        result.errorType,
        _getErrorMessage(result.errorType),
      );
    }

    final key = await _algorithm.newSecretKey();
    await _saveKey(key);
    await _notifyKeyChanged();
    return key;
  }

  /// 保存密钥到安全存储
  Future<void> _saveKey(SecretKey key) async {
    final keyBytes = await key.extractBytes();
    final keyBase64 = base64Encode(keyBytes);
    await _storage.write(key: _keyStorageKey, value: keyBase64);
    // iOS NSE 通过相同的 Keychain Access Group 直接访问，无需额外同步
  }

  /// 从 Base64 字符串导入密钥
  /// 
  /// 需要身份认证
  Future<void> importKey(String keyBase64, {String? authReason}) async {
    // 执行身份认证
    final result = await _authService.authenticateWithError(
      reason: authReason ?? 'Please authenticate to import encryption key',
    );
    if (!result.isSuccess) {
      throw AuthenticationException(
        result.errorType,
        _getErrorMessage(result.errorType),
      );
    }

    try {
      final keyBytes = base64Decode(keyBase64);
      if (keyBytes.length != 32) {
        throw Exception('Invalid key length: expected 32 bytes, got ${keyBytes.length}');
      }
      
      final key = SecretKey(keyBytes);
      await _saveKey(key);
      await _notifyKeyChanged();
    } catch (e) {
      throw Exception('Failed to import key: $e');
    }
  }

  /// 导出当前密钥为 Base64 字符串
  /// 
  /// 需要身份认证
  Future<String?> exportKey({String? authReason}) async {
    // 执行身份认证
    final result = await _authService.authenticateWithError(
      reason: authReason ?? 'Please authenticate to export encryption key',
    );
    if (!result.isSuccess) {
      // 对于取消操作，返回 null 而不是抛出异常
      if (result.errorType == AuthErrorType.canceled) {
        return null;
      }
      throw AuthenticationException(
        result.errorType,
        _getErrorMessage(result.errorType),
      );
    }

    final key = await getEncryptionKey();
    if (key == null) return null;
    
    final keyBytes = await key.extractBytes();
    return base64Encode(keyBytes);
  }

  /// 删除加密密钥
  /// 
  /// 需要身份认证
  Future<void> deleteKey({String? authReason}) async {
    // 执行身份认证
    final result = await _authService.authenticateWithError(
      reason: authReason ?? 'Please authenticate to delete encryption key',
    );
    if (!result.isSuccess) {
      throw AuthenticationException(
        result.errorType,
        _getErrorMessage(result.errorType),
      );
    }

    await _storage.delete(key: _keyStorageKey);
  }

  /// 获取错误消息（占位符，实际消息在 UI 层根据错误类型显示）
  String _getErrorMessage(AuthErrorType errorType) {
    switch (errorType) {
      case AuthErrorType.noCredentialsSet:
        return 'No credentials set';
      case AuthErrorType.noBiometricsEnrolled:
        return 'No biometrics enrolled';
      case AuthErrorType.notAvailable:
        return 'Authentication not available';
      case AuthErrorType.locked:
        return 'Biometric locked';
      case AuthErrorType.canceled:
        return 'Authentication canceled';
      default:
        return 'Authentication failed';
    }
  }
}
