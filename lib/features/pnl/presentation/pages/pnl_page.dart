import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/widgets/kpi_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

class PnlPage extends StatefulWidget {
  const PnlPage({super.key});

  @override
  State<PnlPage> createState() => _PnlPageState();
}

class _PnlPageState extends State<PnlPage> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;
  int _year = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final filter = context.read<FilterCubit>().state;
    final result = await sl<FinancialRepository>().getPnl(
      year: _year,
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

  double _n(dynamic v) => (v as num?)?.toDouble() ?? 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocListener<FilterCubit, FilterState>(
      listener: (_, __) => _load(),
      child: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorRetry(message: _error!, onRetry: _load);
    final pnl = Map<String, dynamic>.from(_data!['pnl_data'] as Map? ?? {});
    final years = (_data!['available_years'] as List?)?.cast<int>() ?? [_year];

    return ListView(
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      children: [
        LiquidGlassCard(
          child: Row(
            children: [
              const Icon(CupertinoIcons.calendar, color: AppColors.primaryMid),
              const SizedBox(width: AppDimensions.spaceSm),
              Text(l10n.year, style: AppTextStyles.labelLg),
              const Spacer(),
              DropdownButton<int>(
                value: _year,
                underline: const SizedBox.shrink(),
                items: years
                    .map((y) => DropdownMenuItem(value: y, child: Text('$y')))
                    .toList(),
                onChanged: (y) {
                  if (y != null) {
                    setState(() => _year = y);
                    _load();
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        LayoutBuilder(
          builder: (context, c) {
            final w = (c.maxWidth - AppDimensions.spaceSm) / 2;
            return Wrap(
              spacing: AppDimensions.spaceSm,
              runSpacing: AppDimensions.spaceSm,
              children: [
                SizedBox(
                  width: w,
                  child: KpiCard(
                    label: l10n.kpiRevenue,
                    value: _n(pnl['total_revenue']),
                    color: AppColors.kpiRevenue,
                  ),
                ),
                SizedBox(
                  width: w,
                  child: KpiCard(
                    label: l10n.kpiCost,
                    value: _n(pnl['total_cost']),
                    color: AppColors.kpiCost,
                  ),
                ),
                SizedBox(
                  width: w,
                  child: KpiCard(
                    label: l10n.kpiGrossProfit,
                    value: _n(pnl['gross_profit']),
                    color: AppColors.kpiProfit,
                  ),
                ),
                SizedBox(
                  width: w,
                  child: KpiCard(
                    label: l10n.kpiNetProfit,
                    value: _n(pnl['net_profit']),
                    color: AppColors.kpiProfit,
                  ),
                ),
                SizedBox(
                  width: c.maxWidth,
                  child: KpiCard(
                    label: l10n.kpiPartnerShare,
                    value: _n(pnl['partner_share']),
                    color: AppColors.primaryMid,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppDimensions.spaceLg),
        _AccountSection(
          title: 'Revenue Accounts',
          accounts: pnl['revenue_accounts'],
          accent: AppColors.kpiRevenue,
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        _AccountSection(
          title: 'Cost Accounts',
          accounts: pnl['cost_accounts'],
          accent: AppColors.kpiCost,
        ),
      ],
    );
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({
    required this.title,
    required this.accounts,
    required this.accent,
  });

  final String title;
  final dynamic accounts;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final list = accounts as List? ?? [];
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              Text(title, style: AppTextStyles.headlineSm),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          if (list.isEmpty)
            Text(
              AppLocalizations.of(context)!.noData,
              style: AppTextStyles.bodyMd,
            )
          else
            ...list.map((a) {
              final m = Map<String, dynamic>.from(a as Map);
              final amount = (m['amount'] as num?)?.toDouble() ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.spaceXs),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${m['code']} ${m['name']}',
                        style: AppTextStyles.bodySm,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      AppFormatters.money(amount),
                      style: AppTextStyles.financial.copyWith(color: accent),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
