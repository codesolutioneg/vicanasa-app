import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/widgets/month_closing_banner.dart';
import '../../domain/dashboard_metrics.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/dashboard_balance_cards.dart';
import '../widgets/dashboard_charts_section.dart';
import '../widgets/dashboard_grouped_sheet.dart';
import '../widgets/dashboard_main_kpis.dart';
import '../widgets/dashboard_ratio_cards.dart';
import '../widgets/dashboard_summary_table.dart';
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

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat.yMMMd();
    return BlocListener<FilterCubit, FilterState>(
      listener: (_, __) => _load(),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardError) {
            return ErrorRetry(message: state.message, onRetry: _load);
          }
          final data = (state as DashboardLoaded).data;
          final filter = context.read<FilterCubit>().state;
          final level = data['analysis_level'] as String? ?? 'none';
          final capped = data['data_capped'] == true;
          final revenueGrouped = _groups(data['revenue_grouped']);
          final costGrouped = _groups(data['cost_grouped']);
          final expenseGrouped = _groups(data['expense_grouped']);
          final allowedIds = _allowedIds(data['allowed_group_ids']);
          final monthly = _groups(data['monthly_data']);
          final ratios = DashboardMetrics.ratios(data);
          final profitDist = DashboardMetrics.profitDistribution(data);

          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Financial Dashboard', style: AppTextStyles.headlineLg),
                const SizedBox(height: 4),
                Text(
                  '${fmt.format(filter.dateFrom)} → ${fmt.format(filter.dateTo)}',
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppDimensions.spaceMd),
                if (capped && data['closed_display_text'] != null)
                  MonthClosingBanner(period: '${data['closed_display_text']}'),
                DashboardMainKpis(
                  revenue: _n(data['revenue']),
                  cost: _n(data['cost']),
                  expense: _n(data['expense']),
                  netProfit: _n(data['net_profit']),
                  partnerShare: _n(data['partner_share']),
                  revenueGrouped: revenueGrouped,
                  onRevenueTap: level != 'none'
                      ? () => showDashboardGroupedSheet(
                            context,
                            title: 'Revenue Analysis',
                            headerColor: AppColors.accentGreen,
                            groups: revenueGrouped,
                            analysisLevel: level,
                            allowedGroupIds: allowedIds,
                            grandTotal: _n(data['revenue']),
                            grandLabel: 'Total Revenue',
                          )
                      : null,
                  onDeductionsTap: level != 'none'
                      ? () => showDeductionsSheet(
                            context,
                            costGrouped: costGrouped,
                            expenseGrouped: expenseGrouped,
                            costTotal: _n(data['cost']),
                            expenseTotal: _n(data['expense']),
                            analysisLevel: level,
                            allowedGroupIds: allowedIds,
                          )
                      : null,
                ),
                const SizedBox(height: AppDimensions.spaceMd),
                DashboardBalanceCards(
                  capitalBalance: _n(data['capital_balance']),
                  distributionBalance: _n(data['distribution_balance']),
                ),
                const SizedBox(height: AppDimensions.spaceLg),
                DashboardRatioCards(
                  expenseRatio: ratios.expenseRatio,
                  costRatio: ratios.costRatio,
                  otherIncomeRatio: ratios.otherIncomeRatio,
                  profitMargin: ratios.profitMargin,
                  partnerMargin: ratios.partnerMargin,
                  sharePercentage: _n(data['share_percentage']),
                ),
                const SizedBox(height: AppDimensions.spaceLg),
                DashboardChartsSection(
                  monthlyList: monthly,
                  yourShare: profitDist.yourShare,
                  companyShare: profitDist.companyShare,
                  totalProfit: profitDist.totalProfit,
                  isLoss: profitDist.isLoss,
                ),
                const SizedBox(height: AppDimensions.spaceLg),
                DashboardSummaryTable(
                  revenue: _n(data['revenue']),
                  cost: _n(data['cost']),
                  grossProfit: _n(data['gross_profit']),
                  expense: _n(data['expense']),
                  netProfit: _n(data['net_profit']),
                  partnerShare: _n(data['partner_share']),
                  sharePercentage: _n(data['share_percentage']),
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
