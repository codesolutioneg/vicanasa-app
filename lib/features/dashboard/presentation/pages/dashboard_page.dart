import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/shimmer/shimmer.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/widgets/month_closing_banner.dart';
import '../../domain/dashboard_metrics.dart';
import '../../domain/dashboard_monthly_trend.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/dashboard_breakdown_list.dart';
import '../widgets/dashboard_charts_section.dart';
import '../widgets/dashboard_deductions_card.dart';
import '../widgets/dashboard_grouped_sheet.dart';
import '../widgets/dashboard_hero_card.dart';
import '../widgets/dashboard_main_kpis.dart';
import '../widgets/dashboard_ratio_cards.dart';
import '../widgets/dashboard_revenue_card.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final DashboardCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = DashboardCubit(sl());
    _load();
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  void _load() => _cubit.load(context.read<FilterCubit>().state);

  double _n(dynamic v) => (v as num?)?.toDouble() ?? 0;

  List<Map<String, dynamic>> _groups(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  List<int> _allowedIds(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => (e as num).toInt()).toList();
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(text, style: AppTextStyles.headlineSm),
      );

  @override
  Widget build(BuildContext context) {
    return BlocListener<FilterCubit, FilterState>(
      listener: (_, __) => _load(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const DashboardPageShimmer();
          }
          if (state is DashboardError) {
            return ErrorRetry(message: state.message, onRetry: _load);
          }
          final data = (state as DashboardLoaded).data;
          final filter = context.read<FilterCubit>().state;
          // Odoo: none | group_totals | all_details | custom
          final level = '${data['analysis_level'] ?? 'none'}'.trim();
          final canOpenAnalysis = level.isNotEmpty && level != 'none';
          final capped = data['data_capped'] == true;
          final revenueGrouped = _groups(data['revenue_grouped']);
          final costGrouped = _groups(data['cost_grouped']);
          final expenseGrouped = _groups(data['expense_grouped']);
          final allowedIds = _allowedIds(data['allowed_group_ids']);
          final monthly = DashboardMonthlyTrend.from(data);
          final ratios = DashboardMetrics.ratios(data);
          final branchShareLines = DashboardMetrics.branchShares(
            data,
            analyticId: filter.analyticId,
          );
          final myShareTotal = branchShareLines.isNotEmpty
              ? DashboardMetrics.totalBranchShare(branchShareLines)
              : _n(data['partner_share']);
          final singleBranchPct = branchShareLines.length == 1
              ? branchShareLines.first.sharePercentage
              : null;
          final profitDist = DashboardMetrics.profitDistribution(
            data,
            analyticId: filter.analyticId,
          );
          final revenue = _n(data['revenue']);
          final cost = _n(data['cost']);
          final expense = _n(data['expense']);
          final netProfit = _n(data['net_profit']);
          final capital = _n(data['capital_balance']);

          final ratiosMap = data['ratios'] is Map
              ? Map<String, dynamic>.from(data['ratios'] as Map)
              : null;
          final salesBase = revenueGrouped.isNotEmpty
              ? DashboardMetrics.salesVal(revenueGrouped, revenue)
              : ((ratiosMap?['sales'] as num?)?.toDouble() ?? revenue);

          return RefreshIndicator(
            color: AppColors.primaryMid,
            onRefresh: () async => _load(),
            child: ListView(
              primary: false,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                if (capped && data['closed_display_text'] != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
                    child: MonthClosingBanner(period: '${data['closed_display_text']}'),
                  ),
                DashboardHeroCard(
                  netProfit: netProfit,
                  revenue: revenue,
                  branchShares: branchShareLines,
                  isLoss: profitDist.isLoss,
                ),
                const SizedBox(height: AppDimensions.spaceLg),
                _sectionTitle('Overview'),
                const SizedBox(height: AppDimensions.spaceSm),
                DashboardRevenueCard(
                  revenue: revenue,
                  branchLines: branchShareLines,
                  onTap: canOpenAnalysis
                      ? () => showDashboardGroupedSheet(
                            context,
                            title: 'Revenue Analysis',
                            headerColor: AppColors.accentGreen,
                            groups: revenueGrouped,
                            analysisLevel: level,
                            allowedGroupIds: allowedIds,
                            grandTotal: revenue,
                            grandLabel: 'Total Revenue',
                          )
                      : null,
                ),
                const SizedBox(height: AppDimensions.spaceMd),
                DashboardDeductionsCard(
                  cost: cost,
                  expense: expense,
                  branchLines: branchShareLines,
                  onTap: canOpenAnalysis
                      ? () => showDeductionsSheet(
                            context,
                            costGrouped: costGrouped,
                            expenseGrouped: expenseGrouped,
                            costTotal: cost,
                            expenseTotal: expense,
                            analysisLevel: level,
                            allowedGroupIds: allowedIds,
                            salesBase: salesBase,
                          )
                      : null,
                ),
                const SizedBox(height: AppDimensions.spaceSm),
                DashboardMainKpis(
                  revenue: revenue,
                  netProfit: netProfit,
                  myShare: myShareTotal,
                  capitalBalance: capital,
                  distributionBalance: _n(data['distribution_balance']),
                  branchLines: branchShareLines,
                ),
                const SizedBox(height: AppDimensions.spaceLg),
                _sectionTitle('Trends'),
                const SizedBox(height: AppDimensions.spaceSm),
                DashboardChartsSection(
                  monthlyList: monthly,
                  yourShare: profitDist.yourShare,
                  companyShare: profitDist.companyShare,
                  totalProfit: profitDist.totalProfit,
                  isLoss: profitDist.isLoss,
                ),
                const SizedBox(height: AppDimensions.spaceLg),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    final breakdown = DashboardBreakdownList(
                      revenue: revenue,
                      cost: cost,
                      grossProfit: _n(data['gross_profit']),
                      expense: expense,
                      netProfit: netProfit,
                    );
                    final ratiosCard = DashboardRatioCards(
                      expenseRatio: ratios.expenseRatio,
                      costRatio: ratios.costRatio,
                      otherIncomeRatio: ratios.otherIncomeRatio,
                      profitMargin: ratios.profitMargin,
                      partnerMargin: salesBase > 0
                          ? myShareTotal / salesBase * 100
                          : ratios.partnerMargin,
                      sharePercentage: singleBranchPct,
                    );
                    if (wide) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 3, child: breakdown),
                          const SizedBox(width: AppDimensions.spaceMd),
                          Expanded(flex: 2, child: ratiosCard),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        breakdown,
                        const SizedBox(height: AppDimensions.spaceMd),
                        ratiosCard,
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
