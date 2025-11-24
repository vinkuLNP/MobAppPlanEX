import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
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
      floatingActionButton: provider.multiSelectMode
          ? FloatingActionButton.extended(
              label: textWidget(
                text: "Delete (${provider.selectedNoteIds.length})",
                color: AppColors.whiteColor,
              ),
              icon: const Icon(Icons.delete, color: AppColors.whiteColor),
              backgroundColor: AppColors.errorColor.withValues(alpha: 0.9),
              onPressed: () => provider.deleteSelected(),
            )
          : FloatingActionButton.extended(
              label: textWidget(text: "New Note"),
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteEditorScreen()),
              ),
            ),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.lightGrey.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search notes...",
                            prefixIcon: const Icon(Icons.search, size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(top: 12),
                          ),
                          onChanged: provider.updateSearch,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: provider.selectedCategory,
                        underline: const SizedBox(),
                        isExpanded: false,
                        icon: Row(
                          children: const [
                            Icon(Icons.filter_list),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),

                        selectedItemBuilder: (context) {
                          return provider.categories.map((c) {
                            return const SizedBox.shrink();
                          }).toList();
                        },

                        items: provider.categories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: textWidget(text: c),
                              ),
                            )
                            .toList(),

                        onChanged: (v) {
                          if (v != null) provider.filter(v);
                        },
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: provider.multiSelectMode
                              ? AppColors.greyishColor
                              : AppColors.errorColor.withValues(alpha: 0.9),
                        ),
                        onPressed: provider.multiSelectMode
                            ? provider.disableMultiSelectMode
                            : provider.enableMultiSelectMode,
                      ),
                    ),
                  ),
                ],
              ),

              Expanded(
                child: provider.filteredNotes.isEmpty
                    ? Center(child: textWidget(text: "No notes yet"))
                    : ListView.builder(
                        itemCount: provider.filteredNotes.length,
                        itemBuilder: (context, i) {
                          final n = provider.filteredNotes[i];
                          return NoteCard(
                            note: n,
                            isSelected: provider.selectedNoteIds.contains(n.id),
                            multiSelectMode: provider.multiSelectMode,
                            onSelectToggle: () =>
                                provider.toggleSelection(n.id),

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
        ],
      ),
    );
  }
}
