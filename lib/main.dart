import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plan_ex_app/core/constants/app_theme.dart';
import 'package:plan_ex_app/core/notifications/notification_service.dart';
import 'package:plan_ex_app/core/routes/app_router.dart';
import 'package:plan_ex_app/core/routes/app_routes.dart';
import 'package:plan_ex_app/features/auth_flow/data/auth_service.dart';
import 'package:plan_ex_app/features/auth_flow/providers/auth_provider.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/database/account_local_datasource.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/database/account_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/database/notes_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/account_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/notes_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/task_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/account_provider.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/notes_provider.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/task_provider.dart';
import 'package:plan_ex_app/firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest_all.dart' as tz;

final AuthService authService = AuthService();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
   tz.initializeTimeZones();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await NotificationService.init();
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

        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => AccountProvider(accountRepository),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              NotesProvider(NotesRepository(NotesService(), accountRepository)),
        ),

        ChangeNotifierProvider(
          create: (_) => TasksProvider(TasksRepository(accountRepository)),
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
    return Consumer<AccountProvider>(
      builder: (context, accountProvider, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(context),
          darkTheme: AppTheme.darkTheme(context),
          themeMode: accountProvider.themeMode,
          initialRoute: AppRoutes.splash,
          routes: AppRouter.routes,
        );
      },
    );
  }
}
