import 'package:flutter/material.dart';

import '../theme/app_fonts.dart';
import '../theme/app_text_styles.dart';

/// Bilingual labels from Odoo often arrive as `Arabic - English`.
/// UI shows English on the left and Arabic on the right.
abstract final class BilingualDisplay {
  BilingualDisplay._();

  /// `أبريل - April 2026` → `April 2026 - أبريل`
  static String swapMonthLabel(String apiName) {
    final sep = apiName.indexOf(' - ');
    if (sep < 0) return apiName;
    final ar = apiName.substring(0, sep).trim();
    final en = apiName.substring(sep + 3).trim();
    if (ar.isEmpty || en.isEmpty) return apiName;
    return '$en - $ar';
  }

  /// Odoo `Arabic - English` → English only (`April 2026`).
  static String englishMonthLabel(String apiName) {
    final sep = apiName.indexOf(' - ');
    if (sep < 0) return apiName.trim();
    final left = apiName.substring(0, sep).trim();
    final right = apiName.substring(sep + 3).trim();
    if (right.isEmpty) return left;
    // API order is Arabic - English.
    return right;
  }

  /// Month option label with EN left / AR right (stable in RTL app).
  static Widget monthLabel(String apiName, {TextStyle? style}) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        swapMonthLabel(apiName),
        style: style,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Account row without amount: code right, Arabic name left-of-center (RTL).
  static Widget accountLine({
    required String code,
    required String name,
    TextStyle? codeStyle,
    TextStyle? nameStyle,
    int maxLines = 2,
  }) {
    return accountAmountRow(
      code: code,
      name: name,
      amountText: '',
      codeStyle: codeStyle,
      nameStyle: nameStyle,
      maxLines: maxLines,
      showAmount: false,
    );
  }

  /// Financial account row (RTL): code يمين — اسم عربي وسط — مبلغ شمال.
  static Widget accountAmountRow({
    required String code,
    required String name,
    required String amountText,
    TextStyle? codeStyle,
    TextStyle? nameStyle,
    TextStyle? amountStyle,
    int maxLines = 2,
    bool showAmount = true,
  }) {
    final codeText = code.trim();
    final nameText = name.trim();
    final amount = amountText.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (codeText.isNotEmpty)
            Text(
              codeText,
              style: codeStyle ?? AppTextStyles.bodySm,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (codeText.isNotEmpty && nameText.isNotEmpty)
            const SizedBox(width: 10),
          if (nameText.isNotEmpty)
            Expanded(
              child: Text(
                nameText,
                style: (nameStyle ?? AppTextStyles.bodySm).copyWith(
                  fontFamily: AppFonts.tajawal,
                ),
                textAlign: TextAlign.center,
                maxLines: maxLines,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (showAmount && amount.isNotEmpty) ...[
            const SizedBox(width: 10),
            Text(
              amount,
              style: amountStyle ?? AppTextStyles.financial,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
