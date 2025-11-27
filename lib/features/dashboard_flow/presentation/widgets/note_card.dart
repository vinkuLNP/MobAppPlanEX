import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/note_entity.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/note_editor_screen.dart';
import 'package:share_plus/share_plus.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback? onTap;
  final VoidCallback onDelete;
  final bool isSelected;
  final bool multiSelectMode;
  final VoidCallback? onSelectToggle;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    required this.onDelete,
    this.isSelected = false,
    this.multiSelectMode = false,
    this.onSelectToggle,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().add_jm().format(note.createdAt);
    return GestureDetector(
      onTap: multiSelectMode ? onSelectToggle : onTap,
      onLongPress: onSelectToggle,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (multiSelectMode)
              GestureDetector(
                onTap: onSelectToggle,
                child: _selectionCircle(isSelected),
              ),
            if (!multiSelectMode)
              GestureDetector(
                onTap: onSelectToggle,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2),
                    color: Colors.transparent,
                  ),
                ),
              ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          textWidget(
                            context: context,
                            text: note.title,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          const SizedBox(height: 4),
                          textWidget(
                            context: context,
                            text: note.content,
                            fontSize: 12,
                            maxLine: 2,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'share') _shareTask(note);
                          if (value == 'edit') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteEditorScreen(note: note),
                              ),
                            );
                          }
                          if (value == 'delete') _confirmDelete(context, note);
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share, size: 16),
                                SizedBox(width: 6),
                                textWidget(context: context, text: 'Share'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 16),
                                SizedBox(width: 6),

                                textWidget(context: context, text: 'Edit'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 16),
                                SizedBox(width: 6),

                                textWidget(context: context, text: 'Delete'),
                              ],
                            ),
                          ),
                        ],
                        child:  Icon(Icons.more_vert,color: Theme.of(context).hintColor,),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      textWidget(
                        context: context,
                        text: note.category,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                      const Spacer(),
                      textWidget(
                        context: context,
                        text: date,
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),
            Container(
              width: 5,
              height: 30,
              decoration: BoxDecoration(
                color: Color(note.color),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectionCircle(bool isSelected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.authThemeColor : Colors.grey,
          width: 2,
        ),
        color: isSelected ? AppColors.authThemeColor : Colors.transparent,
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }

  void _shareTask(NoteEntity note) {
    final text =
        """
        Note: ${note.title}
        Content: ${note.content.isEmpty ? "-" : note.content}
        Category: ${note.category}
        """;
    SharePlus.instance.share(ShareParams(text: text));
  }

  void _confirmDelete(BuildContext context, NoteEntity note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: textWidget(context: context, text: "Delete Note?"),
        content: textWidget(
          context: context,
          text: "This action cannot be undone.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: textWidget(context: context, text: "Cancel"),
          ),
          AppButton(
            text: "Delete",
            onTap: () {
              Navigator.pop(context);

              onDelete();
            },
          ),
        ],
      ),
    );
  }
}
