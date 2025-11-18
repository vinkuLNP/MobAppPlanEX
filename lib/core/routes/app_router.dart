import 'package:flutter/material.dart';
import 'package:plan_ex_app/features/auth_flow/presentation/forgot_password_screen.dart';
import 'package:plan_ex_app/features/auth_flow/presentation/sign_in_screen.dart';
import 'package:plan_ex_app/features/auth_flow/presentation/sign_up_screen.dart';
import 'package:plan_ex_app/features/auth_flow/presentation/verify_email_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/home_screen.dart';
import 'package:plan_ex_app/features/onboarding_flow/presentation/splash_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (context) => const SplashPage(),
    AppRoutes.login: (context) => const SignInScreen(),
    AppRoutes.signup: (context) => const SignUpScreen(),
    AppRoutes.forgot: (context) => const ForgotPasswordScreen(),
    AppRoutes.verifyEmail: (context) => const EmailVerificationScreen(),

    AppRoutes.home: (context) => const HomeScreen(),
  };
}




