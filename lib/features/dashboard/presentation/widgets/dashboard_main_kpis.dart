import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/portal_kpi_card.dart';

class DashboardMainKpis extends StatelessWidget {
  const DashboardMainKpis({
    super.key,
    required this.revenue,
    required this.cost,
    required this.expense,
    required this.netProfit,
    required this.partnerShare,
    required this.capitalBalance,
    required this.sharePercentage,
    this.onRevenueTap,
    this.onDeductionsTap,
  });

  final double revenue;
  final double cost;
  final double expense;
  final double netProfit;
  final double partnerShare;
  final double capitalBalance;
  final double sharePercentage;
  final VoidCallback? onRevenueTap;
  final VoidCallback? onDeductionsTap;

  String? _pctOfRevenue(double part) {
    if (revenue <= 0) return null;
    return '${AppFormatters.percent1.format(part / revenue * 100)}% of revenue';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossCount = width >= 1200
        ? 6
        : width >= 900
            ? 3
            : 2;
    final aspect = crossCount >= 6
        ? 1.4
        : crossCount == 3
            ? 1.55
            : 1.5;

    final margin = revenue > 0 ? netProfit / revenue * 100 : 0.0;
    final cards = [
      PortalKpiCard(
        label: 'Revenue',
        value: revenue,
        icon: CupertinoIcons.arrow_up_right,
        iconColor: AppColors.kpiRevenue,
        iconBackground: const Color(0xFFEFF6FF),
        onTap: onRevenueTap,
      ),
      PortalKpiCard(
        label: 'Direct Cost',
        value: cost,
        icon: CupertinoIcons.doc_text,
        iconColor: AppColors.kpiCost,
        iconBackground: const Color(0xFFFFF7ED),
        subtitle: _pctOfRevenue(cost),
        onTap: onDeductionsTap,
      ),
      PortalKpiCard(
        label: 'Expenses',
        value: expense,
        icon: CupertinoIcons.creditcard,
        iconColor: AppColors.kpiExpense,
        iconBackground: const Color(0xFFFEF2F2),
        subtitle: _pctOfRevenue(expense),
        onTap: onDeductionsTap,
      ),
      PortalKpiCard(
        label: 'Net Profit',
        value: netProfit,
        icon: CupertinoIcons.money_dollar_circle_fill,
        iconColor: AppColors.kpiProfit,
        iconBackground: const Color(0xFFECFDF5),
        subtitle: revenue > 0
            ? '${AppFormatters.percent1.format(margin)}% margin'
            : null,
      ),
      PortalKpiCard(
        label: 'My Share',
        value: partnerShare,
        icon: CupertinoIcons.person_fill,
        iconColor: AppColors.kpiShare,
        iconBackground: const Color(0xFFF5F3FF),
        valueColor: AppColors.primaryMid,
        subtitle: sharePercentage > 0
            ? '${AppFormatters.percent1.format(sharePercentage)}% ownership'
            : null,
      ),
      PortalKpiCard(
        label: 'Capital',
        value: capitalBalance,
        icon: CupertinoIcons.building_2_fill,
        iconColor: AppColors.kpiCapital,
        iconBackground: const Color(0xFFECFEFF),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossCount,
        mainAxisSpacing: AppDimensions.spaceMd,
        crossAxisSpacing: AppDimensions.spaceMd,
        childAspectRatio: aspect,
      ),
      itemCount: cards.length,
      itemBuilder: (_, i) => cards[i],
    );
  }
}
