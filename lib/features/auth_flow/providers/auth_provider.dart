import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:plan_ex_app/features/auth_flow/data/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  // SIGN IN CONTROLLERS
  final signInEmailCtrl = TextEditingController();
  final signInPassCtrl = TextEditingController();

  // SIGN UP CONTROLLERS
  final signUpNameCtrl = TextEditingController();
  final signUpEmailCtrl = TextEditingController();
  final signUpPassCtrl = TextEditingController();
  final signUpConfirmCtrl = TextEditingController();

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

  String? validatePassword(String? v) {
    RegExp regex = RegExp(
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$',
    );
    if (v == null || v.isEmpty) {
      return 'Please enter password';
    } else {
      if (!regex.hasMatch(v)) {
        return 'Weak password"';
      } else {
        return null;
      }
    }
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

  // AUTH CALLS

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

  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<bool> signUp() async {
    _setLoading(true);
    error = await _service.signUp(
      fullName: signUpNameCtrl.text.trim(),
      email: signUpEmailCtrl.text.trim(),
      password: signUpPassCtrl.text,
    );
    _setLoading(false);
    return error == null;
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
    _setLoading(false);
    return error == null;
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
