import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../presentation/widgets/pdf_share_sheet.dart';

/// Mobile/desktop — temp file + share sheet (matches rm_mobile_app flow).
Future<void> shareReportPdf({
  required Uint8List bytes,
  required String fileBaseName,
  BuildContext? context,
  required String reportTitle,
  String? shareText,
}) async {
  final dir = await getTemporaryDirectory();
  final ts = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
  final file = File('${dir.path}/${fileBaseName}_$ts.pdf');
  await file.writeAsBytes(bytes);

  if (context != null && context.mounted) {
    await showPdfShareSheet(
      context,
      file: file,
      reportTitle: reportTitle,
    );
    return;
  }

  await Share.shareXFiles(
    [XFile(file.path)],
    text: shareText ?? reportTitle,
  );
}
