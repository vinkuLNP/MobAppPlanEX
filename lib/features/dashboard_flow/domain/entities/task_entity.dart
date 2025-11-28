import 'package:plan_ex_app/features/dashboard_flow/domain/entities/recurrence_entity.dart';

class TaskEntity {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? dueDate;
  final bool completed;
  final int color;
  final List<String> attachments;
  final String priority;
  final List<String> tags;
  final RecurrenceEntity? recurrence;
   bool get isRecurring {
    if (recurrence == null) return false;
    if (recurrence!.interval == 0) return false;
    if (recurrence!.unit == RecurrenceUnit.none) return false;
    return true;
  }
  bool get isOverdue {
  if (completed) return false;
  if (dueDate == null) return false;
  return dueDate!.isBefore(DateTime.now());
}

  TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.dueDate,
    required this.completed,
    required this.color,
    required this.attachments,
    required this.priority,
    required this.tags,
    required this.recurrence,
  });
}
