import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/branch_share_line.dart';
import '../../domain/dashboard_metrics.dart';
import 'dashboard_hero_branch_column.dart';

/// Fintech-style hero: net profit + per-branch Revenue / My Share (same order).
class DashboardHeroCard extends StatelessWidget {
  const DashboardHeroCard({
    super.key,
    required this.netProfit,
    required this.revenue,
    required this.branchShares,
    required this.isLoss,
  });

  final double netProfit;
  final double revenue;
  final List<BranchShareLine> branchShares;
  final bool isLoss;

  bool get _expand => branchShares.length > 3;

  @override
  Widget build(BuildContext context) {
    final totalShare = DashboardMetrics.totalBranchShare(branchShares);
    final totalRevenue = branchShares.any((l) => l.revenue != 0)
        ? DashboardMetrics.totalBranchRevenue(branchShares)
        : revenue;

    final revenueCol = DashboardHeroBranchColumn(
      title: 'Revenue',
      icon: CupertinoIcons.chart_bar_alt_fill,
      lines: branchShares,
      total: totalRevenue,
      lineBuilder: heroRevenueLine,
    );
    final shareCol = DashboardHeroBranchColumn(
      title: 'My Share',
      icon: CupertinoIcons.person_fill,
      lines: branchShares,
      total: totalShare,
      lineBuilder: heroShareLine,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMid.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isLoss ? 'Net Loss' : 'Net Profit',
                style: AppTextStyles.bodyMd.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _marginBadge(),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              AppFormatters.money(netProfit.abs()),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_expand) ...[
            revenueCol,
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.20)),
            const SizedBox(height: 12),
            shareCol,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: revenueCol),
                Container(
                  width: 1,
                  constraints: BoxConstraints(
                    minHeight: 56,
                    maxHeight: 28.0 + branchShares.length * 40,
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.white.withValues(alpha: 0.20),
                ),
                Expanded(child: shareCol),
              ],
            ),
        ],
      ),
    );
  }

  Widget _marginBadge() {
    final margin = revenue > 0 ? netProfit / revenue * 100 : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLoss
                ? CupertinoIcons.arrow_down_right
                : CupertinoIcons.arrow_up_right,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '${AppFormatters.percent1.format(margin.abs())}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
