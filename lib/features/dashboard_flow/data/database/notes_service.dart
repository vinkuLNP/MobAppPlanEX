import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/notes_model.dart';

class NotesService {
  CollectionReference<Map<String, dynamic>> _col() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("notes");
  }

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) {
    return FirebaseFirestore.instance.collection("users").doc(uid);
  }

  Future<int> addNote(NoteModel model) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _col().add(model.toMap());

    return await _updateNoteCount(uid);
  }

  Future<void> updateNote(NoteModel model) =>
      _col().doc(model.id).update(model.toMap());

  Future<int> deleteNote(String id) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await _col().doc(id).delete();

    return await _updateNoteCount(uid);
  }

  Stream<List<NoteModel>> getNotes() {
    return _col()
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((d) => NoteModel.fromMap(d.id, d.data()))
              .toList(),
        );
  }

  Future<int> _updateNoteCount(String uid) async {
    final snap = await _col().get();

    final count = snap.docs.length;

    await _userDoc(uid).update({"stats.totalNotes": count});
    return count;
  }
}
