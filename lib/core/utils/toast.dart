import 'dart:ui';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static void showSuccess(String msg) =>
      Fluttertoast.showToast(msg: msg, backgroundColor: const Color(0xFF4CAF50));

  static void showError(String msg) =>
      Fluttertoast.showToast(msg: msg, backgroundColor: const Color(0xFFF44336));
}
