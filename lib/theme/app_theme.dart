import 'package:flutter/material.dart';

class AppColors {
  // 主色调
  static const primary = Color(0xFFFFB5C2);       // 樱花粉
  static const primaryLight = Color(0xFFFFE4EC);   // 浅粉
  static const primaryDark = Color(0xFFFF7F8E);    // 珊瑚粉

  // 辅助色
  static const lavender = Color(0xFFC9B1FF);       // 薰衣草紫
  static const mint = Color(0xFFA8E6CF);           // 薄荷绿
  static const cream = Color(0xFFFFE4A0);          // 奶黄
  static const sky = Color(0xFF87CEEB);            // 天空蓝

  // 背景色
  static const background = Color(0xFFFFF8F0);     // 米白
  static const card = Color(0xFFFFFFFF);           // 纯白
  static const cardAlt = Color(0xFFFFF5F5);        // 淡粉白

  // 文字色
  static const textPrimary = Color(0xFF4A3728);    // 深棕
  static const textBody = Color(0xFF333333);       // 深灰
  static const textSecondary = Color(0xFF999999);  // 浅灰
  static const textHint = Color(0xFFCCAAAA);       // 浅粉灰

  // 分隔线
  static const divider = Color(0xFFF5F0EB);        // 极浅灰
}

class AppTheme {
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.lavender,
      surface: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.card,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        fontFamily: 'NotoSansSC',
      ),
      iconTheme: IconThemeData(color: AppColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: AppColors.textHint),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Color(0xFFCCCCCC),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
