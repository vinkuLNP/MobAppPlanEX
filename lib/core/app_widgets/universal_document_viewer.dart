import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
        title: const Text("Document Viewer"),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(googleViewerUrl),
            ),
            onProgressChanged: (controller, progressValue) {
              setState(() {
                progress = progressValue / 100;
              });
            },
          ),

          if (progress < 1)
            Container(
              color: Colors.black.withOpacity(0.1),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                     CircularProgressIndicator(color: Theme.of(context).hintColor,),
                    const SizedBox(height: 12),
                    Text(
                      "Loading document...",
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
