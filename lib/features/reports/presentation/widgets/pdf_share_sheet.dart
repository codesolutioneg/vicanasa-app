import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

Future<void> showPdfShareSheet(
  BuildContext context, {
  File? file,
  Uint8List? bytes,
  required String reportTitle,
}) {
  assert(file != null || bytes != null);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (ctx) {
      final viewInsets = MediaQuery.viewInsetsOf(ctx);
      final maxHeight = MediaQuery.sizeOf(ctx).height * 0.88 - viewInsets.bottom;
      return Padding(
        padding: viewInsets,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: _PdfShareSheet(
            file: file,
            bytes: bytes,
            reportTitle: reportTitle,
          ),
        ),
      );
    },
  );
}

class _PdfShareSheet extends StatelessWidget {
  const _PdfShareSheet({
    this.file,
    this.bytes,
    required this.reportTitle,
  });

  final File? file;
  final Uint8List? bytes;
  final String reportTitle;

  String _fmtSize(int byteCount) {
    if (byteCount < 1024) return '$byteCount B';
    if (byteCount < 1024 * 1024) {
      return '${(byteCount / 1024).toStringAsFixed(1)} KB';
    }
    return '${(byteCount / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  String _fileName() {
    if (file != null) {
      return file!.path.split(Platform.pathSeparator).last;
    }
    return '$reportTitle.pdf';
  }

  int _byteLength() {
    if (file != null && file!.existsSync()) return file!.lengthSync();
    return bytes?.length ?? 0;
  }

  Future<Uint8List> _readBytes() async {
    if (bytes != null) return bytes!;
    return file!.readAsBytes();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sizeText = _byteLength() > 0 ? _fmtSize(_byteLength()) : '';

    return Material(
      color: AppColors.bgSecondary,
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppDimensions.radiusXl),
      ),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppDimensions.spaceSm),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              _Header(reportTitle: reportTitle),
              const SizedBox(height: AppDimensions.spaceMd),
              _FileInfo(fileName: _fileName(), sizeText: sizeText),
              const SizedBox(height: AppDimensions.spaceMd),
              _ActionGrid(
                reportTitle: reportTitle,
                readBytes: _readBytes,
                fileName: _fileName(),
                file: file,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLg),
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    foregroundColor: AppColors.textMuted,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.commonCancel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.reportTitle});
  final String reportTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.doc_text_fill,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.pdfGeneratedTitle,
                    style: AppTextStyles.kpiLabel.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reportTitle,
                    style: AppTextStyles.headlineSm.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileInfo extends StatelessWidget {
  const _FileInfo({required this.fileName, required this.sizeText});
  final String fileName;
  final String sizeText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLg),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceSm),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            const Icon(CupertinoIcons.doc, color: AppColors.accentRed, size: 18),
            const SizedBox(width: AppDimensions.spaceSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: AppTextStyles.labelLg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (sizeText.isNotEmpty)
                    Text('PDF · $sizeText', style: AppTextStyles.caption),
                ],
              ),
            ),
            Text(
              AppLocalizations.of(context)!.pdfReady,
              style: AppTextStyles.kpiLabel.copyWith(color: AppColors.accentGreen),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  const _ActionGrid({
    required this.reportTitle,
    required this.readBytes,
    required this.fileName,
    this.file,
  });

  final String reportTitle;
  final Future<Uint8List> Function() readBytes;
  final String fileName;
  final File? file;

  Future<void> _share(BuildContext context) async {
    Navigator.of(context).pop();
    final data = await readBytes();
    if (file != null && !kIsWeb) {
      await Share.shareXFiles([XFile(file!.path)], text: reportTitle);
      return;
    }
    await Printing.sharePdf(bytes: data, filename: fileName);
  }

  Future<void> _preview(BuildContext context) async {
    Navigator.of(context).pop();
    final data = await readBytes();
    await Printing.layoutPdf(onLayout: (_) async => data, name: reportTitle);
  }

  Future<void> _saveAs(BuildContext context) async {
    Navigator.of(context).pop();
    final data = await readBytes();
    await Printing.sharePdf(bytes: data, filename: fileName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceLg),
      child: Row(
        children: [
          Expanded(
            child: _ActionTile(
              icon: CupertinoIcons.eye,
              label: l10n.pdfPreviewPrint,
              color: AppColors.primaryMid,
              onTap: () => _preview(context),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: _ActionTile(
              icon: CupertinoIcons.share,
              label: l10n.pdfShare,
              color: AppColors.accentGreen,
              onTap: () => _share(context),
            ),
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: _ActionTile(
              icon: CupertinoIcons.arrow_down_to_line,
              label: l10n.pdfSave,
              color: AppColors.accentOrange,
              onTap: () => _saveAs(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Ink(
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spaceSm,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
