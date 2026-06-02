import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../core/utils/app_formatters.dart';

class DashboardMainKpis extends StatelessWidget {
  const DashboardMainKpis({
    super.key,
    required this.revenue,
    required this.cost,
    required this.expense,
    required this.netProfit,
    required this.partnerShare,
    required this.revenueGrouped,
    this.onRevenueTap,
    this.onDeductionsTap,
  });

  final double revenue;
  final double cost;
  final double expense;
  final double netProfit;
  final double partnerShare;
  final List<Map<String, dynamic>> revenueGrouped;
  final VoidCallback? onRevenueTap;
  final VoidCallback? onDeductionsTap;

  double get totalDeductions => cost + expense;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MainKpiCard(
          label: 'TOTAL REVENUE',
          value: revenue,
          icon: CupertinoIcons.arrow_up_right,
          color: AppColors.accentGreen,
          onTap: onRevenueTap,
          breakdown: revenueGrouped
              .map((g) => '${g['group_name']}: ${AppFormatters.money(_amount(g))}')
              .toList(),
        ),
        const SizedBox(height: AppDimensions.spaceSm),
        _MainKpiCard(
          label: 'TOTAL DEDUCTIONS',
          value: totalDeductions,
          icon: CupertinoIcons.arrow_down_right,
          color: AppColors.accentRed,
          onTap: onDeductionsTap,
          breakdown: [
            'Costs: ${AppFormatters.money(cost)}',
            'Expenses: ${AppFormatters.money(expense)}',
          ],
        ),
        const SizedBox(height: AppDimensions.spaceSm),
        Row(
          children: [
            Expanded(
              child: _MainKpiCard(
                label: 'COMPANY NET PROFIT',
                value: netProfit,
                icon: CupertinoIcons.building_2_fill,
                color: AppColors.kpiProfit,
                compact: true,
              ),
            ),
            const SizedBox(width: AppDimensions.spaceSm),
            Expanded(
              child: _MainKpiCard(
                label: 'YOUR PROFIT SHARE',
                value: partnerShare,
                icon: CupertinoIcons.money_dollar_circle_fill,
                color: AppColors.accentBlue,
                compact: true,
                highlight: true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _amount(Map<String, dynamic> g) =>
      (g['total_amount'] as num?)?.toDouble() ?? 0;
}

class _MainKpiCard extends StatelessWidget {
  const _MainKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.breakdown = const [],
    this.onTap,
    this.compact = false,
    this.highlight = false,
  });

  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final List<String> breakdown;
  final VoidCallback? onTap;
  final bool compact;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlassCard(
        addTealShimmer: true,
        padding: EdgeInsets.all(compact ? 12 : 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryPale,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Icon(icon, color: color, size: compact ? 22 : 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.kpiLabel),
                  const SizedBox(height: 4),
                  Text(
                    AppFormatters.money(value),
                    style: AppTextStyles.kpiValue.copyWith(
                      color: highlight ? AppColors.accentGreen : color,
                      fontSize: compact ? 16 : 22,
                    ),
                  ),
                  if (breakdown.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ...breakdown.map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(line, style: AppTextStyles.caption),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
