import 'package:plan_ex_app/features/dashboard_flow/data/database/task_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/recurrence_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

class TasksRepository {
  final TaskService _service = TaskService();

  Stream<List<TaskEntity>> getTasks() => _service.watchTasks();

  Future<void> add(TaskEntity t) => _service.addTask(
    TaskModel(
      id: '',
      title: t.title,
      description: t.description,
      createdAt: t.createdAt,
      dueDate: t.dueDate,
      completed: t.completed,
      color: t.color,
      attachments: t.attachments,
      priority: t.priority,
      tags: t.tags,
      recurrence: t.recurrence,
    ),
  );

  Future<void> update(TaskEntity t) => _service.updateTask(
    TaskModel(
      id: t.id,
      title: t.title,
      description: t.description,
      createdAt: t.createdAt,
      dueDate: t.dueDate,
      completed: t.completed,
      color: t.color,
      attachments: t.attachments,
      priority: t.priority,
      tags: t.tags,
      recurrence: t.recurrence,
    ),
  );

  Future<void> delete(String id) => _service.deleteTask(id);

  Future<void> toggleComplete(TaskEntity task, bool value) async {
    await _service.toggleComplete(task.id, value);

    if (value == true && task.recurrence != null) {
      final nextDate = _getNextRecurringDate(task);
      if (nextDate != null) {
        await add(
          TaskEntity(
            
            id: '',
            title: task.title,
            description: task.description,
            createdAt: DateTime.now(),
            dueDate: nextDate,
            completed: false,
            color: task.color,
            attachments: task.attachments,
            priority: task.priority,
            tags: task.tags,
            recurrence: task.recurrence,
          ),
        );
      }
    }
  }

  DateTime? _getNextRecurringDate(TaskEntity t) {
    if (t.dueDate == null) return null;
    switch (t.recurrence!.unit) {
      case RecurrenceUnit.days:
        return t.dueDate!.add(Duration(days: t.recurrence!.interval));

      case RecurrenceUnit.weeks:
        return t.dueDate!.add(Duration(days: 7 * t.recurrence!.interval));

      case RecurrenceUnit.months:
        return DateTime(
          t.dueDate!.year,
          t.dueDate!.month + t.recurrence!.interval,
          t.dueDate!.day,
        );

      default:
        return null;
    }
  }
}
