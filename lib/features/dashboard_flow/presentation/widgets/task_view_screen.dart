import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import '../../domain/entities/task_entity.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskViewScreen extends StatelessWidget {
  final TaskEntity task;
  const TaskViewScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: textWidget(context: context,
      text: task.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            textWidget(context: context,
            text: task.description),
            if (task.attachments.isNotEmpty) const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.attachments.map((a) {
                final name = a.split('/').last;
                final isImage =
                    name.endsWith('.png') ||
                    name.endsWith('.jpg') ||
                    name.endsWith('.jpeg') ||
                    name.endsWith('.webp');
                return GestureDetector(
                  onTap: () => _openUrl(a),
                  child: Container(
                    width: isImage ? 120 : 220,
                    height: isImage ? 90 : 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: isImage
                          ? Image.network(
                              a,
                              fit: BoxFit.cover,
                              width: 120,
                              height: 90,
                            )
                          : textWidget(context: context,
                          text: name),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
