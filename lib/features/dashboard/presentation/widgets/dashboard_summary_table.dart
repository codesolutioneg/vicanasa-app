import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../core/utils/app_formatters.dart';

class DashboardSummaryTable extends StatelessWidget {
  const DashboardSummaryTable({
    super.key,
    required this.revenue,
    required this.cost,
    required this.grossProfit,
    required this.expense,
    required this.netProfit,
    required this.partnerShare,
    required this.sharePercentage,
  });

  final double revenue;
  final double cost;
  final double grossProfit;
  final double expense;
  final double netProfit;
  final double partnerShare;
  final double sharePercentage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Financial Summary', style: AppTextStyles.headlineSm),
        const SizedBox(height: AppDimensions.spaceSm),
        LiquidGlassCard(
          padding: const EdgeInsets.all(20),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(1),
            },
            children: [
              _row('Gross Revenue', AppFormatters.money(revenue)),
              _row('Less: Cost of Goods Sold', AppFormatters.moneyParen(cost),
                  valueColor: AppColors.accentRed),
              _row('Gross Profit', AppFormatters.money(grossProfit), bold: true),
              _row('Less: Operating Expenses', AppFormatters.moneyParen(expense),
                  valueColor: AppColors.accentRed),
              _row('Net Profit', AppFormatters.money(netProfit), bold: true),
              _row(
                'Your Share (${AppFormatters.percent1.format(sharePercentage)}%)',
                AppFormatters.money(partnerShare),
                bold: true,
                valueColor: AppColors.primaryMid,
                highlight: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _row(
    String label,
    String value, {
    bool bold = false,
    Color? valueColor,
    bool highlight = false,
  }) {
    final style =
        bold ? AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.bold) : AppTextStyles.bodyMd;
    final valStyle = style.copyWith(color: valueColor ?? AppColors.textPrimary);
    return TableRow(
      decoration: highlight
          ? BoxDecoration(color: AppColors.primaryPale.withValues(alpha: 0.5))
          : null,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(label, style: style),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(value, style: valStyle, textAlign: TextAlign.end),
        ),
      ],
    );
  }
}
