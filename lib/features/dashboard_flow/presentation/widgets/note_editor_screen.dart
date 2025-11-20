import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_button.dart';
import 'package:plan_ex_app/core/utils/colors_utils.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/image_preview_screen.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/notes_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
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
        title: Text(
          isEditing ? "Edit Note" : "Create Note",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(child: _titleField()),
            const SizedBox(height: 16),
            _sectionCard(child: _colorCategoryRow(provider)),
            const SizedBox(height: 16),
            _sectionCard(child: _contentField()),
            const SizedBox(height: 16),
            _sectionCard(child: _attachmentsSection(provider)),
            const SizedBox(height: 24),

            uploading
                ? const LinearProgressIndicator(minHeight: 4)
                : const SizedBox.shrink(),
            const SizedBox(height: 16),
            AppButton(
              text: isEditing ? "Update Note" : "Create Note",
              onTap: uploading ? null : _saveNote,
            ),SizedBox(height: 20,)
          ],
        ),
      ),
    );
  }


  Widget _sectionCard({required Widget child}) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha:0.05),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: child,
  );

  Widget _titleField() => TextField(
    controller: titleCtrl,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    decoration: const InputDecoration(
      labelText: "Title",
      border: InputBorder.none,
    ),
  );

  Widget _colorCategoryRow(NotesProvider provider) {
    return Row(
      children: [
        const Text("Color", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => _openColorPicker(context),
          child: CircleAvatar(backgroundColor: selectedColor, radius: 16),
        ),
        const Spacer(),
        const Text("Category", style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 10),
        provider.isPro
            ? _categoryDropdown(provider)
            : Text("General", style: TextStyle(color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _contentField() => TextField(
    controller: contentCtrl,
   minLines: 4,
  maxLines: null,    
  keyboardType: TextInputType.multiline,
    style: const TextStyle(fontSize: 16),
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
          child: Text(c),
        ),
      ),

      const DropdownMenuItem(
        value: "__add_new__",
        child: Row(
          children: [
            Icon(Icons.add, size: 18),
            SizedBox(width: 6),
            Text("Add new category"),
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
      title: const Text("New Category"),
      content: TextField(
        controller: ctrl,
        decoration: const InputDecoration(
          hintText: "Enter category name",
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, ctrl.text.trim()),
          child: const Text("Add"),
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
            const Text(
              "Attachments",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            if (pro)
              TextButton.icon(
                onPressed: _pickAndUploadFile,
                icon: const Icon(Icons.upload_file, size: 20),
                label: const Text("Add"),
              ),
          ],
        ),

        if (attachments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              pro
                  ? "No attachments yet."
                  : "Upgrade to Pro to add attachments.",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),

        ...attachments.map((a) => _attachmentTile(a)),
      ],
    );
  }

ListTile _attachmentTile(String url) {
  final fileName = extractOriginalNameFromSignedUrl(url);
  final isImage = fileName.contains(".png") ||
      fileName.contains(".jpg") ||
      fileName.contains(".jpeg") ||
      fileName.contains(".webp");

  return ListTile(
    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),

    leading: isImage
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              height: 45,
              width: 45,
              fit: BoxFit.cover,
            ),
          )
        : const Icon(Icons.insert_drive_file, size: 32),

    title: Text(fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(
      isImage ? "Image" : "Document",
      style: TextStyle(color: Colors.grey.shade600),
    ),

    onTap: () => openAttachment(url, isImage: isImage),

    trailing: IconButton(
      icon: const Icon(Icons.close),
      onPressed: () => setState(() => attachments.remove(url)),
    ),
  );
}

Future<void> openAttachment(String url, {required bool isImage}) async {
  if (isImage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewScreen(imageUrl: url),
      ),
    );
  } else {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
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

  String extractOriginalNameFromSignedUrl(String url) {
    final filePath = Uri.parse(url).pathSegments.last;
    final clean = filePath.split('?').first;
    final parts = clean.split('___');
    if (parts.length < 2) return clean;

    final nameWithExt = parts[1];
    return nameWithExt;

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
        const SnackBar(content: Text("Title and content cannot be empty")),
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
        ).showSnackBar(SnackBar(content: Text("Failed: $e")));
      }
    }
  }

  void _openColorPicker(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      builder: (_) => Container(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          children: ColorsUtil.palette
              .map(
                (c) => GestureDetector(
                  onTap: () {
                    setState(() => selectedColor = c);
                    Navigator.pop(context);
                  },
                  child: CircleAvatar(backgroundColor: c, radius: 22),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
