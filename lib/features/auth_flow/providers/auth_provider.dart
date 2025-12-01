import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:plan_ex_app/features/auth_flow/data/auth_service.dart';

class AuthUserProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  AuthUserProvider();
  final signInEmailCtrl = TextEditingController();
  final signInPassCtrl = TextEditingController();

  final signUpNameCtrl = TextEditingController();
  final signUpEmailCtrl = TextEditingController();
  final signUpPassCtrl = TextEditingController();
  final signUpConfirmCtrl = TextEditingController();
  bool resetLinkSent = false;

  bool autoValidate = false;
  bool isLoading = false;
  bool signInObscure = true;
  bool signUpObscure = true;
  bool signUpConfirmObscure = true;
  String? error;

  void toggleSignInObscure() {
    signInObscure = !signInObscure;
    notifyListeners();
  }

  void toggleSignUpObscure() {
    signUpObscure = !signUpObscure;
    notifyListeners();
  }

  void toggleSignUpConfirmObscure() {
    signUpConfirmObscure = !signUpConfirmObscure;
    notifyListeners();
  }

  void enableAutoValidate() {
    AppLogger.logString('-----------enable------->');
    autoValidate = true;
    notifyListeners();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  String? validateEmail(String? v) {
    AppLogger.logString('------------------>$v');
    if (v == null || v.trim().isEmpty) return "Email is required";

    final reg = RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!reg.hasMatch(v.trim())) return "Enter a valid email";

    return null;
  }

  String? validateSignINPassword(String? v) {
    if (v == null || v.trim().isEmpty) {
      return "Password is required";
    }
    return null;
  }

  String? validatePassword(String? v) {
    if (v == null || v.isEmpty) {
      return 'Please enter password';
    }

    if (v.length < 6) {
      return "Password must be at least 6 characters";
    }
    if (!RegExp(r'[A-Z]').hasMatch(v)) {
      return "Add at least 1 uppercase letter";
    }
    if (!RegExp(r'[a-z]').hasMatch(v)) {
      return "Add at least 1 lowercase letter";
    }
    if (!RegExp(r'[0-9]').hasMatch(v)) {
      return "Add at least 1 number";
    }
    if (!RegExp(r'[!@#\$&*~]').hasMatch(v)) {
      return "Add at least 1 special character (!@#\$&*~)";
    }

    return null;
  }

  String? validateConfirm(String? v) {
    if (v == null || v.isEmpty) return "Confirm password required";
    if (v != signUpPassCtrl.text) return "Passwords do not match";
    return null;
  }

  void _setLoading(bool v) {
    isLoading = v;
    notifyListeners();
  }

  Future<String> signIn() async {
    _setLoading(true);

    final result = await _service.signIn(
      email: signInEmailCtrl.text.trim(),
      password: signInPassCtrl.text,
    );

    _setLoading(false);

    if (result == null) {
      return "verified";
    }

    if (result == "unverified") {
      return "unverified";
    }

    error = result;
    return "error";
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();

    super.dispose();
  }

  void clearControllers() {
    signInEmailCtrl.clear();
    signInPassCtrl.clear();
    error = null;
    signUpNameCtrl.clear();
    signUpEmailCtrl.clear();
    signUpPassCtrl.clear();
    signUpConfirmCtrl.clear();
    signInObscure = true;
    signUpObscure = true;
    signUpConfirmObscure = true;
    notifyListeners();
  }

  Future<String?> signUp() async {
    _setLoading(true);
    final result = await _service.signUp(
      fullName: signUpNameCtrl.text.trim(),
      email: signUpEmailCtrl.text.trim(),
      password: signUpPassCtrl.text,
    );
    if (result == "unverified-existing") {
      error = "You are not verified yet.";
    } else if (result == "already-verified") {
      error = "You are already verified user. Kindly proceed with Login.";
    } else {
      error = result;
    }
    _setLoading(false);
    return error;
  }

  int cooldown = 0;
  Timer? _cooldownTimer;
  DateTime? _cooldownEnd;
  void startCooldown() {
    _cooldownEnd = DateTime.now().add(const Duration(seconds: 30));
    cooldown = 30;
    notifyListeners();

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = _cooldownEnd!.difference(DateTime.now()).inSeconds;

      if (remaining <= 0) {
        cooldown = 0;
        timer.cancel();
      } else {
        cooldown = remaining;
      }
      notifyListeners();
    });
  }

  void restoreCooldown() {
    if (_cooldownEnd == null) return;

    final remaining = _cooldownEnd!.difference(DateTime.now()).inSeconds;
    if (remaining > 0) {
      cooldown = remaining;
      startCooldown();
    }
  }

  Future<bool> sendVerification() async {
    _setLoading(true);
    error = await _service.sendEmailVerification();
    _setLoading(false);
    return error == null;
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    error = await _service.resetPassword(email);
    if (error == null) {
      resetLinkSent = true;
    } else {
      resetLinkSent = false;
    }
    _setLoading(false);
    notifyListeners();
    return error == null;
  }

  void clearResetState() {
    resetLinkSent = false;
    error = null;
    notifyListeners();
  }

  Future<bool> checkEmailVerified() async {
    _setLoading(true);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      error = "No user logged in.";
      _setLoading(false);
      return false;
    }

    await user.reload();
    final refreshedUser = FirebaseAuth.instance.currentUser;

    final isVerified = refreshedUser?.emailVerified ?? false;

    if (isVerified) {
      error = null;
      _setLoading(false);
      return true;
    }

    error = "Email not verified yet";
    _setLoading(false);
    return false;
  }

  Future<String> googleSignIn() async {
    _setLoading(true);

    final result = await _service.signInWithGoogle();

    _setLoading(false);

    if (result == null) return "success";

    if (result == "cancelled") return "cancelled";

    if (result.toLowerCase().contains('cancelled')) return 'cancelled';

    error = result;
    notifyListeners();
    return error!;
  }

  Future<String> appleSignIn() async {
    _setLoading(true);

    final result = await _service.signInWithApple();

    _setLoading(false);

    if (result == null) return "success";

    if (result == "cancelled") return "cancelled";

    error = result;
    notifyListeners();
    return error!;
  }
}
