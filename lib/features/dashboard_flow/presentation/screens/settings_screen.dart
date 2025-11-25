import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/account_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        final user = provider.user!;

        return Scaffold(
          backgroundColor: AppColors.screenBackgroundColor,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _card(
                  child: Row(
                    children: [
                      _statBox('Notes', user.totalNotes),
                      _statBox('Tasks', user.totalTasks),
                      _statBox('Completed', user.completedTasks),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Appearance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Dark Mode'),
                        value: user.darkMode,
                        onChanged: (v) => provider.toggleSetting('darkMode', v),
                      ),
                      SwitchListTile(
                        title: const Text('Show Creation Dates'),
                        value: user.showCreationDates,
                        onChanged: (v) =>
                            provider.toggleSetting('showCreationDates', v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SwitchListTile(
                        title: const Text('Daily Summary'),
                        value: user.dailySummary,
                        onChanged: (v) =>
                            provider.toggleSetting('dailySummary', v),
                      ),
                      SwitchListTile(
                        title: const Text('Task Reminders'),
                        value: user.taskReminders,
                        onChanged: (v) =>
                            provider.toggleSetting('taskReminders', v),
                      ),
                      SwitchListTile(
                        title: const Text('Overdue Alerts'),
                        value: user.overdueAlerts,
                        onChanged: (v) =>
                            provider.toggleSetting('overdueAlerts', v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _card(
                  child: SwitchListTile(
                    title: const Text('Auto Save'),
                    value: user.autoSave,
                    onChanged: (v) => provider.toggleSetting('autoSave', v),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statBox(String title, int value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(title),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}
