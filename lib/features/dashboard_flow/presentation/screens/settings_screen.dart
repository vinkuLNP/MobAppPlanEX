import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/pro_switch_tile.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/account_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).loadSettingsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountProvider>(
      builder: (context, provider, _) {
        final user = provider.user;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (provider.settingsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

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
                      textWidget(
                        text: 'Appearance',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 10),
                      ProSwitchTile(
                        title: 'Dark Mode',
                        description:
                            'Toggle between light and dark themes (Pro feature)',
                        value: user.darkMode,
                        isPremium: true,
                        onChanged: (v) => provider.toggleSetting('darkMode', v),
                        onUpgradeTap: () {},
                      ),

                      ProSwitchTile(
                        title: 'Show Creation Dates',
                        description:
                            'Display when notes and tasks were created (Pro feature)',
                        value: user.showCreationDates,
                        isPremium: provider.isPremium,
                        onChanged: (v) =>
                            provider.toggleSetting('showCreationDates', v),
                        onUpgradeTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      textWidget(
                        text: 'Notifications',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 10),
                      ProSwitchTile(
                        title: 'Daily Summary',
                        description:
                            'Receive daily task summary notifications (Pro feature)',
                        value: user.dailySummary,
                        isPremium: provider.isPremium,
                        onChanged: (v) =>
                            provider.toggleSetting('dailySummary', v),
                        onUpgradeTap: () {},
                      ),

                      ProSwitchTile(
                        title: 'Task Reminders',
                        description:
                            'Get notified about upcoming task due dates (Pro feature)',
                        value: user.taskReminders,
                        isPremium: provider.isPremium,
                        onChanged: (v) =>
                            provider.toggleSetting('taskReminders', v),
                        onUpgradeTap: () {},
                      ),
                      ProSwitchTile(
                        title: 'Overdue Alerts',
                        description:
                            'Daily alerts for overdue tasks until completed (Pro feature)',
                        value: user.overdueAlerts,
                        isPremium: provider.isPremium,
                        onChanged: (v) =>
                            provider.toggleSetting('overdueAlerts', v),
                        onUpgradeTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _card(
                  child: ProSwitchTile(
                    title: 'Auto Save',
                    description:
                        'Automatically save changes as you type (Pro feature)',
                    value: user.autoSave,
                    isPremium: provider.isPremium,
                    onChanged: (v) => provider.toggleSetting('autoSave', v),
                    onUpgradeTap: () {},
                  ),
                ),
                const SizedBox(height: 20),

                _card(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: textWidget(text: 'Logout'),
                    onTap: () => provider.logout(context),
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
          textWidget(
            text: value.toString(),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textWidget(text: title),
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

