import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PDFViewerScreen extends StatelessWidget {
  final String pdfUrl;
  final String title;

  const PDFViewerScreen({super.key, required this.pdfUrl, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: pdfUrl.isEmpty
          ? const Center(
              child: Text(
                "رابط الكتاب غير متوفر",
                style: TextStyle(color: Colors.white),
              ),
            )
          : SfPdfViewer.network(
              pdfUrl,
              onDocumentLoadFailed: (PdfDocumentLoadFailedDetails details) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("فشل تحميل الكتاب: ${details.description}"),
                  ),
                );
              },
            ),
    );
  }
}
