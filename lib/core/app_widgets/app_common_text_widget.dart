import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';

Widget textWidget({
  required String text,
  String highLightText = "",
  Color color = AppColors.black,
  Color textDecorationColor= AppColors.black,

  double fontSize = 14,
  Color highLightColor = AppColors.black,
  TextAlign alignment = TextAlign.start,
  int? maxLine,
  TextDecoration? textDecoration,
  bool isHighLighted = false,
  TextOverflow? textOverflow,
  FontWeight fontWeight = FontWeight.normal,
  FontStyle fontStyle = FontStyle.normal,
  double height = 1.5,
}) => isHighLighted
    ? Text(
        text,
        textAlign: alignment,
        maxLines: maxLine,
        style: appTextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color,
          height: height,
          fontStyle: fontStyle,
          textDecoration: textDecoration,
          textDecorationColor:textDecorationColor ,
          textOverflow: textOverflow,
        ),
      )
    : Text(
        text,
        textAlign: alignment,
        maxLines: maxLine,
        style: appTextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          textDecorationColor:textDecorationColor ,
          color: color,
          height: height,
          fontStyle: fontStyle,
          textDecoration: textDecoration,
          textOverflow: textOverflow,
        ),
      );