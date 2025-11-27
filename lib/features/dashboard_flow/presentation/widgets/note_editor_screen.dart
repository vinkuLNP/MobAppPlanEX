import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_widgets.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';
import 'package:plan_ex_app/core/utils/colors_utils.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/custom_appbar.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/pro_badge.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/notes_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/note_entity.dart';

class NoteEditorScreen extends StatefulWidget {
  final NoteEntity? note;
  final bool isViewOnly;
  const NoteEditorScreen({super.key, this.note, this.isViewOnly = false});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final titleCtrl = TextEditingController();
  final contentCtrl = TextEditingController();
  final categoryCtrl = TextEditingController();
  Color selectedColor = ColorsUtil.palette.first;
  bool savingNote = false;

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
      appBar: CustomAppBar(
        title: widget.isViewOnly
            ? "View Note"
            : isEditing
            ? "Edit Note"
            : "Create Note",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commonSectionCard(context: context, child: _titleField()),
            const SizedBox(height: 16),
            commonSectionCard(
              context: context,
              child: _colorCategoryRow(provider),
            ),
            const SizedBox(height: 16),
            commonSectionCard(context: context, child: _contentField()),
            const SizedBox(height: 16),
            commonSectionCard(
              context: context,
              child: _attachmentsSection(provider),
            ),
            const SizedBox(height: 24),

            uploading
                ? const LinearProgressIndicator(minHeight: 4)
                : const SizedBox.shrink(),
            const SizedBox(height: 16),
            if (!widget.isViewOnly)
              AppButton(
                isLoading: savingNote,
                text: isEditing ? "Update Note" : "Create Note",
                onTap: (uploading || savingNote) ? null : _saveNote,
              ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _titleField() => TextField(
    controller: titleCtrl,
    minLines: 1,
    maxLines: 7,
    readOnly: widget.isViewOnly,
    style: appTextStyle(context: context, fontSize: 14),
    decoration: InputDecoration(
      labelText: "Title",
      filled: false,
      border: InputBorder.none,
      labelStyle: appTextStyle(context: context, fontSize: 14),
    ),
  );

  Widget _colorCategoryRow(NotesProvider provider) {
    return Row(
      children: [
        textWidget(
          context: context,
          text: "Color",
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: widget.isViewOnly
              ? null
              : () {
                  openColorPicker(
                    context: context,
                    onColorSelected: (color) {
                      setState(() => selectedColor = color);
                    },
                  );
                },
          child: CircleAvatar(backgroundColor: selectedColor, radius: 16),
        ),
        // const Spacer(),
        SizedBox(width: 6,),
        textWidget(
          context: context,
          text: "Category",
          fontWeight: FontWeight.w500,
        ),
        const SizedBox(width: 10),
        Flexible(
          child: provider.isPro
              ? _categoryDropdown(provider)
              : textWidget(
                  context: context,
                  text: "General",
                  color: Colors.grey.shade600,
                ),
        ),
      ],
    );
  }
  Widget _categoryDropdown(NotesProvider provider) {
    final cats = provider.categories.where((c) => c != "All").toList();

 if (!cats.contains("General")) {
    cats.insert(0, "General");
  }
    if (!cats.contains(categoryCtrl.text)) {
      cats.add(categoryCtrl.text);
    }
if (categoryCtrl.text.isEmpty) {
    categoryCtrl.text = "General";
  }
    return DropdownButton<String>(
      underline: const SizedBox.shrink(),
      isExpanded: true,
      value: categoryCtrl.text,
      onChanged: widget.isViewOnly
          ? null
          : (v) async {
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
            child: textWidget(context: context, text: c,maxLine: 1,textOverflow: TextOverflow.ellipsis),
          ),
        ),

        DropdownMenuItem(
          value: "__add_new__",
          child: Row(
            children: [
              Icon(Icons.add, size: 18),
              SizedBox(width: 6),
              Flexible(child: textWidget(context: context, text: "Add new category")),
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
        title: textWidget(context: context, text: "New Category"),
        content: TextField(
          controller: ctrl,

          decoration: const InputDecoration(hintText: "Enter category name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: textWidget(context: context, text: "Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: textWidget(context: context, text: "Add"),
          ),
        ],
      ),
    );
  }

  Widget _contentField() => TextField(
    controller: contentCtrl,
    minLines: 4,
    maxLines: null,
    readOnly: widget.isViewOnly,
    keyboardType: TextInputType.multiline,
    style: appTextStyle(context: context, fontSize: 16),
    decoration: InputDecoration(
      filled: false,
      labelText: "Write your note...",
      border: InputBorder.none,
      labelStyle: appTextStyle(context: context, fontSize: 14),
    ),
  );


  Widget _attachmentsSection(NotesProvider provider) {
    final pro = provider.isPro;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            textWidget(
              context: context,
              text: "Attachments",
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            if (!pro) ProBadge(),

            if (pro && !widget.isViewOnly)
              TextButton.icon(
                onPressed: _pickAndUploadFile,
                icon: Icon(
                  Icons.upload_file,
                  size: 20,
                  color: Theme.of(context).hintColor,
                ),
                label: textWidget(context: context, text: "Add"),
              ),
          ],
        ),

        if (attachments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: textWidget(
              context: context,
              text: pro
                  ? "No attachments yet."
                  : "Upgrade to Pro to add attachments.",
              color: Colors.grey.shade600,
            ),
          ),

        ...attachments.map(
          (a) => commonAttachmentTile(
            url: a,
            isViewOnly: widget.isViewOnly,
            onRemove: widget.isViewOnly
                ? null
                : () => setState(() => attachments.remove(a)),
            context: context,
          ),
        ),
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
    if (savingNote) return;

    setState(() => savingNote = true);
    final provider = Provider.of<NotesProvider>(context, listen: false);

    if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) {
      setState(() => savingNote = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: textWidget(
            context: context,
            text: "Title and content cannot be empty",
            color: Theme.of(context).cardColor,
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: textWidget(
              context: context,
              text: "Failed: $e",
              color: Theme.of(context).cardColor,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => savingNote = false);
    }
  }
}
