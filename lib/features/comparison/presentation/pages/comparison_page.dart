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
import '../../../../l10n/app_localizations.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});

  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = true;
  List<int> _years = [];

  @override
  void initState() {
    super.initState();
    final y = DateTime.now().year;
    _years = [y - 2, y - 1, y];
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final filter = context.read<FilterCubit>().state;
    final result = await sl<FinancialRepository>().getComparison(
      years: _years,
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
        _years = (d['selected_years'] as List?)?.cast<int>() ?? _years;
        _error = null;
        _loading = false;
      }),
    );
  }

  double _n(dynamic v) => (v as num?)?.toDouble() ?? 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return ErrorRetry(message: _error!, onRetry: _load);

    final rows = _data!['comparison_data'] as List? ?? [];
    final available = (_data!['available_years'] as List?)?.cast<int>() ?? [];

    return ListView(
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      children: [
        LiquidGlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(CupertinoIcons.chart_bar_alt_fill, color: AppColors.primaryMid),
                  const SizedBox(width: AppDimensions.spaceSm),
                  Text(l10n.selectYears, style: AppTextStyles.headlineSm),
                ],
              ),
              const SizedBox(height: AppDimensions.spaceSm),
              Wrap(
                spacing: AppDimensions.spaceSm,
                runSpacing: AppDimensions.spaceSm,
                children: available.map((y) {
                  final selected = _years.contains(y);
                  return FilterChip(
                    label: Text('$y'),
                    selected: selected,
                    selectedColor: AppColors.primaryPale,
                    checkmarkColor: AppColors.primaryDark,
                    onSelected: (s) {
                      setState(() {
                        if (s) {
                          _years = [..._years, y]..sort();
                        } else if (_years.length > 1) {
                          _years = _years.where((e) => e != y).toList();
                        }
                      });
                      _load();
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        ...rows.map((r) {
          final m = Map<String, dynamic>.from(r as Map);
          final year = m['year'];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
            child: LiquidGlassCard(
              addTealShimmer: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$year',
                    style: AppTextStyles.headlineMd.copyWith(color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: AppDimensions.spaceMd),
                  _MetricRow(
                    label: l10n.kpiRevenue,
                    value: _n(m['revenue']),
                    color: AppColors.kpiRevenue,
                  ),
                  _MetricRow(
                    label: l10n.kpiNetProfit,
                    value: _n(m['net_profit']),
                    color: AppColors.kpiProfit,
                  ),
                  _MetricRow(
                    label: l10n.kpiPartnerShare,
                    value: _n(m['partner_share']),
                    color: AppColors.primaryMid,
                  ),
                ],
              ),
            ),
          );
        }),
        if (rows.isEmpty)
          LiquidGlassCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.spaceLg),
                child: Text(l10n.noData, style: AppTextStyles.bodyMd),
              ),
            ),
          ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: AppDimensions.spaceSm),
          Expanded(child: Text(label, style: AppTextStyles.bodyMd)),
          Text(
            AppFormatters.money(value),
            style: AppTextStyles.financial.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
