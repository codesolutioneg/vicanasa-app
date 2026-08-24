import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import 'analysis_group_card.dart';
import 'analysis_popup_bits.dart';
import 'analysis_popup_shell.dart';

Future<void> showDashboardGroupedSheet(
  BuildContext context, {
  required String title,
  required Color headerColor,
  required List<Map<String, dynamic>> groups,
  required String analysisLevel,
  required List<int> allowedGroupIds,
  required double grandTotal,
  required String grandLabel,
}) {
  return showAnalysisPopup(
    context,
    title: title,
    headerColor: headerColor,
    headerIcon: CupertinoIcons.chart_bar_alt_fill,
    body: (_) {
      if (groups.isEmpty) {
        return [analysisEmptyState('No revenue in this period')];
      }
      return [
        for (final g in groups)
          AnalysisGroupCard(
            group: Map<String, dynamic>.from(g),
            themeColor: headerColor,
            analysisLevel: analysisLevel,
            allowedGroupIds: allowedGroupIds,
          ),
        analysisGrandTotal(
          label: grandLabel,
          total: grandTotal,
          color: headerColor,
        ),
      ];
    },
  );
}

Future<void> showDeductionsSheet(
  BuildContext context, {
  required List<Map<String, dynamic>> costGrouped,
  required List<Map<String, dynamic>> expenseGrouped,
  required double costTotal,
  required double expenseTotal,
  required String analysisLevel,
  required List<int> allowedGroupIds,
  required double salesBase,
}) {
  final base = salesBase > 0 ? salesBase : 1.0;

  return showAnalysisPopup(
    context,
    title: 'Expenses Analysis',
    headerColor: AppColors.accentRed,
    headerIcon: CupertinoIcons.arrow_down_right,
    body: (_) {
      if (costGrouped.isEmpty && expenseGrouped.isEmpty) {
        return [analysisEmptyState('No deductions in this period')];
      }

      final children = <Widget>[];
      if (costGrouped.isNotEmpty) {
        children
          ..add(analysisSectionTitle(
            icon: CupertinoIcons.cube_box_fill,
            title: 'Cost of Goods Sold',
            color: AppColors.accentRed,
          ))
          ..addAll([
            for (final g in costGrouped)
              AnalysisGroupCard(
                group: Map<String, dynamic>.from(g),
                themeColor: AppColors.accentRed,
                analysisLevel: analysisLevel,
                allowedGroupIds: allowedGroupIds,
                revenueBase: base,
                showRevPercent: true,
              ),
          ])
          ..add(analysisSectionTotal(
            label: 'Total Cost of Goods Sold',
            total: costTotal,
            color: AppColors.accentRed,
            percent: costTotal / base * 100,
          ));
      }

      if (expenseGrouped.isNotEmpty) {
        children
          ..add(analysisSectionTitle(
            icon: CupertinoIcons.doc_text_fill,
            title: 'Operating Expenses',
            color: AppColors.accentOrange,
          ))
          ..addAll([
            for (final g in expenseGrouped)
              AnalysisGroupCard(
                group: Map<String, dynamic>.from(g),
                themeColor: AppColors.accentOrange,
                analysisLevel: analysisLevel,
                allowedGroupIds: allowedGroupIds,
                revenueBase: base,
                showRevPercent: true,
              ),
          ])
          ..add(analysisSectionTotal(
            label: 'Total Operating Expenses',
            total: expenseTotal,
            color: AppColors.accentOrange,
            percent: expenseTotal / base * 100,
          ));
      }

      children.add(analysisGrandTotal(
        label: 'Total Deductions',
        total: costTotal + expenseTotal,
        color: AppColors.accentRed,
      ));
      return children;
    },
  );
}
