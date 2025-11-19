
import 'package:plan_ex_app/features/dashboard_flow/data/database/notes_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/notes_model.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/note_entity.dart';

class NotesRepository {
  final NotesService service;

  NotesRepository(this.service);

  Stream<List<NoteEntity>> getNotes() => service.getNotes();

  Future<void> add(NoteEntity e) =>
      service.addNote(NoteModel(
        id: "",
        title: e.title,
        category: e.category,
        content: e.content,
        attachments: e.attachments,
        createdAt: DateTime.now(),color: e.color, 
      ));

  Future<void> update(NoteEntity e) =>
      service.updateNote(NoteModel(
        id: e.id,
        title: e.title,
        category: e.category,
        content: e.content,
        attachments: e.attachments,
        createdAt: e.createdAt,color: e.color, 
      ));

  Future<void> delete(String id) => service.deleteNote(id);
}
