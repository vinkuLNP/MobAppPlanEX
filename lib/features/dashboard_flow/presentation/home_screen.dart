import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/screens/account_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/screens/notes_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/screens/settings_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/screens/tasks_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/custom_appbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {
      'screen': NotesScreen(),
      'appBar': CustomAppBar(
        title: "Notes",
      ),
    },
    {
      'screen': const TasksScreen(),
    },
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
  Widget build(BuildContext context) {
    return DefaultTabController(
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
            BottomNavigationBarItem(icon: Icon(Icons.note_alt), label: 'Notes'),
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
          unselectedItemColor: AppColors.greyishColor,
          backgroundColor: AppColors.whiteColor,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          elevation: 10,
        ),
      ),
    );
  }
}
