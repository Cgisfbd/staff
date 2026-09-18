import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:staff_app/core/widgets/pdf/global_pdf_viewer.dart';

export 'package:staff_app/core/widgets/pdf/global_pdf_viewer.dart';

/// Backward-Compatible Adapter for [GlobalPdfViewer]
class PdfViewerPage extends StatelessWidget {
  const PdfViewerPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fileName,
    required this.pdfBytesFuture,
    this.isLandscape = false,
    this.actions,
  });

  final String title;
  final String subtitle;
  final String fileName;
  final Future<Uint8List> Function() pdfBytesFuture;
  final bool isLandscape;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return GlobalPdfViewer(
      title: title,
      subtitle: subtitle,
      fileName: fileName,
      pdfBytesFuture: pdfBytesFuture,
      isLandscape: isLandscape,
      actions: actions,
    );
  }
}
