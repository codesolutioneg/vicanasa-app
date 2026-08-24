import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/branch_share_line.dart';
import '../../domain/dashboard_metrics.dart';
import 'dashboard_card_branch_lines.dart';
import 'dashboard_card_headline.dart';

/// Total Revenue: Sales | Other Income per branch (same sequence as hero).
class DashboardRevenueCard extends StatelessWidget {
  const DashboardRevenueCard({
    super.key,
    required this.revenue,
    required this.branchLines,
    this.onTap,
  });

  final double revenue;
  final List<BranchShareLine> branchLines;
  final VoidCallback? onTap;

  bool get _expand => branchLines.length > 3;

  @override
  Widget build(BuildContext context) {
    final tappable = onTap != null;
    final salesTotal = DashboardMetrics.totalBranchSales(branchLines);
    final otherTotal = DashboardMetrics.totalBranchOtherIncome(branchLines);
    final salesCol = DashboardCardBranchLines(
      title: 'SALES',
      lines: branchLines,
      amountOf: (l) => l.sales,
      accent: AppColors.accentGreen,
      showTotal: true,
      total: salesTotal,
    );
    final otherCol = DashboardCardBranchLines(
      title: 'OTHER INCOME',
      lines: branchLines,
      amountOf: (l) => l.otherIncome,
      accent: AppColors.accentBlue,
      showTotal: true,
      total: otherTotal,
    );

    return Material(
      color: AppColors.bgSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: tappable
              ? AppColors.accentGreen.withValues(alpha: 0.35)
              : AppColors.cardBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.accentGreen.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(tappable),
              if (branchLines.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderLight,
                ),
                const SizedBox(height: 10),
                if (_expand) ...[
                  salesCol,
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 12),
                  otherCol,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: salesCol),
                      Container(
                        width: 1,
                        constraints: BoxConstraints(
                          minHeight: 56,
                          maxHeight: 28.0 + branchLines.length * 40,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: AppColors.borderLight,
                      ),
                      Expanded(child: otherCol),
                    ],
                  ),
              ],
              if (tappable) ...[
                const SizedBox(height: 8),
                Text(
                  'Tap for details',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(bool tappable) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            CupertinoIcons.chart_bar_alt_fill,
            size: 18,
            color: AppColors.accentGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardCardHeadline(
                text: 'TOTAL REVENUE',
                color: AppColors.accentGreen,
                trailing: tappable
                    ? Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: AppColors.accentGreen.withValues(alpha: 0.8),
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  AppFormatters.money(revenue),
                  style: AppTextStyles.kpiValue.copyWith(
                    fontSize: 22,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
