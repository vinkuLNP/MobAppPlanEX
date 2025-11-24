import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';

class ColorsUtil {
  static final List<Color> palette = [
    AppColors.authThemeColor,
    Colors.redAccent,
    Colors.orangeAccent,
    Colors.yellowAccent,
    Colors.greenAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.pinkAccent,
    Colors.tealAccent,
  ];

  static Color randomDefault() {
    // palette.shuffle();
    // return palette.first;
    return AppColors.authThemeColor;
  }
}