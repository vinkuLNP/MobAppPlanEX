import 'package:flutter/material.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/note_card.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/note_editor_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/notes_provider.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotesProvider>(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("New Note"),
        icon: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => NoteEditorScreen()),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 10),
                      Text("Search notes..."),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.filter_list),
                    SizedBox(width: 6),
                    Text("All Categories"),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(Icons.folder_open, color: Colors.purple),
              const SizedBox(width: 6),
              const Text(
                "General",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ...provider.filteredNotes.map((note) => NoteCard(note: note)),
        ],
      ),
    );
  }
}