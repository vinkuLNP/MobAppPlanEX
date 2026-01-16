import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:plan_ex_app/core/app_widgets/app_common_text_widget.dart';

class UniversalDocumentViewer extends StatefulWidget {
  final String fileUrl;

  const UniversalDocumentViewer({super.key, required this.fileUrl});

  @override
  State<UniversalDocumentViewer> createState() =>
      _UniversalDocumentViewerState();
}

class _UniversalDocumentViewerState extends State<UniversalDocumentViewer> {
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    final googleViewerUrl =
        "https://docs.google.com/gview?embedded=true&url=${widget.fileUrl}";

    return Scaffold(
      appBar: AppBar(
        title: textWidget(text: "Document Viewer", context: context),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(googleViewerUrl)),
            onProgressChanged: (controller, progressValue) {
              setState(() {
                progress = progressValue / 100;
              });
            },
          ),

          if (progress < 1)
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(height: 12),
                    textWidget(context: context, text: "Loading document..."),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
