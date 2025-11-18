import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_theme.dart';
import 'package:plan_ex_app/core/routes/app_router.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/features/auth_flow/data/auth_service.dart';
import 'package:plan_ex_app/features/auth_flow/providers/auth_provider.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/database/notes_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/notes_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/notes_provider.dart';
import 'package:plan_ex_app/features/theme_settings/provider/theme_provider.dart';
import 'package:plan_ex_app/firebase_options.dart';
import 'package:provider/provider.dart';

final AuthService authService = AuthService();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAppCheck.instance.activate(
    // providerAndroid: AndroidDebugProvider(),
    // providerApple:AppleDebugProvider(),
    //       androidProvider: AndroidProvider.debug,
    // appleProvider: AppleProvider.debug,

    // 0aad6f12-c6b7-4f2d-b0b4-c16f64554902
    // androidProvider: AndroidProvider.debug,
    // appleProvider: AppleProvider.debug,
    //aff7534e-b36e-4b4e-b0fd-1417863076e6
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => NotesProvider(NotesRepository(NotesService())),
        ),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.currentTheme,
      initialRoute: AppRoutes.splash,
      routes: AppRouter.routes,
    );
  }
}
