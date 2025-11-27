import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';
import 'package:plan_ex_app/core/constants/app_colors.dart';
import 'package:plan_ex_app/core/utils/colors_utils.dart';
import 'package:plan_ex_app/features/dashboard_flow/presentation/widgets/image_preview_screen.dart';
import 'package:url_launcher/url_launcher.dart';

void showUpgradeDialog(BuildContext context, String subtitle) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: textWidget(text: "Upgrade to Pro", context: context),
      content: textWidget(text: subtitle, context: context),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: textWidget(text: "Later", context: context),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: textWidget(
            text: "Upgrade",
            context: context,
            color: AppColors.whiteColor,
          ),
        ),
      ],
    ),
  );
}

Widget commonSectionCard({required Widget child, required BuildContext context}) => Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color:Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  ),
  child: child,
);

Future<void> openColorPicker({
  required BuildContext context,
  required Function(Color) onColorSelected,
}) async {
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
                  onColorSelected(c);
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

Widget commonAttachmentTile({
  required String url,
  required bool isViewOnly,
  required VoidCallback? onRemove,
  required BuildContext context,
}) {
  final fileName = _extractOriginalName(url);
  final isImage =
      fileName.toLowerCase().endsWith('.png') ||
      fileName.toLowerCase().endsWith('.jpg') ||
      fileName.toLowerCase().endsWith('.jpeg') ||
      fileName.toLowerCase().endsWith('.webp');

  return ListTile(
    contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
    leading: isImage
        ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(url, height: 45, width: 45, fit: BoxFit.cover),
          )
        : const Icon(Icons.insert_drive_file, size: 32),
    title: textWidget(
      context: context,

      text: fileName,
      maxLine: 1,
      textOverflow: TextOverflow.ellipsis,
    ),
    subtitle: textWidget(
      context: context,

      text: isImage ? 'Image' : 'Document',
      color: Colors.grey.shade600,
    ),
    onTap: () => _openAttachment(url, isImage, context),
    trailing: isViewOnly
        ? null
        : IconButton(icon: const Icon(Icons.close), onPressed: onRemove),
  );
}

Future<String?> pickFileAndUpload({
  required Future<String> Function(File file) uploadFunc,
}) async {
  final result = await FilePicker.platform.pickFiles(withData: false);
  if (result == null) return null;

  final filePath = result.files.single.path;
  if (filePath == null) return null;

  final file = File(filePath);
  return uploadedUrl(file, uploadFunc);
}

Future<String> uploadedUrl(
  File file,
  Future<String> Function(File file) uploadFunc,
) async {
  return await uploadFunc(file);
}

Future<void> _openAttachment(
  String url,
  bool isImage,
  BuildContext context,
) async {
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

String _extractOriginalName(String url) {
  final clean = Uri.parse(url).pathSegments.last.split('?').first;
  final parts = clean.split('___');
  if (parts.length < 2) return clean;
  return parts[1];
}
