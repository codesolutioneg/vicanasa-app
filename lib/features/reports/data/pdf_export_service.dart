import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

import 'report_pdf_share_platform.dart';

class PdfExportService {
  Future<void> shareFinancialReport({
    required Uint8List bytes,
    required String partnerName,
    BuildContext? context,
  }) async {
    await shareReportPdf(
      bytes: bytes,
      fileBaseName: 'financial_${partnerName.replaceAll(' ', '_')}',
      reportTitle: 'Financial Report — $partnerName',
      shareText: 'Financial Report',
      context: context,
    );
  }

  Future<Uint8List> buildSimplePdf(String title, List<String> lines) async {
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        build: (ctx) => [
          pw.Header(level: 0, child: pw.Text(title)),
          ...lines.map(pw.Text.new),
        ],
      ),
    );
    return doc.save();
  }
}
