import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/recurrence_model.dart';
import '../../domain/entities/task_entity.dart';
class TaskModel extends TaskEntity {
  TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.createdAt,
    required super.dueDate,
    required super.completed,
    required super.color,
    required super.attachments,
    required super.priority,
    required super.tags,
    required super.recurrence,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'completed': completed,
      'color': color,
      'attachments': attachments,
      'priority': priority,
      'tags': tags,
      'recurrence': recurrence?.toMap(),
    };
  }

  factory TaskModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TaskModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      completed: data['completed'] ?? false,
      color: data['color'] ?? 0xFFB388FF,
      attachments: List<String>.from(data['attachments'] ?? []),
      priority: data['priority'] ?? 'medium',
      tags: List<String>.from(data['tags'] ?? []),
      recurrence: RecurrenceModel.fromMap(
        data['recurrence'] as Map<String, dynamic>?,
      ),
    );
  }
}
