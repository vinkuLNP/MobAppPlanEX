
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/note_entity.dart';

class NoteModel extends NoteEntity {
  NoteModel({
    required super.id,
    required super.title,
    required super.category,
    required super.content,
    required super.attachments,
    required super.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "category": category,
      "content": content,
      "attachments": attachments,
      "createdAt": createdAt.toIso8601String(),
    };
  }

  factory NoteModel.fromMap(String id, Map<String, dynamic> map) {
    return NoteModel(
      id: id,
      title: map["title"],
      category: map["category"],
      content: map["content"],
      attachments: List<String>.from(map["attachments"] ?? []),
      createdAt: DateTime.parse(map["createdAt"]),
    );
  }
}
