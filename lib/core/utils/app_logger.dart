import 'dart:developer';

class AppLogger {
  static logString(String message) {
    log("📌 LOG: $message");
  }

  static error(String message) {
    log("❌ ERROR: $message");
  }
}
