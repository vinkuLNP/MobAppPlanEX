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

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButton<String>(
              value: provider.selectedCategory,
              items: provider.categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                provider.filter(v);
              },
            ),
          ),

          Expanded(
            child: provider.filteredNotes.isEmpty
                ? const Center(child: Text("No notes yet"))
                : ListView.builder(
                    itemCount: provider.filteredNotes.length,
                    itemBuilder: (context, i) {
                      final n = provider.filteredNotes[i];
                      return NoteCard(
                        note: n,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NoteEditorScreen(note: n),
                            ),
                          );
                        },
                        onDelete: () => provider.delete(n.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
    
  }
}
