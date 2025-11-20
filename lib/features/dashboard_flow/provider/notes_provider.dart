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
void enableMultiSelectMode() {
  multiSelectMode = true;
  notifyListeners();
}

void disableMultiSelectMode() {
  multiSelectMode = false;
  selectedNoteIds.clear();
  notifyListeners();
}
int notesCountFor(String category) {
  if (category == "All") return notes.length;
  return notes.where((n) => n.category == category).length;
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

  String searchQuery = "";
  bool multiSelectMode = false;
  Set<String> selectedNoteIds = {};

  List<NoteEntity> get filteredNotes {
    var filtered = selectedCategory == "All"
        ? notes
        : notes.where((n) => n.category == selectedCategory).toList();
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((n) {
        final q = searchQuery.toLowerCase();
        return n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q);
      }).toList();
    }

    return filtered;
  }

  void updateSearch(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void toggleSelection(String id) {
    if (selectedNoteIds.contains(id)) {
      selectedNoteIds.remove(id);
    } else {
      selectedNoteIds.add(id);
    }

    if (selectedNoteIds.isEmpty) {
      multiSelectMode = false;
    } else {
      multiSelectMode = true;
    }

    notifyListeners();
  }

  void clearSelection() {
    selectedNoteIds.clear();
    multiSelectMode = false;
    notifyListeners();
  }

  Future<void> deleteSelected() async {
    for (var id in selectedNoteIds) {
      await repo.delete(id);
    }
    clearSelection();
  }
}
