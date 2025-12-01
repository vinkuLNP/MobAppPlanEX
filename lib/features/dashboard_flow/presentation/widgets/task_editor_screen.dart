import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_widgets.dart';
import 'package:plan_ex_app/core/constants/app_text_style.dart';
import 'package:plan_ex_app/core/utils/app_logger.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/database/supabase_service.dart';
import 'package:plan_ex_app/features/dashboard_flow/data/models/recurrence_model.dart';
import 'package:plan_ex_app/features/dashboard_flow/domain/entities/recurrence_entity.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/custom_appbar.dart';
import 'package:plan_ex_app/features/dashboard_flow/provider/task_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/task_entity.dart';
import '../../../../core/utils/colors_utils.dart';
import '../../../../core/app_widgets/app_common_button.dart';

class TaskEditorScreen extends StatefulWidget {
  final TaskEntity? editing;
  final bool viewOnly;
  const TaskEditorScreen({super.key, this.editing, this.viewOnly = false});

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final tagCtrl = TextEditingController();
  bool savingTask = false;

  DateTime? dueDate;
  String priority = 'MEDIUM';
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
    dueDate = widget.editing?.dueDate ?? DateTime.now();
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

  bool get isViewOnly => widget.viewOnly;
  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editing != null;
    final prov = Provider.of<TasksProvider>(context, listen: false);

    return Scaffold(
      appBar: CustomAppBar(
        title: isViewOnly
            ? 'View Task'
            : isEditing
            ? 'Edit Task'
            : 'Create Task',
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            commonSectionCard(context: context, child: _titleField()),
            const SizedBox(height: 12),
            commonSectionCard(context: context, child: _colorPriorityRow()),
            const SizedBox(height: 12),
            commonSectionCard(context: context, child: _descriptionField()),
            const SizedBox(height: 12),
            commonSectionCard(
              context: context,
              child: _dueAndRecurringRow(prov),
            ),
            const SizedBox(height: 12),
            commonSectionCard(context: context, child: _tagField()),
            const SizedBox(height: 12),
            commonSectionCard(
              context: context,
              child: _attachmentsSection(prov),
            ),
            const SizedBox(height: 20),
            if (uploading) const LinearProgressIndicator(minHeight: 4),
            const SizedBox(height: 12),
            if (!isViewOnly)
              IgnorePointer(
                ignoring: savingTask,
                child: AppButton(
                  isLoading: savingTask,
                  text: savingTask
                      ? (isEditing ? 'Saving...' : 'Creating...')
                      : isEditing
                      ? 'Save Changes'
                      : 'Create Task',
                  onTap: uploading
                      ? null
                      : () async {
                          final title = titleCtrl.text.trim();

                          if (title.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Task title is required'),
                              ),
                            );
                            return;
                          }

                          setState(() => savingTask = true);
                          try {
                            final newTask = TaskEntity(
                              id: widget.editing?.id ?? '',
                              title: titleCtrl.text.trim(),
                              description: descCtrl.text.trim(),
                              createdAt:
                                  widget.editing?.createdAt ?? DateTime.now(),
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
                          } catch (e) {
                            AppLogger.error(e.toString());
                          } finally {
                            if (mounted) {
                              setState(() => savingTask = false);
                            }
                          }
                        },
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _titleField() => TextField(
    controller: titleCtrl,
    readOnly: isViewOnly,
    minLines: 1,
    maxLines: 7,
    maxLength: 100,
    style: appTextStyle(context: context, fontSize: 14),
    decoration: InputDecoration(
      labelText: 'Task title',
      filled: false,
      border: InputBorder.none,
      labelStyle: appTextStyle(context: context, fontSize: 14),
    ),
  );

  Widget _tagField() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      textWidget(context: context, text: 'Tags', fontWeight: FontWeight.w600),
      const SizedBox(height: 8),

      SizedBox(
        width: double.infinity,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...tags.map(
              (tag) => Chip(
                label: Text(tag),
                deleteIcon: isViewOnly ? null : const Icon(Icons.close),
                onDeleted: isViewOnly
                    ? null
                    : () => setState(() => tags.remove(tag)),
              ),
            ),

            if (!isViewOnly)
              ActionChip(
                label: const Text('+ Add tag'),
                onPressed: () => _showAddTagDialog(),
              ),
          ],
        ),
      ),
    ],
  );

  void _showAddTagDialog() {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: ctrl,
          maxLength: 20,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter tag name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          AppButton(
            text: 'Add',
            onTap: () {
              final tag = ctrl.text.trim();
              if (tag.isNotEmpty && !tags.contains(tag)) {
                setState(() => tags.add(tag));
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _descriptionField() => TextField(
    controller: descCtrl,
    readOnly: isViewOnly,
    minLines: 4,
    maxLength: 2000,
    maxLines: null,
    decoration: InputDecoration(
      filled: false,
      labelStyle: appTextStyle(context: context, fontSize: 14),
      labelText: 'Description (optional)',
      border: InputBorder.none,
    ),
  );

  Widget _colorPriorityRow() => Row(
    children: [
      textWidget(context: context, text: 'Color', fontWeight: FontWeight.w600),
      const SizedBox(width: 12),
      GestureDetector(
        onTap: isViewOnly
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
      const Spacer(),
      textWidget(
        context: context,

        text: 'Priority',
        fontWeight: FontWeight.w600,
      ),
      const SizedBox(width: 10),
      DropdownButton<String>(
        value: priority,
        iconDisabledColor: Colors.grey,
        items: ['LOW', 'MEDIUM', 'HIGH']
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: textWidget(context: context, text: e),
              ),
            )
            .toList(),
        onChanged: isViewOnly ? null : (v) => setState(() => priority = v!),
      ),
    ],
  );

  Widget _dueAndRecurringRow(TasksProvider provider) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          textWidget(
            context: context,

            text: dueDate == null
                ? 'No due date'
                : '${dueDate!.year}-${dueDate!.month}-${dueDate!.day}',
          ),
          const Spacer(),
          isViewOnly
              ? textWidget(context: context, text: 'Due Date')
              : TextButton(
                  onPressed: _pickDate,
                  child: textWidget(context: context, text: 'Pick Due Date'),
                ),
        ],
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Checkbox(
            value: recurringEnabled,
            onChanged: !isViewOnly && provider.isPro
                ? (v) => setState(() => recurringEnabled = v!)
                : null,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: textWidget(
              context: context,

              text: 'Make this a recurring task',
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 5),

          // ProBadge(),
          const Spacer(),
        ],
      ),
      if (recurringEnabled)
        Row(
          children: [
            SizedBox(
              width: 80,
              child: TextFormField(
                readOnly: isViewOnly,
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
              iconDisabledColor: Colors.grey,
              items: RecurrenceUnit.values
                  .map(
                    (u) => DropdownMenuItem(
                      value: u,
                      child: textWidget(context: context, text: u.name),
                    ),
                  )
                  .toList(),
              onChanged: isViewOnly
                  ? null
                  : (v) => setState(() => recurrenceUnit = v!),
            ),
          ],
        ),
    ],
  );

  Widget _attachmentsSection(TasksProvider provider) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          textWidget(
            context: context,

            text: 'Attachments',
            fontWeight: FontWeight.w600,
          ),
          // if (!provider.isPro) ProBadge(),
          if (!isViewOnly && provider.isPro && attachments.length < 10)
            TextButton.icon(
              onPressed: _pickAndUploadFile,
              icon: Icon(Icons.upload_file, color: Theme.of(context).hintColor),
              label: textWidget(context: context, text: 'Add'),
            ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: textWidget(
          context: context,
          text: "Supported formats: JPG, PNG, PDF, DOC",
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      if (attachments.isEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: textWidget(
            context: context,

            text: provider.isPro
                ? "No attachments yet."
                : "Upgrade to Pro to add attachments.",
            color: Colors.grey.shade600,
          ),
        ),
      ...attachments.map(
        (a) => commonAttachmentTile(
          url: a,
          isViewOnly: isViewOnly,
          onRemove: () => setState(() => attachments.remove(a)),
          context: context,
        ),
      ),
    ],
  );

  Future<void> _pickAndUploadFile() async {
    final r = await FilePicker.platform.pickFiles(
      withData: false,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
    );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: textWidget(
              context: context,
              text: 'Upload failed: $e',
              color: Theme.of(context).cardColor,
            ),
          ),
        );
      }
    } finally {
      setState(() => uploading = false);
    }
  }

  Future<void> _pickDate() async {
    final p = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).hintColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (p != null) setState(() => dueDate = p);
  }
}
