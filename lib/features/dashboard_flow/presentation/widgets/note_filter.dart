import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';

class NoteFilter extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final Function(String) onChanged;

  const NoteFilter({super.key, 
    required this.categories,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.filter_list),
      onSelected: onChanged,
      itemBuilder: (_) => categories
          .map((c) => PopupMenuItem(
                value: c,
                child: textWidget(text:  c),
              ))
          .toList(),
    );
  }
}
