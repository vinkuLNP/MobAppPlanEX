import 'package:flutter/material.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/custom_appbar.dart';
import '../../domain/entities/note_entity.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteEntity? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();

  Color selectedColor = Colors.redAccent;

  @override
  void initState() {
    if (widget.note != null) {
      titleCtrl.text = widget.note!.title;
      contentCtrl.text = widget.note!.content;
      categoryCtrl.text = widget.note!.category;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final provider = Provider.of<NotesProvider>(context, listen: false);
    final isEditing = widget.note != null;

    return Scaffold(
      backgroundColor: Colors.white,
appBar:  CustomAppBar(title:  isEditing ? "Edit Note" : "Create Note",actions: [ IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),]),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.92,
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              const Text(
                "Update your note content and settings.",
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      "Title",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text("Color", style: TextStyle(color: Colors.black87)),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => _colorPicker(),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: selectedColor,
                      radius: 14,
                      child: const Icon(Icons.palette, color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),
              _inputField(titleCtrl),

              const SizedBox(height: 20),

              Row(
                children: [
                  const Text(
                    "Category",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 6),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "PRO",
                      style: TextStyle(fontSize: 11, color: Colors.purple),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              _inputField(categoryCtrl, enabled: false),

              const SizedBox(height: 20),

              const Text(
                "Content",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 6),
              _inputArea(contentCtrl),

              const SizedBox(height: 20),

              Row(
                children: [
                  const Text(
                    "Attachments",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "PRO",
                      style: TextStyle(fontSize: 11, color: Colors.purple),
                    ),
                  ),
                ],
              ),

              _attachmentBox(),

          
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(TextEditingController ctrl, {bool enabled = true}) {
    return TextField(
      controller: ctrl,
      enabled: enabled,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        disabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _inputArea(TextEditingController ctrl) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade100,
      ),
      child: TextField(
        controller: ctrl,
        maxLines: null,
        decoration: const InputDecoration.collapsed(hintText: ""),
      ),
    );
  }

  Widget _attachmentBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add New Attachments",
            style: TextStyle(color: Colors.grey.shade800),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.file_copy_outlined),
                SizedBox(width: 8),
                Text("Add Files"),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Attachments are a Pro feature. Upgrade to add or remove files.",
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _colorPicker() {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      child: Wrap(
        spacing: 14,
        children: colors
            .map(
              (c) => GestureDetector(
                onTap: () {
                  setState(() => selectedColor = c);
                  Navigator.pop(context);
                },
                child: CircleAvatar(backgroundColor: c, radius: 18),
              ),
            )
            .toList(),
      ),
    );
  }
}
