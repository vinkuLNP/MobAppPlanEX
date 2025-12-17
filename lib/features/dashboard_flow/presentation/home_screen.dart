import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/notifications/notification_streams.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/screens/account_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/screens/notes_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/screens/settings_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/screens/tasks_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/custom_appbar.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/account_provider.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/notes_provider.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/task_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'screen': NotesScreen(), 'appBar': CustomAppBar(title: "Notes")},
    {'screen': const TasksScreen()},
    {
      'screen': const AccountScreen(),
      'appBar': const CustomAppBar(title: "Account"),
    },
    {
      'screen': const SettingsScreen(),
      'appBar': const CustomAppBar(title: "Settings"),
    },
  ];
  @override
  void initState() {
    super.initState();
    homeScreenTaskTabStream.stream.listen((tabIndex) {
      setState(() {
        _currentIndex = tabIndex;
      });
    });
    Future.microtask(() async {
      if (mounted) {
        final tasksProvider = context.read<TasksProvider>();
        final accountProvider = context.read<AccountProvider>();

        final notesProvider = context.read<NotesProvider>();

        await accountProvider.loadAccountBasicInfo();
        notesProvider.listenNotes();
        tasksProvider.listen();
        if (mounted)  await accountProvider.enforceNotificationPermissionOnHome(context: context);
        await accountProvider.bootstrapNotifications(tasksProvider.tasks);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: _tabs[_currentIndex]['appBar'],
          body: _tabs[_currentIndex]['screen'],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.note_alt),
                label: 'Notes',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_box),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.account_circle),
                label: 'Account',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: 'Settings',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.authThemeColor,
            showUnselectedLabels: true,
            showSelectedLabels: true,
            elevation: 10,
          ),
        ),
      ),
    );
  }
}
