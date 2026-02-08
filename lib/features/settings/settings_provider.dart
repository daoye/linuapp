import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/db/database.dart';
import 'package:app/db/database_provider.dart';

/// Settings state model
class SettingsState {
  final ThemeMode themeMode;
  final Locale? locale;
  final String? deviceToken;
  /// 用于 webhook 回调的伪装标识符
  final String? webhookToken;
  /// 是否使用真实 device token（默认 false，使用伪装 token）
  final bool useRealToken;

  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.locale,
    this.deviceToken,
    this.webhookToken,
    this.useRealToken = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Locale? locale,
    String? deviceToken,
    String? webhookToken,
    bool? useRealToken,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      locale: locale, // 允许显式设置为 null
      deviceToken: deviceToken ?? this.deviceToken,
      webhookToken: webhookToken ?? this.webhookToken,
      useRealToken: useRealToken ?? this.useRealToken,
    );
  }

  /// 获取用于 webhook 的 token
  /// 如果 useRealToken 为 true，返回真实 device token
  /// 否则返回伪装的 webhook token
  String get effectiveWebhookToken {
    if (useRealToken) {
      return deviceToken ?? '';
    }
    return webhookToken ?? '';
  }
}

/// Settings Notifier
class SettingsNotifier extends Notifier<SettingsState> {
  AppDatabase get _db => ref.read(databaseProvider);

  @override
  SettingsState build() {
    _loadSettings();
    return const SettingsState();
  }

  Future<void> _loadSettings() async {
    final themeStr = await _db.getSetting('theme_mode');
    final localeStr = await _db.getSetting('locale');
    final token = await _db.getSetting('device_token');
    final webhookToken = await _db.getSetting('webhook_token');
    final useRealTokenStr = await _db.getSetting('use_real_token');

    // 如果没有 webhook token，自动生成一个
    String? effectiveWebhookToken = webhookToken;
    if (effectiveWebhookToken == null || effectiveWebhookToken.isEmpty) {
      effectiveWebhookToken = _generateWebhookToken();
      await _db.setSetting('webhook_token', effectiveWebhookToken);
    }

    // 显式创建新状态，确保所有字段都被正确设置
    state = SettingsState(
      themeMode: _parseThemeMode(themeStr),
      locale: _parseLocale(localeStr),
      deviceToken: token,
      webhookToken: effectiveWebhookToken,
      useRealToken: useRealTokenStr == 'true',
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _db.setSetting('theme_mode', mode.name);
    // 显式创建新状态，保持其他字段不变（特别是 locale）
    state = SettingsState(
      themeMode: mode,
      locale: state.locale, // 保持当前 locale 不变
      deviceToken: state.deviceToken,
      webhookToken: state.webhookToken,
      useRealToken: state.useRealToken,
    );
  }

  Future<void> setLocale(Locale? locale) async {
    if (locale == null) {
      await _db.setSetting('locale', '');
      // 显式设置为 null，不使用 copyWith 的默认值逻辑
      state = SettingsState(
        themeMode: state.themeMode,
        locale: null,
        deviceToken: state.deviceToken,
        webhookToken: state.webhookToken,
        useRealToken: state.useRealToken,
      );
    } else {
      await _db.setSetting('locale', locale.languageCode);
      state = state.copyWith(locale: locale);
    }
  }

  Future<void> setDeviceToken(String token) async {
    await _db.setSetting('device_token', token);
    state = state.copyWith(deviceToken: token);
  }

  /// 设置是否使用真实 token
  Future<void> setUseRealToken(bool useReal) async {
    await _db.setSetting('use_real_token', useReal ? 'true' : 'false');
    state = state.copyWith(useRealToken: useReal);
  }

  /// 重置 webhook token（生成新的伪装 token）
  Future<String> resetWebhookToken() async {
    final newToken = _generateWebhookToken();
    await _db.setSetting('webhook_token', newToken);
    state = state.copyWith(webhookToken: newToken);
    return newToken;
  }

  /// 生成伪装的 webhook token
  /// 格式与真实 device token 相同（64 位十六进制字符串）
  String _generateWebhookToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
  }

  ThemeMode _parseThemeMode(String? str) {
    switch (str) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Locale? _parseLocale(String? str) {
    if (str == null || str.isEmpty) return null;
    if (str == 'zh') return const Locale('zh');
    if (str == 'en') return const Locale('en');
    return null;
  }
}

final settingsProvider =
    NotifierProvider<SettingsNotifier, SettingsState>(SettingsNotifier.new);
