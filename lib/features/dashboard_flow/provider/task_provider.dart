import 'dart:async';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/task_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/task_entity.dart';

class TasksProvider extends ChangeNotifier {
  final TasksRepository _repo = TasksRepository();

  List<TaskEntity> tasks = [];
  StreamSubscription? _sub;
  bool loading = true;

  TasksProvider() {
    _listen();
  }

  void _listen() {
    _sub = _repo.getTasks().listen((list) {
      tasks = list;
      loading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> addTask(TaskEntity t) => _repo.add(t);

  Future<void> updateTask(TaskEntity t) => _repo.update(t);

  Future<void> deleteTask(String id) => _repo.delete(id);

  Future<void> toggleComplete(TaskEntity task, bool val) => _repo.toggleComplete(task, val);

  int get total => tasks.length;

  int get overdue {
    final now = DateTime.now();
    return tasks.where((t) => t.dueDate != null && !t.completed && t.dueDate!.isBefore(now)).length;
  }

  int get today {
    final now = DateTime.now();
    return tasks.where((t) {
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year && t.dueDate!.month == now.month && t.dueDate!.day == now.day;
    }).length;
  }
Future<void> completeTask(TaskEntity task, bool val) async {
  await _repo.toggleComplete(task, val);
}


  int get completed => tasks.where((t) => t.completed).length;

  List<TaskEntity> get pending => tasks.where((t) => !t.completed).toList();
double get completionRate {
  if (tasks.isEmpty) return 0;
  return (completed / tasks.length) * 100;
}

int get completedThisMonth {
  final now = DateTime.now();
  return tasks.where(
    (t) =>
        t.completed &&
        t.dueDate != null &&
        t.dueDate!.year == now.year &&
        t.dueDate!.month == now.month,
  ).length;
}
int get thisWeek {
  final now = DateTime.now();

  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

  final endOfWeek = startOfWeek.add(const Duration(days: 6));

  return tasks.where((t) {
    if (!t.completed || t.dueDate == null) return false;

    final d = t.dueDate!;
    return d.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
           d.isBefore(endOfWeek.add(const Duration(days: 1)));
  }).length;
}

}
