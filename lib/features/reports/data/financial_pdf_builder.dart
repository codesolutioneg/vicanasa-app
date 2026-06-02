import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// PDF layout matching Odoo [_generate_pdf_html] schema.
/// Uses Cairo (Google Fonts) for Arabic / Unicode partner names and labels.
class FinancialPdfBuilder {
  static pw.Font? _base;
  static pw.Font? _bold;

  Future<void> _ensureFonts() async {
    if (_base != null && _bold != null) return;
    _base = await PdfGoogleFonts.cairoRegular();
    _bold = await PdfGoogleFonts.cairoBold();
  }

  pw.TextStyle _ts({
    double size = 10,
    bool bold = false,
    PdfColor? color,
  }) =>
      pw.TextStyle(
        font: bold ? _bold! : _base!,
        fontSize: size,
        color: color ?? PdfColors.black,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      );

  Future<Uint8List> build({
    required String partnerName,
    required DateTime dateFrom,
    required DateTime dateTo,
    required Map<String, dynamic> financialData,
    required List<Map<String, dynamic>> branchData,
  }) async {
    await _ensureFonts();

    final revenue = _num(financialData['revenue']);
    final cost = _num(financialData['cost']);
    final expense = _num(financialData['expense']);
    final netProfit = _num(financialData['net_profit']);
    final expenseRatio = revenue > 0 ? expense / revenue * 100 : 0.0;
    final costRatio = revenue > 0 ? cost / revenue * 100 : 0.0;
    final profitMargin = revenue > 0 ? netProfit / revenue * 100 : 0.0;
    var totalShare = 0.0;
    final branchRows = <pw.TableRow>[];
    for (final branch in branchData) {
      final data = Map<String, dynamic>.from(branch['data'] as Map? ?? {});
      final net = _num(data['net_profit']);
      final pct = _num(branch['share_percentage']);
      final share = net * pct / 100;
      totalShare += share;
      branchRows.add(
        pw.TableRow(
          children: [
            pw.Text('${branch['name']}', style: _ts()),
            pw.Text('${pct.toStringAsFixed(0)}%', style: _ts()),
            pw.Text(_fmt(net), style: _ts()),
            pw.Text(_fmt(share), style: _ts()),
          ],
        ),
      );
    }

    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: _base!, bold: _bold!, italic: _base!),
        build: (ctx) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('006B6B'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              children: [
                pw.Text(
                  'Financial Report',
                  style: _ts(size: 22, bold: true, color: PdfColors.white),
                ),
                pw.SizedBox(height: 6),
                pw.Text(partnerName, style: _ts(color: PdfColors.white)),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Text(
            'Period: ${DateFormat('yyyy-MM-dd').format(dateFrom)} to '
            '${DateFormat('yyyy-MM-dd').format(dateTo)}',
            style: _ts(),
          ),
          pw.SizedBox(height: 16),
          pw.Text('Financial Ratios', style: _ts(size: 16, bold: true)),
          pw.SizedBox(height: 8),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              _ratioBox('Expense / Revenue', '${expenseRatio.toStringAsFixed(1)}%'),
              _ratioBox('COGS / Revenue', '${costRatio.toStringAsFixed(1)}%'),
              _ratioBox('Net Margin', '${profitMargin.toStringAsFixed(1)}%'),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text('Financial Summary', style: _ts(size: 16, bold: true)),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              _row('Gross Revenue', _fmt(revenue)),
              _row('Less: COGS', '(${_fmt(cost)})'),
              _row('Gross Profit', _fmt(revenue - cost)),
              _row('Less: Operating Expenses', '(${_fmt(expense)})'),
              _row('Net Profit', _fmt(netProfit), bold: true),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Text(
            'Branch Breakdown - Your Share',
            style: _ts(size: 16, bold: true),
          ),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300),
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Text('Branch', style: _ts(bold: true)),
                  pw.Text('Share %', style: _ts(bold: true)),
                  pw.Text('Net Profit', style: _ts(bold: true)),
                  pw.Text('Your Share', style: _ts(bold: true)),
                ],
              ),
              ...branchRows,
              pw.TableRow(
                children: [
                  pw.Text('TOTAL YOUR SHARE', style: _ts(bold: true)),
                  pw.Text('', style: _ts()),
                  pw.Text('', style: _ts()),
                  pw.Text(_fmt(totalShare), style: _ts(bold: true)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Generated on ${DateFormat('yyyy-MM-dd').format(DateTime.now())}',
            style: _ts(size: 10, color: PdfColors.grey),
          ),
        ],
      ),
    );
    return doc.save();
  }

  double _num(dynamic v) => (v as num?)?.toDouble() ?? 0;

  String _fmt(double v) => NumberFormat('#,##0.00').format(v);

  pw.Widget _ratioBox(String label, String value) => pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(8),
          margin: const pw.EdgeInsets.symmetric(horizontal: 4),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey400),
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Column(
            children: [
              pw.Text(label, style: _ts(size: 9)),
              pw.SizedBox(height: 4),
              pw.Text(value, style: _ts(size: 14, bold: true)),
            ],
          ),
        ),
      );

  pw.TableRow _row(String label, String value, {bool bold = false}) => pw.TableRow(
        children: [
          pw.Text(label, style: _ts(bold: bold)),
          pw.Text(value, style: _ts(bold: bold), textAlign: pw.TextAlign.right),
        ],
      );
}
