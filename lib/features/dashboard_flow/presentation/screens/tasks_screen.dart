import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
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
        backgroundColor: const Color(0xffF5F6FA),
        appBar: CustomAppBar(
          title: "Tasks",
          bottom: TabBar(
            indicatorColor: Colors.deepPurple,
            labelStyle: appTextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            labelColor: AppColors.authThemeColor,
            unselectedLabelColor: AppColors.greyishColor,
            tabs: [
              Tab(text: "All (${prov.total})"),
              Tab(text: "Pending (${prov.pending.length})"),
              Tab(text: "Done (${prov.completed})"),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.deepPurple,
          label: textWidget(text: "Add Task", color: Colors.white),
          icon: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaskEditorScreen()),
            );
          },
        ),
        body: Column(
          children: [
            const SizedBox(height: 14),
            _statsRow(prov),
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
        child: textWidget(text: "No tasks yet", color: Colors.black45),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) => _taskTile(list[i], context),
    );
  }

  Widget _statsRow(TasksProvider prov) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Row(
        children: [
          _statCard(
            "Completion",
            "${prov.completionRate.toStringAsFixed(1)}%",
            Colors.deepPurple,
          ),
          const SizedBox(width: 10),
          _statCard("Week", prov.thisWeek.toString(), Colors.blue),
          const SizedBox(width: 10),
          _statCard("Month", prov.completedThisMonth.toString(), Colors.teal),
          const SizedBox(width: 10),
          _statCard("Overdue", prov.overdue.toString(), Colors.redAccent),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            textWidget(text: title, fontSize: 12, color: Colors.black54),
            const SizedBox(height: 6),
            textWidget(
              text: value,
              fontSize: 18,
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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
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
                        text: t.title,
                        fontWeight: FontWeight.w600,
                        textDecoration: t.completed
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: t.completed ? Colors.grey : Colors.black87,
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
                              ? Colors.red.shade50
                              : t.priority.toUpperCase() == "MEDIUM"
                              ? Colors.orange.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: t.priority.toUpperCase() == "HIGH"
                                ? Colors.red
                                : t.priority.toUpperCase() == "MEDIUM"
                                ? Colors.orange
                                : Colors.green,
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
                                  ? Colors.red
                                  : t.priority.toUpperCase() == "MEDIUM"
                                  ? Colors.orange
                                  : Colors.green,
                            ),
                            const SizedBox(width: 4),
                            textWidget(
                              text: t.priority.toUpperCase(),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: t.priority.toUpperCase() == "HIGH"
                                  ? Colors.red
                                  : t.priority.toUpperCase() == "MEDIUM"
                                  ? Colors.orange
                                  : Colors.green,
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
                          text: t.description,
                          fontSize: 13,
                          color: Colors.black54,
                          maxLine: 2,
                        ),
                      ),
                    if (t.dueDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: textWidget(
                          text: isOverdue
                              ? "Overdue • ${t.dueDate!.toLocal().toString().split(' ').first}"
                              : "Due • ${t.dueDate!.toLocal().toString().split(' ').first}",
                          fontSize: 12,
                          color: isOverdue ? Colors.red : Colors.blueGrey,
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
                          textWidget(text: 'Share'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 6),

                          textWidget(text: 'Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16),
                          SizedBox(width: 6),

                          textWidget(text: 'Delete'),
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
        title: textWidget(text: "Delete Task?"),
        content: textWidget(text: "This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: textWidget(text: "Cancel"),
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
        title: textWidget(text: "Mark as Completed?"),
        content: textWidget(
          text: task.isRecurring
              ? "This is a recurring task. Completing it will generate the next task."
              : "Are you sure you want to mark this task as completed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: textWidget(text: "Cancel"),
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
        border: Border.all(color: Colors.grey, width: 2),
        color: isChecked ? Colors.grey : Colors.transparent,
      ),
      child: isChecked
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
