import 'package:flutter/material.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/notes_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/note_entity.dart';

class NotesProvider extends ChangeNotifier {
  final NotesRepository repo;

  NotesProvider(this.repo) {
    _listenNotes();
  }

  List<NoteEntity> notes = [];
  String selectedCategory = "All";

  void _listenNotes() {
    repo.getNotes().listen((event) {
      notes = event;
      notifyListeners();
    });
  }

  List<String> get categories =>
      ["All", ...{for (var n in notes) n.category}];

  List<NoteEntity> get filteredNotes =>
      selectedCategory == "All"
          ? notes
          : notes.where((n) => n.category == selectedCategory).toList();

  Future<void> add(NoteEntity e) => repo.add(e);
  Future<void> update(NoteEntity e) => repo.update(e);
  Future<void> delete(String id) => repo.delete(id);

  void filter(String category) {
    selectedCategory = category;
    notifyListeners();
  }
}
