import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppUtils {
  /// 检查用户是否偏好减少动画
  static bool prefersReducedMotion(BuildContext context) {
    return MediaQuery.of(context).disableAnimations;
  }
  /// 格式化日期时间，所有时间都显示具体时分
  /// 
  /// - 今天: 14:30
  /// - 昨天: 昨天 14:30
  /// - 一周内: 周二 14:30
  /// - 更早: 11/27 14:30 或 2024/11/27 14:30（跨年）
  /// 
  /// [locale] 用于本地化星期、日期格式，传入 `Localizations.localeOf(context).toString()`
  static String formatDateTime(
    DateTime dateTime, {
    String yesterday = 'Yesterday',
    String? locale,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final dayDifference = today.difference(targetDay).inDays;
    
    // 时间部分（本地化格式）
    final time = DateFormat.Hm(locale).format(dateTime);

    if (dayDifference == 0) {
      // 今天: 只显示时间
      return time;
    } else if (dayDifference == 1) {
      // 昨天: 昨天 + 时间
      return '$yesterday $time';
    } else if (dayDifference < 7) {
      // 一周内: 星期 + 时间（本地化）
      final weekday = DateFormat.E(locale).format(dateTime);
      return '$weekday $time';
    } else if (dateTime.year == now.year) {
      // 今年: 月/日 + 时间
      final date = DateFormat.Md(locale).format(dateTime);
      return '$date $time';
    } else {
      // 跨年: 年/月/日 + 时间
      final date = DateFormat.yMd(locale).format(dateTime);
      return '$date $time';
    }
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
