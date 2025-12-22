import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_widgets.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/task_entity.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/custom_appbar.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/task_editor_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TasksProvider>(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Tasks",
          showBack: false,
          bottom: TabBar(
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
            indicatorColor: AppColors.authThemeColor,
            labelStyle: appTextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              context: context,
            ),
            labelColor: AppColors.authThemeColor,
            tabs: [
              Tab(text: "All (${prov.total})"),
              Tab(text: "Pending (${prov.pending.length})"),
              Tab(text: "Done (${prov.completed})"),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.authThemeColor,
          label: textWidget(
            context: context,
            text: "Add Task",
            color: Colors.white,
          ),
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            if (!prov.isPro && prov.tasks.length >= 5) {
              showUpgradeDialog(
                context,
                'Free users can create only 5 tasks. Upgrade to Pro for unlimited tasks, attachments and tags.',
              );
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaskEditorScreen()),
            );
          },
        ),
        body: Column(
          children: [
            const SizedBox(height: 14),
            _statsRow(prov, context),
            const SizedBox(height: 10),
            Expanded(
              child: prov.loading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      children: [
                        _taskList(prov.tasks, context),
                        _taskList(prov.pending, context),
                        _taskList(
                          prov.tasks.where((e) => e.completed).toList(),
                          context,
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskList(List<TaskEntity> list, BuildContext context) {
    if (list.isEmpty) {
      return Center(
        child: textWidget(
          context: context,
          text: "No tasks yet",
          color: Theme.of(context).hintColor,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        return Column(
          children: [
            _taskTile(list[i], context),
            i >= list.length - 1 ? SizedBox(height: 80) : SizedBox(),
          ],
        );
      },
    );
  }

  Widget _statsRow(TasksProvider prov, BuildContext context) {
    final isSmallWidth = MediaQuery.of(context).size.width < 360;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: isSmallWidth
          ? Column(
              children: [
                Row(
                  children: [
                    _statCard(
                      "Done",
                      "${prov.completionRate.toStringAsFixed(1)}%",
                      AppColors.authThemeColor,
                      context,
                    ),
                    const SizedBox(width: 8),
                    _statCard(
                      "Week",
                      prov.thisWeek.toString(),
                      Colors.blue,
                      context,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _statCard(
                      "Month",
                      prov.completedThisMonth.toString(),
                      Colors.teal,
                      context,
                    ),
                    const SizedBox(width: 8),
                    _statCard(
                      "Overdue",
                      prov.overdue.toString(),
                      Colors.redAccent,
                      context,
                    ),
                  ],
                ),
              ],
            )
          : Row(
              children: [
                _statCard(
                  "Done %",
                  "${prov.completionRate.toStringAsFixed(1)}%",
                  AppColors.authThemeColor,
                  context,
                ),
                const SizedBox(width: 10),
                _statCard(
                  "Week",
                  prov.thisWeek.toString(),
                  Colors.blue,
                  context,
                ),
                const SizedBox(width: 10),
                _statCard(
                  "Month",
                  prov.completedThisMonth.toString(),
                  Colors.teal,
                  context,
                ),
                const SizedBox(width: 10),
                _statCard(
                  "Overdue",
                  prov.overdue.toString(),
                  Colors.redAccent,
                  context,
                ),
              ],
            ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    Color color,
    BuildContext context,
  ) {
    final isSmallWidth = MediaQuery.of(context).size.width < 360;

    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: isSmallWidth ? 10 : 14,
          horizontal: 6,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).cardColor,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textWidget(
              context: context,
              text: title,
              fontSize: isSmallWidth ? 11 : 12,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(height: 4),
            textWidget(
              context: context,
              text: value,
              fontSize: isSmallWidth ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ],
        ),
      ),
    );
  }

  Widget _taskTile(TaskEntity t, BuildContext context) {
    final isOverdue =
        t.dueDate != null &&
        !t.completed &&
        t.dueDate!.isBefore(DateTime.now());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final createdAt = DateFormat.yMMMd().add_jm().format(t.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskEditorScreen(editing: t, viewOnly: true),
            ),
          );
        },

        child: Row(
          children: [
            Expanded(
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                leading: GestureDetector(
                  onTap: t.completed
                      ? null
                      : () => _confirmCompletion(context, t),
                  child: _circleCheckbox(t.completed),
                ),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: textWidget(
                        context: context,
                        text: t.title,
                        maxLine: 2,
                        textOverflow: TextOverflow.ellipsis,
                        fontWeight: FontWeight.w600,
                        textDecoration: t.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: t.completed
                            ? Colors.grey
                            : Theme.of(context).hintColor,
                      ),
                    ),
                    if (t.priority.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: t.priority.toUpperCase() == "HIGH"
                              ? (isDark
                                    ? Colors.red.shade100
                                    : Colors.red.shade50)
                              : t.priority.toUpperCase() == "MEDIUM"
                              ? (isDark
                                    ? Colors.orange.shade100
                                    : Colors.orange.shade50)
                              : (isDark
                                    ? Colors.green.shade100
                                    : Colors.green.shade50),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: t.priority.toUpperCase() == "HIGH"
                                ? (isDark ? Colors.red.shade50 : Colors.red)
                                : t.priority.toUpperCase() == "MEDIUM"
                                ? (isDark
                                      ? Colors.orange.shade50
                                      : Colors.orange)
                                : (isDark
                                      ? Colors.green.shade50
                                      : Colors.green),

                            width: 0.7,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.flag,
                              size: 12,
                              color: t.priority.toUpperCase() == "HIGH"
                                  ? (isDark ? Colors.red : Colors.red)
                                  : t.priority.toUpperCase() == "MEDIUM"
                                  ? (isDark ? Colors.orange : Colors.orange)
                                  : (isDark ? Colors.green : Colors.green),
                            ),
                            const SizedBox(width: 4),
                            textWidget(
                              context: context,
                              text: t.priority.toUpperCase(),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: t.priority.toUpperCase() == "HIGH"
                                  ? (isDark ? Colors.black : Colors.red)
                                  : t.priority.toUpperCase() == "MEDIUM"
                                  ? (isDark ? Colors.black : Colors.orange)
                                  : (isDark ? Colors.black : Colors.green),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (t.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: textWidget(
                          context: context,
                          text: t.description,
                          fontSize: 13,
                          color: Theme.of(
                            context,
                          ).hintColor.withValues(alpha: 0.6),
                          maxLine: 2,
                        ),
                      ),
                    if (t.dueDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: textWidget(
                          context: context,
                          text: isOverdue
                              ? "Overdue • ${t.dueDate!.toLocal().toString().split(' ').first}"
                              : "Due • ${t.dueDate!.toLocal().toString().split(' ').first}",
                          fontSize: 12,
                          color: isOverdue ? Colors.red : Colors.blueGrey,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: buildCreationDateWidget(
                        context,
                        date: createdAt,
                        showLabel: true,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'share') _shareTask(t);
                    if (value == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskEditorScreen(editing: t),
                        ),
                      );
                    }
                    if (value == 'delete') _confirmDelete(context, t);
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share, size: 16),
                          SizedBox(width: 6),
                          textWidget(context: context, text: 'Share'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 6),

                          textWidget(context: context, text: 'Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16),
                          SizedBox(width: 6),

                          textWidget(context: context, text: 'Delete'),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(Icons.more_vert),
                ),
              ),
            ),
            Container(
              width: 5,
              height: 60,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Color(t.color),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareTask(TaskEntity task) {
    final text =
        """
        Task: ${task.title}
        Description: ${task.description.isEmpty ? "-" : task.description}
        Due Date: ${task.dueDate?.toString().split(' ').first ?? "-"}
        Status: ${task.completed ? "Completed" : "Pending"}
        """;
    SharePlus.instance.share(ShareParams(text: text));
  }

  void _confirmDelete(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: textWidget(context: context, text: "Delete Task?"),
        content: textWidget(
          context: context,
          text: "This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: textWidget(context: context, text: "Cancel"),
          ),
          AppButton(
            text: "Delete",
            onTap: () {
              Navigator.pop(ctx);
              Provider.of<TasksProvider>(
                context,
                listen: false,
              ).deleteTask(task.id);
            },
          ),
        ],
      ),
    );
  }

  void _confirmCompletion(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: textWidget(context: context, text: "Mark as Completed?"),
        content: textWidget(
          context: context,
          text: task.isRecurring
              ? "This is a recurring task. Completing it will generate the next task."
              : "Are you sure you want to mark this task as completed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: textWidget(context: context, text: "Cancel"),
          ),
          AppButton(
            text: "Confirm",
            onTap: () {
              Navigator.pop(ctx);
              Provider.of<TasksProvider>(
                context,
                listen: false,
              ).completeTask(task, true);
            },
          ),
        ],
      ),
    );
  }

  Widget _circleCheckbox(bool isChecked) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isChecked ? Colors.grey : Colors.green,
          width: 2,
        ),
        color: isChecked ? Colors.grey : Colors.green,
      ),
      child: const Icon(Icons.check, size: 16, color: Colors.white),
    );
  }
}
