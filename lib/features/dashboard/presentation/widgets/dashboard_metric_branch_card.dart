import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/branch_share_line.dart';
import 'dashboard_card_branch_lines.dart';
import 'dashboard_card_headline.dart';

/// Overview metric with the same per-branch sequence as Revenue / Deductions.
class DashboardMetricBranchCard extends StatelessWidget {
  const DashboardMetricBranchCard({
    super.key,
    required this.title,
    required this.total,
    required this.branchLines,
    required this.amountOf,
    required this.accent,
    required this.icon,
    required this.iconBackground,
    this.subtitle,
  });

  final String title;
  final double total;
  final List<BranchShareLine> branchLines;
  final double Function(BranchShareLine line) amountOf;
  final Color accent;
  final IconData icon;
  final Color iconBackground;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            if (branchLines.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderLight,
              ),
              const SizedBox(height: 10),
              DashboardCardBranchLines(
                lines: branchLines,
                amountOf: amountOf,
                accent: accent,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardCardHeadline(text: title, color: accent),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  AppFormatters.money(total),
                  style: AppTextStyles.kpiValue.copyWith(
                    fontSize: 22,
                    color: total < 0 ? AppColors.accentRed : AppColors.textPrimary,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
