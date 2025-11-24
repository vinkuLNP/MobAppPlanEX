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
      onLongPress: onSelectToggle,
      onTap: multiSelectMode ? onSelectToggle : onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        child: Container(
          decoration: BoxDecoration(
            color: lighten(Color(note.color), 0.85),
            borderRadius: BorderRadius.circular(18),
            border: Border(
              left: BorderSide(color: Color(note.color), width: 6),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              if (multiSelectMode)
                Checkbox(
                  value: isSelected,
                  onChanged: (_) => onSelectToggle?.call(),
                ),

              if (!multiSelectMode)
                Container(
                  width: 12,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Color(note.color),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    textWidget(
                      text: note.title,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    const SizedBox(height: 6),
                    textWidget(
                      text: note.content,
                      maxLine: 2,
                      textOverflow: TextOverflow.ellipsis,
                      fontSize: 12,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        textWidget(
                          text: note.category,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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
            ],
          ),
        ),
      ),
    );
  }

  Color lighten(Color color, [double amount = 0.4]) {
    assert(amount >= 0 && amount <= 1);
    return Color.lerp(color, Colors.white, amount)!;
  }
}
