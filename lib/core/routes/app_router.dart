import 'package:flutter/material.dart';
import 'package:plan_ex_app/features/onboarding_flow/presentation/splash_screen.dart';
import 'app_routes.dart';

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    AppRoutes.splash: (context) => const SplashPage(),
  };
}
