import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plan_ex_app/core/constants/app_theme.dart';
import 'package:plan_ex_app/core/routes/app_router.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/features/auth_flow/data/auth_service.dart';
import 'package:plan_ex_app/features/auth_flow/providers/auth_provider.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/database/account_local_datasource.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/database/account_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/database/notes_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/account_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/notes_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/account_provider.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/notes_provider.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/task_provider.dart';
import 'package:plan_ex_app/features/theme_settings/provider/theme_provider.dart';
import 'package:plan_ex_app/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final AuthService authService = AuthService();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_KEY']!,
  );
  final prefs = await SharedPreferences.getInstance();
  final accountLocal = AccountLocalDataSource(prefs);
  final accountService = AccountService();
  final accountRepository = AccountRepository(accountService, accountLocal);

  runApp(
    MultiProvider(
      providers: [
        Provider<AccountRepository>.value(value: accountRepository),

        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(accountRepository: accountRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => AccountProvider(accountRepository),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              NotesProvider(NotesRepository(NotesService(), accountRepository)),
        ),

        ChangeNotifierProvider(create: (_) => TasksProvider()),
      ],

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
       return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: accountProvider.themeMode,
          initialRoute: AppRoutes.splash,
          routes: AppRouter.routes,
        );
      }, );
  }
}
