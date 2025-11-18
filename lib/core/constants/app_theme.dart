import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_textstyles.dart';

class AppTheme {
  static Color accent = Colors.purple.shade400;

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: accent,
    colorScheme: ColorScheme.fromSeed(seedColor: accent),
    scaffoldBackgroundColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
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
      bodySmall: AppTextStyles.bodyText,
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
      bodySmall: AppTextStyles.bodyTextDark,
    ),
  );
}