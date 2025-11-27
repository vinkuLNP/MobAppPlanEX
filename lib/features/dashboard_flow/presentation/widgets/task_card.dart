import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/task_view_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/task_provider.dart';
import '../../domain/entities/task_entity.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<TasksProvider>(context, listen: false);
    final dueText = task.dueDate == null
        ? 'No due'
        : _formatDate(task.dueDate!);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Checkbox(
          value: task.completed,
          onChanged: (v) => prov.toggleComplete(task, v ?? false),
        ),
        title: textWidget(context: context,
        
        text: task.title, fontWeight: FontWeight.w600),
        subtitle: textWidget(context: context,
        
        text: '$dueText • ${task.priority}'),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => TaskViewScreen(task: task)),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
