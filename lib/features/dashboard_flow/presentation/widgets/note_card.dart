import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
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
                    border: Border.all(
                      color: AppColors.greyishColor.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    color: Colors.transparent,
                  ),
                ),
              ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  textWidget(
                    text: note.title,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  const SizedBox(height: 4),
                  textWidget(
                    text: note.content,
                    color: AppColors.greyishColor,
                    fontSize: 12,
                    maxLine: 2,
                    textOverflow: TextOverflow.ellipsis,
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

  Widget _selectionCircle(bool isSelected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.authThemeColor : AppColors.greyishColor,
          width: 2,
        ),
        color: isSelected ? AppColors.authThemeColor : Colors.transparent,
      ),
      child: isSelected
          ? const Icon(Icons.check, size: 14, color: Colors.white)
          : null,
    );
  }
}
