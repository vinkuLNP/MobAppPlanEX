import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_widgets.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';
import 'package:plan_ex_app/core/utils/colors_utils.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/pro_badge.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/notes_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
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
  Color selectedColor = ColorsUtil.palette.first;

  List<String> attachments = [];
  bool uploading = false;

  @override
  void initState() {
    if (widget.note != null) {
      titleCtrl.text = widget.note!.title;
      contentCtrl.text = widget.note!.content;
      categoryCtrl.text = widget.note!.category;
      selectedColor = Color(widget.note!.color);
      attachments = List.from(widget.note!.attachments);
    } else {
      selectedColor = ColorsUtil.randomDefault();
      categoryCtrl.text = "General";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotesProvider>(context);
    final isEditing = widget.note != null;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: textWidget(
          text: isEditing ? "Edit Note" : "Create Note",
          fontWeight: FontWeight.w600,
        ),

        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commonSectionCard(child: _titleField()),
            const SizedBox(height: 16),
            commonSectionCard(child: _colorCategoryRow(provider)),
            const SizedBox(height: 16),
            commonSectionCard(child: _contentField()),
            const SizedBox(height: 16),
            commonSectionCard(child: _attachmentsSection(provider)),
            const SizedBox(height: 24),

            uploading
                ? const LinearProgressIndicator(minHeight: 4)
                : const SizedBox.shrink(),
            const SizedBox(height: 16),
            AppButton(
              text: isEditing ? "Update Note" : "Create Note",
              onTap: uploading ? null : _saveNote,
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _titleField() => TextField(
    controller: titleCtrl,
    style: appTextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    decoration: const InputDecoration(
      labelText: "Title",
      border: InputBorder.none,
    ),
  );

  Widget _colorCategoryRow(NotesProvider provider) {
    return Row(
      children: [
        textWidget(text: "Color", fontWeight: FontWeight.w500),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () {
            openColorPicker(
              context: context,
              onColorSelected: (color) {
                setState(() => selectedColor = color);
              },
            );
          },
          child: CircleAvatar(backgroundColor: selectedColor, radius: 16),
        ),
        const Spacer(),
        textWidget(text: "Category", fontWeight: FontWeight.w500),
        const SizedBox(width: 10),
        provider.isPro
            ? _categoryDropdown(provider)
            : textWidget(text: "General", color: Colors.grey.shade600),
      ],
    );
  }

  Widget _contentField() => TextField(
    controller: contentCtrl,
    minLines: 4,
    maxLines: null,
    keyboardType: TextInputType.multiline,
    style: appTextStyle(fontSize: 16),
    decoration: const InputDecoration(
      labelText: "Write your note...",
      border: InputBorder.none,
    ),
  );

  Widget _categoryDropdown(NotesProvider provider) {
    final cats = provider.categories.where((c) => c != "All").toList();

    if (!cats.contains(categoryCtrl.text)) {
      cats.add(categoryCtrl.text);
    }

    return DropdownButton<String>(
      underline: const SizedBox.shrink(),
      value: categoryCtrl.text,
      onChanged: (v) async {
        if (v == "__add_new__") {
          final newCat = await _openAddCategoryDialog();
          if (newCat != null && newCat.trim().isNotEmpty) {
            provider.addCategory(newCat.trim());
            setState(() => categoryCtrl.text = newCat.trim());
          }
        } else {
          setState(() => categoryCtrl.text = v ?? "General");
        }
      },
      items: [
        ...cats.map(
          (c) => DropdownMenuItem(
            value: c,
            child: textWidget(text: c),
          ),
        ),

        DropdownMenuItem(
          value: "__add_new__",
          child: Row(
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 6),
              textWidget(text: "Add new category"),
            ],
          ),
        ),
      ],
    );
  }

  Future<String?> _openAddCategoryDialog() async {
    final ctrl = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: textWidget(text: "New Category"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: "Enter category name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: textWidget(text: "Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: textWidget(text: "Add"),
          ),
        ],
      ),
    );
  }

  Widget _attachmentsSection(NotesProvider provider) {
    final pro = provider.isPro;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            textWidget(
              text: "Attachments",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            if (!pro) ProBadge(),

            if (pro)
              TextButton.icon(
                onPressed: _pickAndUploadFile,
                icon: const Icon(Icons.upload_file, size: 20),
                label: textWidget(text: "Add"),
              ),
          ],
        ),

        if (attachments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: textWidget(
              text: pro
                  ? "No attachments yet."
                  : "Upgrade to Pro to add attachments.",
              color: Colors.grey.shade600,
            ),
          ),

        ...attachments.map((a) =>  commonAttachmentTile(
          url: a,
          isViewOnly: false,
          onRemove: () => setState(() => attachments.remove(a)),
          context: context,
        ),)
      ],
    );
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(withData: false);
    if (result == null) return;

    final filePath = result.files.single.path;
    if (filePath == null) return;

    setState(() => uploading = true);

    try {
      final url = await _uploadFileToSupabase(File(filePath));
      setState(() => attachments.add(url));
    } finally {
      setState(() => uploading = false);
    }
  }

  Future<String> _uploadFileToSupabase(File file) async {
    final supabase = Supabase.instance.client;
    final id = const Uuid().v4();

    final originalName = file.path.split('/').last;
    final ext = originalName.split('.').last;
    final nameWithoutExt = originalName.replaceAll('.$ext', '');

    final fileName = "attachments/${id}___$nameWithoutExt.$ext";
    final fileBytes = await file.readAsBytes();

    await supabase.storage
        .from('notes_attachments')
        .uploadBinary(
          fileName,
          fileBytes,
          fileOptions: FileOptions(contentType: "image/$ext"),
        );

    return await supabase.storage
        .from('notes_attachments')
        .createSignedUrl(fileName, 60 * 60 * 24 * 365);
  }

  Future<void> _saveNote() async {
    final provider = Provider.of<NotesProvider>(context, listen: false);

    if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: textWidget(text: "Title and content cannot be empty"),
        ),
      );
      return;
    }

    final note = NoteEntity(
      id: widget.note?.id ?? "",
      title: titleCtrl.text.trim(),
      content: contentCtrl.text.trim(),
      category: provider.isPro
          ? (categoryCtrl.text.trim().isEmpty
                ? "General"
                : categoryCtrl.text.trim())
          : "General",
      attachments: provider.isPro ? attachments : [],
      createdAt: widget.note?.createdAt ?? DateTime.now(),
      color: selectedColor.toARGB32(),
    );

    try {
      if (widget.note == null) {
        await provider.add(note);
      } else {
        await provider.update(note);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: textWidget(text: "Failed: $e")));
      }
    }
  }
}