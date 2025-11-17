import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';

TextStyle appTextStyle({
  required double fontSize,
  bool isBold = false,
  Color? color,
  Color? textDecorationColor,
  FontWeight fontWeight = FontWeight.normal,
  FontStyle fontStyle = FontStyle.normal,
  TextDecoration? textDecoration,
  TextOverflow? textOverflow,
  double height = 0.0,
}) => GoogleFonts.aDLaMDisplay(
  decoration: textDecoration,
  decorationColor: textDecorationColor ?? AppColors.black,
  fontSize: fontSize,
  color: color ?? AppColors.black,
  fontStyle: fontStyle,
  height: height,
  fontWeight: isBold == true ? FontWeight.bold : fontWeight,
);
