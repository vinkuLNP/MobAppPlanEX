import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/database/supabase_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/recurrence_model.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/recurrence_entity.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/task_entity.dart';
import '../../../../core/utils/colors_utils.dart';
import '../../../../core/app_widgets/app_common_button.dart';
import '../../../dashboard_flow/presentation/widgets/image_preview_screen.dart';

class TaskEditorScreen extends StatefulWidget {
  final TaskEntity? editing;
  const TaskEditorScreen({super.key, this.editing});

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final tagCtrl = TextEditingController();

  DateTime? dueDate;
  String priority = 'medium';
  Color selectedColor = ColorsUtil.palette.first;
  List<String> attachments = [];
  List<String> tags = [];
  bool recurringEnabled = false;
  int recurrenceInterval = 1;
  RecurrenceUnit recurrenceUnit = RecurrenceUnit.days;

  bool uploading = false;

  final _supabase = SupabaseService();

  @override
  void initState() {
    super.initState();
    if (widget.editing != null) {
      final t = widget.editing!;
      titleCtrl.text = t.title;
      descCtrl.text = t.description;
      dueDate = t.dueDate;
      priority = t.priority;
      selectedColor = Color(t.color);
      attachments = List.from(t.attachments);
      tags = List.from(t.tags);
      if (t.recurrence != null &&
          t.recurrence!.interval != 0 &&
          t.recurrence!.unit != RecurrenceUnit.none) {
        recurringEnabled = true;
        recurrenceInterval = t.recurrence!.interval;
        recurrenceUnit = t.recurrence!.unit;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editing != null;
    final prov = Provider.of<TasksProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(isEditing ? 'Edit Task' : 'Create Task'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(child: _titleField()),
            const SizedBox(height: 12),
            _sectionCard(child: _colorPriorityRow()),
            const SizedBox(height: 12),
            _sectionCard(child: _descriptionField()),
            const SizedBox(height: 12),
            _sectionCard(child: _dueAndRecurringRow()),
            const SizedBox(height: 12),
            _sectionCard(child: _tagField()),
            const SizedBox(height: 12),
            _sectionCard(child: _attachmentsSection()),
            const SizedBox(height: 20),
            if (uploading) const LinearProgressIndicator(minHeight: 4),
            const SizedBox(height: 12),
            AppButton(
              text: isEditing ? 'Save Changes' : 'Create Task',
              onTap: uploading
                  ? null
                  : () async {
                      final newTask = TaskEntity(
                        id: widget.editing?.id ?? '',
                        title: titleCtrl.text.trim(),
                        description: descCtrl.text.trim(),
                        createdAt: widget.editing?.createdAt ?? DateTime.now(),
                        dueDate: dueDate,
                        completed: widget.editing?.completed ?? false,
                        color: selectedColor.toARGB32(),
                        attachments: attachments,
                        priority: priority,
                        tags: tags,
                        recurrence: recurringEnabled
                            ? RecurrenceModel(
                                interval: recurrenceInterval,
                                unit: recurrenceUnit,
                              )
                            : null,
                      );
                      if (widget.editing == null) {
                        await prov.addTask(newTask);
                      } else {
                        await prov.updateTask(newTask);
                      }
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required Widget child}) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
      ],
    ),
    child: child,
  );

  Widget _titleField() => TextField(
    controller: titleCtrl,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    decoration: const InputDecoration(
      labelText: 'Task title',
      border: InputBorder.none,
    ),
  );

    Widget _tagField() => TextField(
    controller: tagCtrl,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    decoration: const InputDecoration(
      labelText: 'Add Tag',
      border: InputBorder.none,
    ),
  );

  Widget _descriptionField() => TextField(
    controller: descCtrl,
    minLines: 4,
    maxLines: null,
    decoration: const InputDecoration(
      labelText: 'Description (optional)',
      border: InputBorder.none,
    ),
  );

  Widget _colorPriorityRow() => Row(
    children: [
      const Text('Color', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(width: 12),
      GestureDetector(
        onTap: _openColorPicker,
        child: CircleAvatar(backgroundColor: selectedColor, radius: 16),
      ),
      const Spacer(),
      const Text('Priority', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(width: 10),
      DropdownButton<String>(
        value: priority,
        items: [
          'low',
          'medium',
          'high',
        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (v) => setState(() => priority = v!),
      ),
    ],
  );

  Widget _dueAndRecurringRow() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            dueDate == null
                ? 'No due date'
                : '${dueDate!.year}-${dueDate!.month}-${dueDate!.day}',
          ),
          const Spacer(),
          TextButton(onPressed: _pickDate, child: const Text('Pick Due Date')),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Checkbox(
            value: recurringEnabled,
            onChanged: (v) => setState(() => recurringEnabled = v!),
          ),
          const SizedBox(width: 6),
          const Text(
            'Make this a recurring task',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const Spacer(),
        ],
      ),
      if (recurringEnabled)
        Row(
          children: [
            SizedBox(
              width: 80,
              child: TextFormField(
                initialValue: recurrenceInterval.toString(),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  final parsed = int.tryParse(v) ?? 1;
                  recurrenceInterval = parsed;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            DropdownButton<RecurrenceUnit>(
              value: recurrenceUnit,
              items: RecurrenceUnit.values
                  .map((u) => DropdownMenuItem(value: u, child: Text(u.name)))
                  .toList(),
              onChanged: (v) => setState(() => recurrenceUnit = v!),
            ),
          ],
        ),
    ],
  );

  Widget _attachmentsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Attachments',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          TextButton.icon(
            onPressed: _pickAndUploadFile,
            icon: const Icon(Icons.upload_file),
            label: const Text('Add'),
          ),
        ],
      ),
      if (attachments.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'No attachments',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ...attachments.map((a) => _attachmentTile(a)),
    ],
  );

  ListTile _attachmentTile(String url) {
    final name = _extractName(url);
    final isImage =
        name.toLowerCase().endsWith('.png') ||
        name.toLowerCase().endsWith('.jpg') ||
        name.toLowerCase().endsWith('.jpeg') ||
        name.toLowerCase().endsWith('.webp');
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: isImage
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
              ),
            )
          : const Icon(Icons.insert_drive_file, size: 32),
      title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(isImage ? 'Image' : 'Document'),
      onTap: () => _openAttachment(url, isImage),
      trailing: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => setState(() => attachments.remove(url)),
      ),
    );
  }

  Future<void> _openAttachment(String url, bool isImage) async {
    if (isImage) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ImagePreviewScreen(imageUrl: url)),
      );
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  Future<void> _pickAndUploadFile() async {
    final r = await FilePicker.platform.pickFiles(withData: false);
    if (r == null) return;
    final path = r.files.single.path;
    if (path == null) return;

    setState(() => uploading = true);
    try {
      final file = File(path);
      final bytes = await file.readAsBytes();
      final originalName = file.path.split('/').last;
      final ext = originalName.split('.').last;
      final id = const Uuid().v4();
      final nameOnly = originalName.replaceAll('.$ext', '');
      final fileName = 'tasks/${id}___$nameOnly.$ext';

      final signed = await _supabase.uploadBytesToBucket(
        bucket: 'tasks_attachments',
        path: fileName,
        bytes: Uint8List.fromList(bytes),
        contentType: 'image/$ext',
      );
      setState(() => attachments.add(signed));
    } catch (e, st) {
      debugPrint('upload err $e $st');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    } finally {
      setState(() => uploading = false);
    }
  }

  String _extractName(String signedUrl) {
    final clean = Uri.parse(signedUrl).pathSegments.last.split('?').first;
    final parts = clean.split('___');
    if (parts.length < 2) return clean;
    return parts[1];
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (p != null) setState(() => dueDate = p);
  }

  void _openColorPicker() {
    showModalBottomSheet(
      context: context,
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

