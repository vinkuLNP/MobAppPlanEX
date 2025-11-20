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
              backgroundColor: const Color.fromARGB(255, 227, 86, 76),
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
                          color: Colors.grey.shade100,
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
                        color: Colors.grey.shade100,
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
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
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
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          color: provider.multiSelectMode
                              ? const Color.fromARGB(255, 110, 108, 108)
                              : const Color.fromARGB(255, 144, 69, 64),
                        ),
                        onPressed: provider.multiSelectMode
                            ? provider.disableMultiSelectMode
                            : provider.enableMultiSelectMode,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 6),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: provider.categories.map((category) {
                      final isSelected = provider.selectedCategory == category;
                      final count = provider.notesCountFor(category);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => provider.filter(category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.black
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                              border: isSelected
                                  ? null
                                  : Border.all(color: Colors.grey.shade400),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "$category ($count)",
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
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

          if (!provider.multiSelectMode)
            Positioned(
              right: 10,
              bottom: 100,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: "multiSelectBtn",
                    mini: true,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.black,
                    ),
                    onPressed: () => provider.enableMultiSelectMode(),
                  ),
                  const SizedBox(height: 6),
                  textWidget(
                    text: "Select",
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
