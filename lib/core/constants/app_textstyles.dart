import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';

class AppTextStyles {
  // LIGHT THEME
  static TextStyle headline1 = appTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static TextStyle headline2 = appTextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );

  static TextStyle bodyText = appTextStyle(fontSize: 14, color: Colors.black54);

  // DARK THEME
  static TextStyle headlineDark1 = headline1.copyWith(color: Colors.white);

  static TextStyle headlineDark2 = headline2.copyWith(color: Colors.white);

  static TextStyle bodyTextDark = bodyText.copyWith(color: Colors.white70);
}
