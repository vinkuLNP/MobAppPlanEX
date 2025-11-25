import 'package:firebase_auth/firebase_auth.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/database/notes_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/notes_model.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/account_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/note_entity.dart';

class NotesRepository {
  final NotesService service;
  final AccountRepository accountRepository;
  NotesRepository(this.service, this.accountRepository);

  Stream<List<NoteEntity>> getNotes() => service.getNotes();

  Future<void> add(NoteEntity e) async {
    final totalNotes = service.addNote(
      NoteModel(
        id: "",
        title: e.title,
        category: e.category,
        content: e.content,
        attachments: e.attachments,
        createdAt: DateTime.now(),
        color: e.color,
      ),
    );
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await accountRepository.updateStats(uid, {'totalNotes': totalNotes});
  }

  Future<void> update(NoteEntity e) => service.updateNote(
    NoteModel(
      id: e.id,
      title: e.title,
      category: e.category,
      content: e.content,
      attachments: e.attachments,
      createdAt: e.createdAt,
      color: e.color,
    ),
  );

  Future<void> delete(String id) async {
    final totalNotes = await service.deleteNote(id);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await accountRepository.updateStats(uid, {'totalNotes': totalNotes});
  }
}
