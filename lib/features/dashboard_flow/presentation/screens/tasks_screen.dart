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
        backgroundColor: AppColors.whiteColor,
        appBar: CustomAppBar(
          title: "Tasks",
          bottom: TabBar(
            indicatorColor: Colors.deepPurple,
            indicatorWeight: 3,
            labelStyle: appTextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: "All (${prov.total})"),
              Tab(text: "Pending (${prov.pending.length})"),
              Tab(text: "Done (${prov.completed})"),
            ],

            labelColor: AppColors.authThemeColor,
            unselectedLabelColor: AppColors.greyishColor,
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          label: textWidget(text: "New Task", color: AppColors.backgroundColor),
          elevation: 4,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TaskEditorScreen()),
            );
          },
          icon: const Icon(Icons.add, size: 28),
        ),

        body: Column(
          children: [
            const SizedBox(height: 12),
            _statsRow(prov),
            const SizedBox(height: 12),

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
          text: "No tasks yet",
          color: Colors.black45,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      itemBuilder: (_, i) => _taskTile(list[i], context),
    );
  }

  Widget _statsRow(TasksProvider prov) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
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
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha:  0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textWidget(text: title, fontSize: 12, color: Colors.black54),

            const Spacer(),
            textWidget(
              text: value,
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
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

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskEditorScreen(editing: t)),
          );
        },
        child: Column(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Color(t.color),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Color(t.color).withValues(alpha: 0.12),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: t.completed,
                      onChanged: (t.completed
                          ? null
                          : (v) {
                              _confirmCompletion(context, t);
                            }),
                      activeColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        textWidget(
                          text: t.completed ? t.title : t.title,

                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: t.completed ? Colors.grey : Colors.black87,
                          textDecoration: t.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),

                        const SizedBox(height: 6),

                        if (t.description.isNotEmpty)
                          textWidget(
                            text: t.description,
                            maxLine: 2,
                            textOverflow: TextOverflow.ellipsis,

                            fontSize: 13,
                            color: t.completed ? Colors.grey : Colors.black54,
                            height: 1.3,
                          ),
                        if (t.dueDate != null)
                          Container(
                            margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: t.completed
                                  ? Colors.grey.withValues(alpha:  0.12)
                                  : (isOverdue
                                        ? Colors.red.withValues(alpha:  0.12)
                                        : Colors.blue.withValues(alpha:  0.10)),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: textWidget(
                              text: isOverdue
                                  ? "Overdue • ${t.dueDate!.toLocal().toString().split(" ").first}"
                                  : "Due • ${t.dueDate!.toLocal().toString().split(" ").first}",

                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isOverdue
                                  ? Colors.red
                                  : (t.completed
                                        ? Colors.grey
                                        : Colors.blue.shade700),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _circleButton(
                        Icons.share,
                        Colors.deepPurple,
                        () => _shareTask(t),
                      ),
                      const SizedBox(height: 8),
                      _circleButton(
                        Icons.delete,
                        Colors.red,
                        () => _confirmDelete(context, t),
                      ),
                      const SizedBox(height: 8),
                      _circleButton(Icons.edit, Colors.grey.shade600, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskEditorScreen(editing: t),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha:  0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  void _shareTask(TaskEntity task) {
    final text =
        """
Task: ${task.title}
Description: ${task.description.isEmpty ? "-" : task.description}
Due Date: ${task.dueDate?.toString().split(" ").first ?? "-"}
Status: ${task.completed ? "Completed" : "Pending"}
""";
    Share.share(text);
  }

  void _confirmDelete(BuildContext context, TaskEntity task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: textWidget(text: "Delete Task?"),
        content: textWidget(text: "This action cannot be undone."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
}
