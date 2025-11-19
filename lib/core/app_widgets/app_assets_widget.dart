import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

Widget imageAsset({
  required String image,
  double width = 50,
  double height = 50,
  BoxFit boxFit = BoxFit.contain,
  Color? color,
}) =>
    Image.asset(image, width: width, height: height, color: color, fit: boxFit);

Widget imageFile({
  required File file,
  double width = 50,
  double height = 50,
  BoxFit boxFit = BoxFit.contain,
  Color? color,
}) => Image.file(file, width: width, height: height, color: color, fit: boxFit);

Widget svgAsset({
  required String image,
  double width = 50,
  double height = 50,
  BoxFit boxFit = BoxFit.none,
  Color? color,
}) => SvgPicture.asset(
  image,
  width: width,
  height: height,
  // colorFilter: ColorFilter.mode(color!, BlendMode.srcIn),
  fit: boxFit,
);

Widget fileImage({
  required File file,
  double width = 50,
  double height = 50,
  BoxFit boxFit = BoxFit.contain,
  Color? color,
}) => Image.file(file, width: width, height: height, color: color, fit: boxFit);
