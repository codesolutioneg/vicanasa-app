import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../core/utils/app_formatters.dart';

class DashboardRatioCards extends StatelessWidget {
  const DashboardRatioCards({
    super.key,
    required this.expenseRatio,
    required this.costRatio,
    required this.otherIncomeRatio,
    required this.profitMargin,
    required this.partnerMargin,
    required this.sharePercentage,
  });

  final double expenseRatio;
  final double costRatio;
  final double otherIncomeRatio;
  final double profitMargin;
  final double partnerMargin;
  final double sharePercentage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Financial Ratios', style: AppTextStyles.headlineSm),
        const SizedBox(height: AppDimensions.spaceSm),
        _RatioCard(
          label: 'EXPENSE TO REVENUE',
          value: expenseRatio,
          description: 'Operating expenses as percentage of total revenue',
          borderColor: _expenseColor(expenseRatio),
        ),
        const SizedBox(height: 8),
        _RatioCard(
          label: 'COST OF SALES',
          value: costRatio,
          description: 'Direct costs (COGS) as percentage of total revenue',
          borderColor: _costColor(costRatio),
        ),
        const SizedBox(height: 8),
        _RatioCard(
          label: 'OTHER INCOME',
          value: otherIncomeRatio,
          description: 'Other income as percentage of sales',
          borderColor: AppColors.accentOrange,
        ),
        const SizedBox(height: 8),
        _RatioCard(
          label: 'COMPANY PROFIT MARGIN',
          value: profitMargin,
          description: 'Company net profit as percentage of revenue',
          borderColor: _profitColor(profitMargin),
        ),
        const SizedBox(height: 8),
        _RatioCard(
          label: 'YOUR PROFIT MARGIN',
          value: partnerMargin,
          description: 'Your share (${AppFormatters.percent2.format(sharePercentage)}%) of revenue',
          borderColor: AppColors.accentGreen,
          decimals: 2,
        ),
      ],
    );
  }

  Color _expenseColor(double v) =>
      v > 30 ? AppColors.accentRed : (v > 20 ? AppColors.accentOrange : AppColors.accentGreen);

  Color _costColor(double v) =>
      v > 70 ? AppColors.accentRed : (v > 50 ? AppColors.accentOrange : AppColors.accentGreen);

  Color _profitColor(double v) =>
      v > 15 ? AppColors.accentGreen : (v > 5 ? AppColors.accentOrange : AppColors.accentRed);
}

class _RatioCard extends StatelessWidget {
  const _RatioCard({
    required this.label,
    required this.value,
    required this.description,
    required this.borderColor,
    this.decimals = 1,
  });

  final String label;
  final double value;
  final String description;
  final Color borderColor;
  final int decimals;

  @override
  Widget build(BuildContext context) {
    final fmt = decimals == 2 ? AppFormatters.percent2 : AppFormatters.percent1;
    return LiquidGlassCard(
      padding: const EdgeInsets.all(14),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: borderColor, width: 4)),
        ),
        padding: const EdgeInsets.only(left: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.kpiLabel),
            const SizedBox(height: 4),
            Text(
              '${fmt.format(value)}%',
              style: AppTextStyles.kpiValue.copyWith(color: borderColor, fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(description, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
