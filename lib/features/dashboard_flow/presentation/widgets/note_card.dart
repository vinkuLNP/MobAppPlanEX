import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/note_entity.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool multiSelectMode;
  final VoidCallback? onSelectToggle;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onDelete,
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
          color: const Color.fromARGB(255, 237, 237, 239),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (multiSelectMode)
              Checkbox(
                value: isSelected,
                onChanged: (_) => onSelectToggle?.call(),
              ),
            if (!multiSelectMode)
              GestureDetector(
                onTap: onSelectToggle,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.orange : Colors.grey,
                      width: 2,
                    ),
                    color: isSelected ? Colors.orange : Colors.transparent,
                  ),
                ),
              ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    note.content,
                    style: TextStyle(
                      color: const Color.fromARGB(255, 43, 42, 42),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      textWidget(
                        text: note.category,
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                      ),
                      const Spacer(),
                      textWidget(
                        text: date,
                        fontSize: 11,
                        color: Colors.grey.shade600,
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
}
