import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../core/utils/app_formatters.dart';

class DashboardWaterfall extends StatelessWidget {
  const DashboardWaterfall({
    super.key,
    required this.revenue,
    required this.cost,
    required this.grossProfit,
    required this.expense,
    required this.netProfit,
    required this.partnerShare,
  });

  final double revenue;
  final double cost;
  final double grossProfit;
  final double expense;
  final double netProfit;
  final double partnerShare;

  @override
  Widget build(BuildContext context) {
    final steps = [
      _Step('Revenue', revenue, AppColors.kpiRevenue, false),
      _Step('Cost', cost, AppColors.kpiCost, true),
      _Step('Gross', grossProfit, const Color(0xFF34D399), false),
      _Step('Expenses', expense, AppColors.accentOrange, true),
      _Step('Net Profit', netProfit, AppColors.kpiProfit, false),
      _Step('My Share', partnerShare, AppColors.primaryDark, false),
    ];
    final maxVal = revenue > 0 ? revenue : steps.map((s) => s.amount).fold(0.0, (a, b) => a > b ? a : b);

    return LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profit Waterfall', style: AppTextStyles.headlineSm),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: steps.map((s) {
                final h = maxVal > 0 ? (s.amount / maxVal).clamp(0.08, 1.0) : 0.08;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: h,
                              widthFactor: 0.65,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: s.color,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.label,
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          s.negative
                              ? AppFormatters.moneyParen(s.amount)
                              : AppFormatters.money(s.amount),
                          style: AppTextStyles.captionBold.copyWith(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Step {
  const _Step(this.label, this.amount, this.color, this.negative);
  final String label;
  final double amount;
  final Color color;
  final bool negative;
}
