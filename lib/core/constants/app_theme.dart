import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/constants/app_textstyles.dart';

class AppTheme {
  static Color accent = AppColors.authThemeColor;

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: accent,
    // colorScheme: ColorScheme.fromSeed(seedColor: accent),
    colorScheme: ColorScheme.light(
    primary: accent,
    // background: Colors.white,
    surface: Colors.grey.shade100,
    onSurface: Colors.black87,
    // onBackground: Colors.black87,
  ),
    scaffoldBackgroundColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    cardColor: AppColors.lightGrey.withValues(alpha: 0.7),
      iconTheme: const IconThemeData(color: Colors.black87),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(50),
        elevation: 3,
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: AppTextStyles.headline1,
      headlineSmall: AppTextStyles.headline2,
      bodySmall: AppTextStyles.bodyText.copyWith(color: Colors.black87),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: accent,
    
    scaffoldBackgroundColor: const Color(0xFF0B1020),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF111426),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
    cardColor: AppColors.premiumColor,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        minimumSize: const Size.fromHeight(50),
        elevation: 0,
      ),
    ),
    textTheme: TextTheme(
      headlineMedium: AppTextStyles.headlineDark1,
      headlineSmall: AppTextStyles.headlineDark2,
      bodySmall: AppTextStyles.bodyTextDark.copyWith(color: Colors.white),

    ),
  );
}
