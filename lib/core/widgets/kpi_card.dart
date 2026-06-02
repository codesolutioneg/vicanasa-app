import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/liquid_glass.dart';
import '../utils/app_formatters.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.color = AppColors.kpiProfit,
    this.onTap,
  });

  final String label;
  final double value;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: LiquidGlassCard(
        addTealShimmer: true,
        padding: const EdgeInsets.all(AppDimensions.spaceSm + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPale,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
                  ),
                  child: Icon(CupertinoIcons.chart_bar_alt_fill, size: 18, color: color),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(label, style: AppTextStyles.kpiLabel)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AppFormatters.money(value),
              style: AppTextStyles.kpiValue.copyWith(color: color, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
