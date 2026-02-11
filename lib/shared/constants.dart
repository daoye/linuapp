// 应用全局常量
// 
// 包含动画时长、主题配置等共享常量

class ApiConstants {
  static const String baseUrl = 'https://api.linu.aprilzz.com';
  static const String pushPath = '/v1/push';
  static const String docsUrl = 'https://linu.aprilzz.com/docs';
}

class AnimationDurations {
  /// 快速动画 - 用于标准的入场/出场效果
  static const Duration fast = Duration(milliseconds: 120);
  
  /// 中等动画 - 用于强调效果（符合 Apple HIG 的 200-300ms 范围）
  static const Duration medium = Duration(milliseconds: 200);
  
  /// 慢速动画 - 用于复杂过渡
  static const Duration slow = Duration(milliseconds: 300);
  
  /// 标准入场动画 - 用于页面元素入场
  static const Duration standard = Duration(milliseconds: 400);
  
  /// 较长动画 - 用于复杂页面过渡
  static const Duration long = Duration(milliseconds: 500);
  
  /// 超长动画 - 用于循环动画
  static const Duration extraLong = Duration(milliseconds: 2000);
  
  /// Shimmer 动画 - 用于持续的加载效果
  static const Duration shimmer = Duration(milliseconds: 800);
  
  /// 延迟常量 - 用于动画序列
  static const Duration delayShort = Duration(milliseconds: 80);
  static const Duration delayMedium = Duration(milliseconds: 100);
  static const Duration delayStandard = Duration(milliseconds: 150);
  static const Duration delayLong = Duration(milliseconds: 200);
  static const Duration delayExtraLong = Duration(milliseconds: 250);
  static const Duration delaySequence = Duration(milliseconds: 300);
  static const Duration delaySequence2 = Duration(milliseconds: 400);
  static const Duration delaySequence3 = Duration(milliseconds: 500);
  static const Duration delaySequence4 = Duration(milliseconds: 600);
  static const Duration delaySequence5 = Duration(milliseconds: 700);
  static const Duration delaySequence6 = Duration(milliseconds: 800);
}

