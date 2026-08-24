import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/shimmer/shimmer.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/widgets/month_closing_banner.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';
import '../widgets/pnl_account_section.dart';

/// P&L for the app-bar From/To range — grouped accounts by Odoo analysis level.
class PnlPage extends StatefulWidget {
  const PnlPage({super.key});

  @override
  State<PnlPage> createState() => _PnlPageState();
}

class _PnlPageState extends State<PnlPage> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final filter = context.read<FilterCubit>().state;
    final result = await sl<FinancialRepository>().getFinancialData(
      dateFrom: filter.dateFromStr,
      dateTo: filter.dateToStr,
      analyticId: filter.analyticId,
    );
    if (!mounted) return;
    result.fold(
      (f) => setState(() {
        _error = f.message;
        _loading = false;
      }),
      (d) => setState(() {
        _data = d;
        _error = null;
        _loading = false;
      }),
    );
  }

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
    final base = Theme.of(context);
    return Theme(
      data: base.copyWith(
        textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
        primaryTextTheme: GoogleFonts.cairoTextTheme(base.primaryTextTheme),
      ),
      child: BlocListener<FilterCubit, FilterState>(
        listener: (_, __) => _load(),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const PnlPageShimmer();
    if (_error != null) return ErrorRetry(message: _error!, onRetry: _load);
    final data = _data!;
    final level = '${data['analysis_level'] ?? 'none'}'.trim();
    final allowedIds = _allowedIds(data['allowed_group_ids']);
    final revenue = _groups(data['revenue_grouped']);
    final costs = _groups(data['cost_grouped']);
    final expenses = _groups(data['expense_grouped']);
    final capped = data['data_capped'] == true;

    return RefreshIndicator(
      color: AppColors.primaryMid,
      onRefresh: _load,
      child: ListView(
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        children: [
          if (capped && data['closed_display_text'] != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.spaceMd),
              child: MonthClosingBanner(
                period: '${data['closed_display_text']}',
              ),
            ),
          if (level == 'none') ...[
            _permissionBanner(
              branchSelected:
                  context.read<FilterCubit>().state.analyticId != null,
            ),
            const SizedBox(height: AppDimensions.spaceMd),
          ],
          PnlAccountSection(
            title: 'Revenue Accounts',
            groups: revenue,
            accent: AppColors.kpiRevenue,
            analysisLevel: level,
            allowedGroupIds: allowedIds,
            fallbackTotal: (data['revenue'] as num?)?.toDouble(),
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          PnlAccountSection(
            title: 'Cost Accounts',
            groups: costs,
            accent: AppColors.kpiCost,
            analysisLevel: level,
            allowedGroupIds: allowedIds,
            fallbackTotal: (data['cost'] as num?)?.toDouble(),
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          PnlAccountSection(
            title: 'Expense Accounts',
            groups: expenses,
            accent: AppColors.kpiExpense,
            analysisLevel: level,
            allowedGroupIds: allowedIds,
            fallbackTotal: (data['expense'] as num?)?.toDouble(),
            initiallyExpanded: false,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _permissionBanner({required bool branchSelected}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warningBorder.withValues(alpha: 0.4)),
      ),
      child: Text(
        branchSelected
            ? 'Branch filter is working, but this branch’s Financial analysis '
                'level in Odoo is set to none, so account names are cleared. '
                'All Branches uses the partner-level setting (all_details). '
                'Raise each branch config’s analysis level to show names.'
            : 'Your analysis level is set to none. Group and account details are hidden. '
                'Ask an administrator to raise Financial analysis level if you need P&L drill-down.',
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
