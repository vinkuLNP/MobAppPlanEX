import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_theme.dart';
import 'package:plan_ex_app/core/routes/app_router.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/features/auth_flow/data/auth_service.dart';
import 'package:plan_ex_app/features/auth_flow/providers/auth_provider.dart';
import 'package:plan_ex_app/features/theme_settings/provider/theme_provider.dart';
import 'package:plan_ex_app/firebase_options.dart';
import 'package:provider/provider.dart';
final AuthService authService = AuthService();
void main() async{
    WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(providers: [
       ChangeNotifierProvider(
      create: (_) => ThemeProvider(),),
       ChangeNotifierProvider(create: (_) => AuthProvider()),
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