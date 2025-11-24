import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/notes_model.dart';

class NotesService {
  final _db = FirebaseFirestore.instance.collection("notes");

  Future<void> addNote(NoteModel model) => _db.add(model.toMap());

  Future<void> updateNote(NoteModel model) =>
      _db.doc(model.id).update(model.toMap());

  Future<void> deleteNote(String id) => _db.doc(id).delete();

  Stream<List<NoteModel>> getNotes() {
    return _db
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => NoteModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }
}
