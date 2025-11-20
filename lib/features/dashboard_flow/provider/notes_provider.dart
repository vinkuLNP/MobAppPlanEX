import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/services/local_storage_services.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/repositories/notes_repository.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/note_entity.dart';

class NotesProvider extends ChangeNotifier {
  final NotesRepository repo;
  late SharedPrefsService _prefsService;

  NotesProvider(this.repo) {
    _listenNotes();
    _initPrefs();
  }

  List<NoteEntity> notes = [];
  String selectedCategory = "All";
  bool isPro = false;

  void _listenNotes() {
    repo.getNotes().listen((event) {
      notes = event;
      notifyListeners();
    });
  }

  Future<void> _initPrefs() async {
    _prefsService = await SharedPrefsService.getInstance();
    isPro = true;
    // _prefsService.isPro;
    notifyListeners();
  }

  Future<void> setPro(bool val) async {
    isPro = val;
    await _prefsService.setPro(val);
    notifyListeners();
  }

  List<String> get categories => [
    "All",
    ...{for (var n in notes) n.category.isNotEmpty ? n.category : "General"},
  ];

  List<NoteEntity> get filteredNotes => selectedCategory == "All"
      ? notes
      : notes.where((n) => n.category == selectedCategory).toList();

  Future<void> add(NoteEntity e) => repo.add(e);
  Future<void> update(NoteEntity e) => repo.update(e);
  Future<void> delete(String id) => repo.delete(id);

  void filter(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void addCategory(String name) {
  if (!categories.contains(name)) {
    categories.add(name);
    notifyListeners();
  }
}

}
