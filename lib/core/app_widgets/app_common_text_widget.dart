import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';

Widget textWidget({
  required String text,
  required BuildContext context,
  String highLightText = "",
  Color? color,
  Color? textDecorationColor,
  double fontSize = 14,
  Color? highLightColor,
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
          context: context,
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: color ?? Theme.of(context).hintColor,
          height: height,
          fontStyle: fontStyle,
          textDecoration: textDecoration,
          textDecorationColor:
              textDecorationColor ?? Theme.of(context).hintColor,
          textOverflow: textOverflow,
        ),
      )
    : Text(
        text,
        textAlign: alignment,
        maxLines: maxLine,
        style: appTextStyle( context: context,
          fontSize: fontSize,
          fontWeight: fontWeight,
          textDecorationColor:
              textDecorationColor ?? Theme.of(context).hintColor,
          color: color ?? Theme.of(context).hintColor,
          height: height,
          fontStyle: fontStyle,
          textDecoration: textDecoration,
          textOverflow: textOverflow,
        ),
      );
