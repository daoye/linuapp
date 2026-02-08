import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';

/// 身份认证错误类型
enum AuthErrorType {
  none,
  noCredentialsSet,
  noBiometricsEnrolled,
  notAvailable,
  locked,
  canceled,
  unknown,
}

/// 身份认证结果
class AuthResult {
  final bool success;
  final AuthErrorType errorType;

  AuthResult.success() : success = true, errorType = AuthErrorType.none;
  AuthResult.failure(this.errorType) : success = false;

  bool get isSuccess => success;
  bool get isFailure => !success;
}

/// 生物识别认证服务
/// 
/// 提供系统身份认证功能（Face ID、指纹、设备密码）
/// 支持认证缓存机制，在指定时间窗口内免认证
class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  DateTime? _lastAuthTime;
  static const Duration _authCacheDuration = Duration(minutes: 5);

  /// 检查设备是否支持生物识别
  Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('BiometricAuthService: Error checking availability: $e');
      return false;
    }
  }

  /// 获取可用的生物识别类型
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('BiometricAuthService: Error getting biometrics: $e');
      return [];
    }
  }

  /// 执行身份认证
  /// 
  /// [reason] 认证原因说明，会显示在系统认证对话框中
  /// 返回 true 表示认证成功，false 表示认证失败或取消
  Future<bool> authenticate({String? reason}) async {
    final result = await authenticateWithError(reason: reason);
    return result.isSuccess;
  }

  /// 执行身份认证（返回详细错误信息）
  /// 
  /// [reason] 认证原因说明，会显示在系统认证对话框中
  /// 返回 [AuthResult] 包含认证结果和错误类型
  Future<AuthResult> authenticateWithError({String? reason}) async {
    // 检查缓存
    if (_isAuthCached()) {
      debugPrint('BiometricAuthService: Using cached authentication');
      return AuthResult.success();
    }

    // 检查设备是否支持
    final isSupported = await isAvailable();
    if (!isSupported) {
      debugPrint('BiometricAuthService: Device does not support authentication');
      return AuthResult.failure(AuthErrorType.notAvailable);
    }

    // 执行认证
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason ??
            'Please authenticate to access encryption key',
        // 3.0.0 API: 使用直接参数替代 AuthenticationOptions
        biometricOnly: false, // 允许使用设备密码作为后备
        persistAcrossBackgrounding: true, // 保持认证对话框在前台（应用切换到后台时保持认证状态）
      );

      if (didAuthenticate) {
        _lastAuthTime = DateTime.now();
        debugPrint('BiometricAuthService: Authentication successful');
        return AuthResult.success();
      }
      debugPrint('BiometricAuthService: Authentication failed or cancelled');
      return AuthResult.failure(AuthErrorType.canceled);
    } on LocalAuthException catch (e) {
      // 3.0.0 API: 现在抛出 LocalAuthException 而不是 PlatformException
      debugPrint('BiometricAuthService: LocalAuthException: ${e.code}');
      // 处理特定错误
      switch (e.code) {
        case LocalAuthExceptionCode.noBiometricHardware:
        case LocalAuthExceptionCode.uiUnavailable:
          debugPrint('BiometricAuthService: Device does not support authentication');
          return AuthResult.failure(AuthErrorType.notAvailable);
        case LocalAuthExceptionCode.noBiometricsEnrolled:
          debugPrint('BiometricAuthService: No biometrics enrolled');
          return AuthResult.failure(AuthErrorType.noBiometricsEnrolled);
        case LocalAuthExceptionCode.noCredentialsSet:
          debugPrint('BiometricAuthService: No credentials set on device. Treating as authenticated.');
          // 如果设备没有设置任何安全验证，认为验证通过
          _lastAuthTime = DateTime.now();
          return AuthResult.success();
        case LocalAuthExceptionCode.temporaryLockout:
        case LocalAuthExceptionCode.biometricLockout:
          debugPrint('BiometricAuthService: Biometric temporarily locked');
          return AuthResult.failure(AuthErrorType.locked);
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
          debugPrint('BiometricAuthService: Authentication canceled');
          return AuthResult.failure(AuthErrorType.canceled);
        default:
          debugPrint('BiometricAuthService: Unknown error: ${e.code}');
          return AuthResult.failure(AuthErrorType.unknown);
      }
    } catch (e) {
      debugPrint('BiometricAuthService: Authentication error: $e');
      return AuthResult.failure(AuthErrorType.unknown);
    }
  }

  /// 清除认证缓存
  /// 
  /// 强制下次操作需要重新认证
  void clearAuthCache() {
    _lastAuthTime = null;
    debugPrint('BiometricAuthService: Auth cache cleared');
  }

  /// 检查认证是否在缓存有效期内
  bool _isAuthCached() {
    if (_lastAuthTime == null) return false;
    final difference = DateTime.now().difference(_lastAuthTime!);
    return difference < _authCacheDuration;
  }

  /// 检查认证缓存是否有效（公开方法）
  bool isAuthCached() {
    return _isAuthCached();
  }
}
