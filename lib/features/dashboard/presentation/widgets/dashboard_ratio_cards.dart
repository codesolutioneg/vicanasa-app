import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
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
  final double? sharePercentage;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Financial Ratios', style: AppTextStyles.headlineSm),
          const SizedBox(height: 16),
          _RatioBar(
            label: 'Net Profit Margin',
            value: profitMargin,
            color: AppColors.accentGreen,
          ),
          const SizedBox(height: 14),
          _RatioBar(
            label: 'Cost Ratio',
            value: costRatio,
            color: AppColors.accentOrange,
          ),
          const SizedBox(height: 14),
          _RatioBar(
            label: 'Expense Ratio',
            value: expenseRatio,
            color: AppColors.accentRed,
          ),
          if (otherIncomeRatio > 0) ...[
            const SizedBox(height: 14),
            _RatioBar(
              label: 'Other Income',
              value: otherIncomeRatio,
              color: AppColors.accentBlue,
            ),
          ],
          const SizedBox(height: 14),
          _RatioBar(
            label: sharePercentage != null
                ? 'Your Margin (${AppFormatters.percent1.format(sharePercentage!)}%)'
                : 'Your Margin',
            value: partnerMargin,
            color: AppColors.kpiShare,
          ),
        ],
      ),
    );
  }
}

class _RatioBar extends StatelessWidget {
  const _RatioBar({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final clamped = value.clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 12)),
            Text(
              '${AppFormatters.percent1.format(value)}%',
              style: AppTextStyles.captionBold.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: clamped / 100,
            minHeight: 8,
            backgroundColor: AppColors.bgTertiary,
            color: color,
          ),
        ),
      ],
    );
  }
}
