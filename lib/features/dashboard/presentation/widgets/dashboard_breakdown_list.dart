import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../core/utils/app_formatters.dart';

/// Clean P&L flow as a colored-dot list (fintech analytics style).
class DashboardBreakdownList extends StatelessWidget {
  const DashboardBreakdownList({
    super.key,
    required this.revenue,
    required this.cost,
    required this.grossProfit,
    required this.expense,
    required this.netProfit,
  });

  final double revenue;
  final double cost;
  final double grossProfit;
  final double expense;
  final double netProfit;

  @override
  Widget build(BuildContext context) {
    final base = revenue > 0 ? revenue : 1.0;
    final items = <_BreakdownItem>[
      _BreakdownItem('Revenue', revenue, AppColors.kpiRevenue, revenue / base),
      _BreakdownItem('Direct Cost', cost, AppColors.kpiCost, cost / base),
      _BreakdownItem('Gross Profit', grossProfit, const Color(0xFF34D399),
          grossProfit / base),
      _BreakdownItem('Expenses', expense, AppColors.kpiExpense, expense / base),
      _BreakdownItem('Net Profit', netProfit, AppColors.kpiProfit,
          netProfit / base),
    ];

    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Breakdown', style: AppTextStyles.headlineSm),
              const Spacer(),
              Text('vs Revenue', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < items.length; i++) ...[
            if (i != 0) const SizedBox(height: 16),
            _row(items[i]),
          ],
        ],
      ),
    );
  }

  Widget _row(_BreakdownItem item) {
    final pct = (item.fraction.abs() * 100).clamp(0.0, 100.0);
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    AppFormatters.money(item.value),
                    style: AppTextStyles.financial.copyWith(fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 5,
                  backgroundColor: AppColors.bgTertiary,
                  color: item.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BreakdownItem {
  const _BreakdownItem(this.label, this.value, this.color, this.fraction);
  final String label;
  final double value;
  final Color color;
  final double fraction;
}
