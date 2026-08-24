import 'package:flutter/cupertino.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/branch_share_line.dart';
import 'dashboard_metric_branch_card.dart';

/// Overview metrics with the same per-branch sequence as Revenue / Deductions.
class DashboardMainKpis extends StatelessWidget {
  const DashboardMainKpis({
    super.key,
    required this.revenue,
    required this.netProfit,
    required this.myShare,
    required this.capitalBalance,
    required this.distributionBalance,
    required this.branchLines,
  });

  final double revenue;
  final double netProfit;
  final double myShare;
  final double capitalBalance;
  final double distributionBalance;
  final List<BranchShareLine> branchLines;

  @override
  Widget build(BuildContext context) {
    final margin = revenue > 0 ? netProfit / revenue * 100 : 0.0;
    return Column(
      children: [
        DashboardMetricBranchCard(
          title: 'NET PROFIT',
          total: netProfit,
          branchLines: branchLines,
          amountOf: (l) => l.netProfit,
          accent: AppColors.kpiProfit,
          icon: CupertinoIcons.money_dollar_circle_fill,
          iconBackground: const Color(0xFFECFDF5),
          subtitle: revenue > 0
              ? '${AppFormatters.percent1.format(margin)}% margin'
              : null,
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        DashboardMetricBranchCard(
          title: 'MY SHARE',
          total: myShare,
          branchLines: branchLines,
          amountOf: (l) => l.branchShare,
          accent: AppColors.kpiShare,
          icon: CupertinoIcons.person_fill,
          iconBackground: const Color(0xFFF5F3FF),
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        DashboardMetricBranchCard(
          title: 'CAPITAL',
          total: capitalBalance,
          branchLines: branchLines,
          amountOf: (l) => l.capital,
          accent: AppColors.kpiCapital,
          icon: CupertinoIcons.building_2_fill,
          iconBackground: const Color(0xFFECFEFF),
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        DashboardMetricBranchCard(
          title: 'DISTRIBUTIONS',
          total: distributionBalance,
          branchLines: branchLines,
          amountOf: (l) => l.distribution,
          accent: AppColors.kpiDistrib,
          icon: CupertinoIcons.arrow_right_arrow_left,
          iconBackground: const Color(0xFFFDF2F8),
        ),
      ],
    );
  }
}
