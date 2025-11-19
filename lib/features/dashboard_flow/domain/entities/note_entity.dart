class NoteEntity {
  final String id;
  final String title;
  final String category;
  final String content;
  final List<String> attachments;
  final DateTime createdAt;

  NoteEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.attachments,
    required this.createdAt,
  });
}
