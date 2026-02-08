// Linu App Theme
// Design Tokens and ThemeData definitions for light and dark modes

import 'package:flutter/material.dart';

// ============================================================================
// Design Tokens: Colors
// ============================================================================

/// Color Design Tokens for Linu Chat UI
/// Supports both light and dark modes with semantic naming
/// Monochrome (Black & White) theme for minimalist design
class LinuColors {
  LinuColors._();

  // ==========================================================================
  // Light Mode Colors
  // ==========================================================================
  
  // Backgrounds (从浅到深的层次)
  static const lightBackground = Color(0xFFFAFAFA);        // Level 0 - 页面背景
  static const lightChatBackground = Color(0xFFF5F5F5);    // Level 1 - 聊天背景
  static const lightCardSurface = Color(0xFFFFFFFF);       // Level 2 - 卡片表面
  static const lightBottomBarBackground = Color(0xFFFFFFFF);
  static const lightListBackground = Color(0xFFFFFFFF);
  
  // Text (对比度符合 WCAG 标准)
  static const lightPrimaryText = Color(0xFF000000);       // 对比度 21:1 (WCAG AAA)
  static const lightSecondaryText = Color(0xFF525252);     // 对比度约 7.5:1 (WCAG AAA)
  static const lightTertiaryText = Color(0xFF737373);      // 对比度约 4.6:1 (WCAG AA)
  
  // Accent
  static const lightPrimaryAccent = Color(0xFF000000);     // Black as primary accent
  static const lightSelectionAccent = Color(0xFF3B82F6);   // 文本选择高亮与手柄
  
  // Borders & Dividers
  static const lightDivider = Color(0xFFE5E5E5);
  static const lightBorder = Color(0xFFD4D4D4);
  
  // Interactive States
  static const lightHoverBackground = Color(0xFFF0F0F0);
  static const lightPressedBackground = Color(0xFFE5E5E5);
  static const lightSelectedBackground = Color(0xFFE8E8E8);
  
  // Bubble Colors
  static const lightOutgoingBubble = Color(0xFFE5E5E5);
  static const lightIncomingBubble = Color(0xFFFFFFFF);
  static const lightOutgoingBubbleText = Color(0xFF000000);
  static const lightIncomingBubbleText = Color(0xFF000000);

  // ==========================================================================
  // Dark Mode Colors (优化的灰阶层次)
  // ==========================================================================
  
  // Backgrounds (规律的灰阶阶梯)
  static const darkBackground = Color(0xFF000000);         // Level 0 - 纯黑 (OLED 友好)
  static const darkChatBackground = Color(0xFF000000);     // Level 0
  static const darkListBackground = Color(0xFF0A0A0A);     // Level 1
  static const darkCardSurface = Color(0xFF141414);        // Level 2
  static const darkBottomBarBackground = Color(0xFF141414);
  static const darkElevatedSurface = Color(0xFF1F1F1F);    // Level 3 - 浮层/弹窗
  
  // Text (对比度符合 WCAG 标准)
  static const darkPrimaryText = Color(0xFFFFFFFF);        // 对比度 21:1 (WCAG AAA)
  static const darkSecondaryText = Color(0xFFA3A3A3);      // 对比度约 7.4:1 (WCAG AAA)
  static const darkTertiaryText = Color(0xFF737373);       // 对比度约 4.6:1 (WCAG AA)
  
  // Accent
  static const darkPrimaryAccent = Color(0xFFFFFFFF);      // White as primary accent
  static const darkSelectionAccent = Color(0xFF60A5FA);    // 文本选择高亮与手柄
  
  // Borders & Dividers
  static const darkDivider = Color(0xFF262626);
  static const darkBorder = Color(0xFF303030);
  
  // Interactive States
  static const darkHoverBackground = Color(0xFF1F1F1F);
  static const darkPressedBackground = Color(0xFF141414);
  static const darkSelectedBackground = Color(0xFF262626);
  
  // Bubble Colors
  static const darkOutgoingBubble = Color(0xFF262626);
  static const darkIncomingBubble = Color(0xFF141414);
  static const darkOutgoingBubbleText = Color(0xFFFFFFFF);
  static const darkIncomingBubbleText = Color(0xFFFFFFFF);

  // ==========================================================================
  // Semantic Colors (状态指示，两种模式通用)
  // ==========================================================================
  
  // Success - 成功/完成
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFFDCFCE7);           // 浅色模式背景
  static const successDark = Color(0xFF166534);            // 深色模式背景
  
  // Warning - 警告/注意
  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);
  static const warningDark = Color(0xFF854D0E);
  
  // Error - 错误/危险
  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);
  static const errorDark = Color(0xFF991B1B);
  
  // Info - 信息/提示
  static const info = Color(0xFF3B82F6);
  static const infoLight = Color(0xFFDBEAFE);
  static const infoDark = Color(0xFF1E40AF);

  // ==========================================================================
  // Utility Colors
  // ==========================================================================
  
  // Toast
  static const toastLightBackground = Color(0xFF171717);
  static const toastDarkBackground = Color(0xFFF5F5F5);
  
  // Unread Indicator
  static const unreadIndicator = Color(0xFF22C55E);        // 使用 success 色
  
  // Focus Ring
  static const lightFocusRing = Color(0x33000000);         // 20% black
  static const darkFocusRing = Color(0x33FFFFFF);          // 20% white
}

// ============================================================================
// Design Tokens: Typography
// ============================================================================

/// Text Style Design Tokens for Linu Chat UI
/// Defines semantic text styles with proper hierarchy
class LinuTextStyles {
  LinuTextStyles._();

  // Headline - Page titles
  static const headline = TextStyle(
    fontSize: 20,
    height: 1.4, // 28sp line height
    fontWeight: FontWeight.w600,
  );

  // Title - List item titles
  static const title = TextStyle(
    fontSize: 16,
    height: 1.375, // 22sp line height
    fontWeight: FontWeight.w500,
  );

  // Body - Main content
  static const body = TextStyle(
    fontSize: 15,
    height: 1.333, // 20sp line height
    fontWeight: FontWeight.w400,
  );

  // Caption - Auxiliary text
  static const caption = TextStyle(
    fontSize: 13,
    height: 1.385, // 18sp line height
    fontWeight: FontWeight.w400,
  );

  // Label - Buttons and tags
  static const label = TextStyle(
    fontSize: 14,
    height: 1.429, // 20sp line height
    fontWeight: FontWeight.w500,
  );

  // Overline - Small badges
  static const overline = TextStyle(
    fontSize: 12,
    height: 1.333, // 16sp line height
    fontWeight: FontWeight.w500,
  );
}

// ============================================================================
// Design Tokens: Spacing
// ============================================================================

/// Spacing Design Tokens for Linu Chat UI
/// 4dp-based spacing scale
class LinuSpacing {
  LinuSpacing._();

  static const double zero = 0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

// ============================================================================
// Design Tokens: Border Radius
// ============================================================================

/// Border Radius Design Tokens for Linu Chat UI
class LinuRadius {
  LinuRadius._();

  static const double small = 4.0;
  static const double medium = 8.0;
  static const double large = 12.0;
  static const double xlarge = 16.0;
}

// ============================================================================
// Theme Data
// ============================================================================

/// Linu App Theme
/// Provides light and dark theme configurations
class LinuTheme {
  LinuTheme._();

  /// Light Theme
  static ThemeData get light {
    final colorScheme = ColorScheme.light(
      primary: LinuColors.lightPrimaryAccent,
      onPrimary: LinuColors.lightCardSurface,
      error: LinuColors.error,
      onError: LinuColors.lightCardSurface,
      surface: LinuColors.lightCardSurface,
      onSurface: LinuColors.lightPrimaryText,
      surfaceContainerHighest: LinuColors.lightChatBackground,
      outline: LinuColors.lightDivider,
      outlineVariant: LinuColors.lightBorder,
      tertiary: LinuColors.lightPrimaryAccent,
      onTertiary: LinuColors.lightCardSurface,
      secondary: LinuColors.lightPrimaryAccent,
      onSecondary: LinuColors.lightCardSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: LinuColors.lightChatBackground,
      
      // Text Theme
      textTheme: TextTheme(
        headlineSmall: LinuTextStyles.headline.copyWith(color: LinuColors.lightPrimaryText),
        titleMedium: LinuTextStyles.title.copyWith(color: LinuColors.lightPrimaryText),
        bodyMedium: LinuTextStyles.body.copyWith(color: LinuColors.lightPrimaryText),
        bodySmall: LinuTextStyles.caption.copyWith(color: LinuColors.lightSecondaryText),
        labelLarge: LinuTextStyles.label.copyWith(color: LinuColors.lightPrimaryText),
        labelSmall: LinuTextStyles.overline.copyWith(color: LinuColors.lightTertiaryText),
        bodyLarge: LinuTextStyles.body.copyWith(color: LinuColors.lightPrimaryText),
        titleLarge: LinuTextStyles.title.copyWith(color: LinuColors.lightPrimaryText),
        titleSmall: LinuTextStyles.caption.copyWith(color: LinuColors.lightPrimaryText),
        displayLarge: LinuTextStyles.headline.copyWith(color: LinuColors.lightPrimaryText),
        displayMedium: LinuTextStyles.headline.copyWith(color: LinuColors.lightPrimaryText),
        displaySmall: LinuTextStyles.headline.copyWith(color: LinuColors.lightPrimaryText),
        headlineLarge: LinuTextStyles.headline.copyWith(color: LinuColors.lightPrimaryText),
        headlineMedium: LinuTextStyles.headline.copyWith(color: LinuColors.lightPrimaryText),
        labelMedium: LinuTextStyles.label.copyWith(color: LinuColors.lightPrimaryText),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: LinuColors.lightDivider,
        thickness: 1,
        space: 0,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: LinuColors.lightCardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LinuRadius.medium),
        ),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: LinuColors.lightListBackground,
        foregroundColor: LinuColors.lightPrimaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: LinuTextStyles.headline.copyWith(color: LinuColors.lightPrimaryText),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LinuColors.lightCardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LinuRadius.medium),
          borderSide: BorderSide(color: LinuColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LinuRadius.medium),
          borderSide: BorderSide(color: LinuColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LinuRadius.medium),
          borderSide: BorderSide(color: LinuColors.lightPrimaryAccent, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: LinuSpacing.md,
          vertical: LinuSpacing.md,
        ),
      ),
      
      // Text Button Theme - 确保链接和文本按钮使用主题颜色而非默认蓝色
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LinuColors.lightPrimaryAccent,
        ),
      ),
      
      // Text Selection Theme - 文本选择颜色
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: LinuColors.lightSelectionAccent.withValues(alpha: 0.5),
        cursorColor: LinuColors.lightPrimaryText,
        selectionHandleColor: LinuColors.lightSelectionAccent,
      ),
    );
  }

  /// Dark Theme
  static ThemeData get dark {
    final colorScheme = ColorScheme.dark(
      primary: LinuColors.darkPrimaryAccent,
      onPrimary: LinuColors.darkCardSurface,
      error: LinuColors.error,
      onError: LinuColors.darkCardSurface,
      surface: LinuColors.darkCardSurface,
      onSurface: LinuColors.darkPrimaryText,
      surfaceContainerHighest: LinuColors.darkChatBackground,
      outline: LinuColors.darkDivider,
      outlineVariant: LinuColors.darkBorder,
      tertiary: LinuColors.darkPrimaryAccent,
      onTertiary: LinuColors.darkCardSurface,
      secondary: LinuColors.darkPrimaryAccent,
      onSecondary: LinuColors.darkCardSurface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: LinuColors.darkChatBackground,
      
      // Text Theme
      textTheme: TextTheme(
        headlineSmall: LinuTextStyles.headline.copyWith(color: LinuColors.darkPrimaryText),
        titleMedium: LinuTextStyles.title.copyWith(color: LinuColors.darkPrimaryText),
        bodyMedium: LinuTextStyles.body.copyWith(color: LinuColors.darkPrimaryText),
        bodySmall: LinuTextStyles.caption.copyWith(color: LinuColors.darkSecondaryText),
        labelLarge: LinuTextStyles.label.copyWith(color: LinuColors.darkPrimaryText),
        labelSmall: LinuTextStyles.overline.copyWith(color: LinuColors.darkTertiaryText),
        bodyLarge: LinuTextStyles.body.copyWith(color: LinuColors.darkPrimaryText),
        titleLarge: LinuTextStyles.title.copyWith(color: LinuColors.darkPrimaryText),
        titleSmall: LinuTextStyles.caption.copyWith(color: LinuColors.darkPrimaryText),
        displayLarge: LinuTextStyles.headline.copyWith(color: LinuColors.darkPrimaryText),
        displayMedium: LinuTextStyles.headline.copyWith(color: LinuColors.darkPrimaryText),
        displaySmall: LinuTextStyles.headline.copyWith(color: LinuColors.darkPrimaryText),
        headlineLarge: LinuTextStyles.headline.copyWith(color: LinuColors.darkPrimaryText),
        headlineMedium: LinuTextStyles.headline.copyWith(color: LinuColors.darkPrimaryText),
        labelMedium: LinuTextStyles.label.copyWith(color: LinuColors.darkPrimaryText),
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: LinuColors.darkDivider,
        thickness: 1,
        space: 0,
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: LinuColors.darkCardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(LinuRadius.medium),
        ),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: LinuColors.darkListBackground,
        foregroundColor: LinuColors.darkPrimaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: LinuTextStyles.headline.copyWith(color: LinuColors.darkPrimaryText),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LinuColors.darkCardSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LinuRadius.medium),
          borderSide: BorderSide(color: LinuColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LinuRadius.medium),
          borderSide: BorderSide(color: LinuColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(LinuRadius.medium),
          borderSide: BorderSide(color: LinuColors.darkPrimaryAccent, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: LinuSpacing.md,
          vertical: LinuSpacing.md,
        ),
      ),
      
      // Text Button Theme - 确保链接和文本按钮使用主题颜色而非默认蓝色
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LinuColors.darkPrimaryAccent,
        ),
      ),
      
      // Text Selection Theme - 文本选择颜色
      textSelectionTheme: TextSelectionThemeData(
        selectionColor: LinuColors.darkSelectionAccent.withValues(alpha: 0.5),
        cursorColor: LinuColors.darkPrimaryText,
        selectionHandleColor: LinuColors.darkSelectionAccent,
      ),
    );
  }
}
