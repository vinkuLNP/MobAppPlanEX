import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

TextStyle appTextStyle({
  required double fontSize,
  required BuildContext context,
  bool isBold = false,
  Color? color,
  Color? textDecorationColor,
  FontWeight fontWeight = FontWeight.normal,
  FontStyle fontStyle = FontStyle.normal,
  TextDecoration? textDecoration,
  TextOverflow? textOverflow,
  double height = 0.0,
}) => GoogleFonts.poppins(
  decoration: textDecoration,
  decorationColor: textDecorationColor ?? Theme.of(context).hintColor,
  fontSize: fontSize,
  color: color ?? Theme.of(context).hintColor,
  fontStyle: fontStyle,
  height: height,
  fontWeight: isBold == true ? FontWeight.bold : fontWeight,
);
