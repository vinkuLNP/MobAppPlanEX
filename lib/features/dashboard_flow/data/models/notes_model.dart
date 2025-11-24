import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  NoteModel({
    required super.id,
    required super.title,
    required super.category,
    required super.content,
    required super.attachments,
    required super.createdAt,
    required super.color,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "category": category,
      "content": content,
      "attachments": attachments,
      "createdAt": Timestamp.fromDate(createdAt),
      "color": color,
    };
  }

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      title: map["title"],
      category: map["category"],
      content: map["content"],
      attachments: List<String>.from(map["attachments"] ?? []),
      createdAt: (map["createdAt"] as Timestamp).toDate(),
      color: map["color"] ?? AppColors.authThemeColor,
    );
  }
}
