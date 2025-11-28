import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';

class AppTheme {
  static Color accent = AppColors.authThemeColor;
  static Color lighten(Color color, [double amount = .2]) {
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: accent,
      splashColor: AppColors.screenBackgroundColor,

      colorScheme: ColorScheme.light(
        primary: accent,
        surface: Colors.grey.shade100,
        onSurface: Colors.black87,
      ),
      scaffoldBackgroundColor: AppColors.screenBackgroundColor,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      cardColor: AppColors.whiteColor,
      iconTheme: const IconThemeData(color: Colors.black87),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size.fromHeight(50),
          elevation: 3,
        ),
      ),
      shadowColor: const Color.fromARGB(136, 214, 210, 210),
      hintColor: AppColors.black,
      highlightColor: Colors.grey.shade300,


  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.black,
  ),


    );
  }

  static ThemeData darkTheme(BuildContext context) {
    final softPrimary = lighten(
      Colors.black,
      0.25,
    ); 
    final deepBackground = lighten(Colors.black, 0.05);

    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accent,

      scaffoldBackgroundColor: deepBackground,
      splashColor: softPrimary.withValues(alpha: 0.15),

      colorScheme: ColorScheme.dark(
        primary: Colors.black,
        secondary: softPrimary,
        surface: lighten(Colors.black, 0.1),
        onPrimary: Colors.white,
        onSurface: Colors.white70,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
       fillColor: const Color(0xFF111426),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),

      iconTheme: IconThemeData(color: softPrimary),

      cardColor: lighten(Colors.black, 0.12),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          minimumSize: const Size.fromHeight(50),
          elevation: 0,
        ),
      ),
  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: Colors.white,
  ),
      hintColor: Colors.white60,
      highlightColor: softPrimary.withValues(alpha: 0.2),
      shadowColor: const Color.fromARGB(255, 65, 63, 63).withValues(alpha: 0.4),
    );
  }
}
