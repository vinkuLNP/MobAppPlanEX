import 'package:flutter/material.dart';
import 'app_routes.dart';

void authFlowNavigate(BuildContext context, String targetRoute) {
  Navigator.pushNamedAndRemoveUntil(
    context,
    targetRoute,
    (route) =>
        route.settings.name == AppRoutes.login &&
        targetRoute != AppRoutes.login,
  );
}
