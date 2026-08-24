import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/comparison_card_data.dart';

class ComparisonResultCard extends StatelessWidget {
  const ComparisonResultCard({super.key, required this.data});

  final ComparisonCardData data;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      addTealShimmer: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.label,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          _MetricRow(
            label: 'Revenue',
            value: data.revenue,
            color: AppColors.kpiRevenue,
          ),
          _MetricRow(
            label: 'Net Profit',
            value: data.netProfit,
            color: AppColors.kpiProfit,
          ),
          _MetricRow(
            label: 'Your Share',
            value: data.partnerShare,
            color: AppColors.primaryMid,
          ),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            AppFormatters.money(value),
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
