import 'package:flutter/material.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/note_entity.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/note_editor_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/notes_provider.dart';
import 'package:provider/provider.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;

  const NoteCard({super.key, required this.note});

  Color get categoryColor => Colors.purple; 

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotesProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:  0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: categoryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      radius: 6,
                      backgroundColor: categoryColor,
                    )
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  note.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteEditorScreen(note: note),
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Edit"),
                    ),

                    const Spacer(),

                    IconButton(
                      onPressed: () => (),
                      //     Share.share("${note.title}\n\n${note.content}"),
                      icon: const Icon(Icons.share_outlined),
                    ),

                    IconButton(
                      onPressed: () => provider.delete(note.id),
                      icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

