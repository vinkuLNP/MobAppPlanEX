import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
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
                        context: context,
                        text: 'Appearance',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 10),
                      ProSwitchTile(
                        title: 'Dark Mode',
                        description: 'Toggle between light and dark themes',
                        value: user.darkMode,
                        isPremium: true,
                        onChanged: (v) =>
                            provider.toggleSetting('darkMode', v, context),
                        onUpgradeTap: () {},
                      ),

                      ProSwitchTile(
                        title: 'Show Creation Dates',
                        description:
                            'Display when notes and tasks were created',
                        value: user.showCreationDates,
                        isPremium: provider.isPremium,
                        onChanged: (v) => provider.toggleSetting(
                          'showCreationDates',
                          v,
                          context,
                        ),
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
                        context: context,
                        text: 'Notifications',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 10),
                      ProSwitchTile(
                        title: 'Daily Summary',
                        description: 'Receive daily task summary notifications',
                        value: user.dailySummary,
                        isPremium: provider.isPremium,
                        onChanged: (v) =>
                            provider.toggleSetting('dailySummary', v, context),
                        onUpgradeTap: () {},
                      ),

                      ProSwitchTile(
                        title: 'Task Reminders',
                        description:
                            'Get notified about upcoming task due dates',
                        value: user.taskReminders,
                        isPremium: provider.isPremium,
                        onChanged: (v) =>
                            provider.toggleSetting('taskReminders', v, context),
                        onUpgradeTap: () {},
                      ),
                      ProSwitchTile(
                        title: 'Overdue Alerts',
                        description:
                            'Daily alerts for overdue tasks until completed',
                        value: user.overdueAlerts,
                        isPremium: provider.isPremium,
                        onChanged: (v) =>
                            provider.toggleSetting('overdueAlerts', v, context),
                        onUpgradeTap: () {},
                      ),
                    ],
                  ),
                ),
             const SizedBox(height: 20),

                _card(
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: textWidget(context: context, text: 'Logout'),
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
            context: context,
            text: value.toString(),
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).hintColor,
          ),
          const SizedBox(height: 6),
          textWidget(
            context: context,
            color: Theme.of(context).hintColor,
            text: title,
            fontSize: 13,
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,

        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).cardColor.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

    /* const SizedBox(height: 20),
                _card(
                  child: ProSwitchTile(
                    title: 'Auto Save',
                    description:
                        'Automatically save changes as you type',
                    value: user.autoSave,
                    isPremium: provider.isPremium,
                    onChanged: (v) => provider.toggleSetting('autoSave', v,context),
                    onUpgradeTap: () {},
                  ),
                ),*/
               