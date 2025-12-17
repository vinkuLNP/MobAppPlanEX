import 'package:firebase_auth/firebase_auth.dart';
import 'package:plan_ex_app/core/notifications/notification_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/database/task_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/account_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/recurrence_entity.dart';
import '../../domain/entities/task_entity.dart';
import '../models/task_model.dart';

class TasksRepository {
  final TaskService _service = TaskService();
  final AccountRepository accountRepository;
  TasksRepository(this.accountRepository);
  Stream<List<TaskEntity>> getTasks() => _service.watchTasks();
  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> add(TaskEntity t) async {
    final stats = await _service.addTask(
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

    getTaskReminder(t);

    await accountRepository.updateStats(uid, stats);
  }

  Future<void> update(TaskEntity t) async {
    _service.updateTask(
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
    getTaskReminder(t);
  }

  Future<void> delete(String id) async {
    final stats = await _service.deleteTask(id);
    await accountRepository.updateStats(uid, stats);
  }

  Future<void> toggleComplete(TaskEntity task, bool value) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

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

    final stats = await _service.updateTaskStats(uid);
    await accountRepository.updateStats(uid, stats);
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

  Future<void> getTaskReminder(TaskEntity t) async {
    if (t.dueDate != null) {
      final user = await accountRepository.getUser(uid);

      if (user.taskReminders == true) {
        final allowed = await NotificationService.requestPermissionIfNeeded();
        if (!allowed) return;

        final reminderTime = t.dueDate!.subtract(const Duration(minutes: 30));
        final finalTime = reminderTime.isAfter(DateTime.now())
            ? reminderTime
            : DateTime.now().add(const Duration(seconds: 2));

        await NotificationService.scheduleTaskReminder(
          t.title,
          t.createdAt.toString(),
          finalTime,
        );
      }

      if (user.overdueAlerts && t.dueDate != null) {
        await NotificationService.scheduleOverdueAlertForTask(
          t.id,
          t.title,
          t.dueDate!,
        );
      }
    }
  }
}
