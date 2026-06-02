import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../presentation/widgets/pdf_share_sheet.dart';

Future<void> shareReportPdf({
  required Uint8List bytes,
  required String fileBaseName,
  BuildContext? context,
  required String reportTitle,
  String? shareText,
}) async {
  if (context != null && context.mounted) {
    await showPdfShareSheet(
      context,
      bytes: bytes,
      reportTitle: reportTitle,
    );
    return;
  }
  // Fallback when no context (should be rare on web).
  final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  debugPrint('PDF ready: ${fileBaseName}_$ts.pdf — ${shareText ?? reportTitle}');
}
