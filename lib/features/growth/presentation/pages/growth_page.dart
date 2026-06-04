import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/shimmer/shimmer.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

class GrowthPage extends StatefulWidget {
  const GrowthPage({super.key});

  @override
  State<GrowthPage> createState() => _GrowthPageState();
}

class _GrowthPageState extends State<GrowthPage> {
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
    final result = await sl<FinancialRepository>().getGrowth(
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
      child: Builder(
        builder: (context) {
          if (_loading) return const GrowthPageShimmer();
          if (_error != null) return ErrorRetry(message: _error!, onRetry: _load);

          final growth = _data!['growth_data'] as List? ?? [];
          return ListView(
            primary: false,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: LiquidGlassCard(
                      child: Column(
                        children: [
                          Text('YoY Revenue'),
                          Text('${_n(_data!['yoy_revenue_growth']).toStringAsFixed(1)}%'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LiquidGlassCard(
                      child: Column(
                        children: [
                          Text('YoY Profit Share'),
                          Text('${_n(_data!['yoy_profit_growth']).toStringAsFixed(1)}%'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LiquidGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Projected Annual', style: Theme.of(context).textTheme.titleSmall),
                    Text(
                      NumberFormat('#,##0.00').format(_n(_data!['projected_annual'])),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 220,
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          for (var i = 0; i < growth.length; i++)
                            FlSpot(
                              i.toDouble(),
                              _n(Map<String, dynamic>.from(growth[i] as Map)['partner_share']),
                            ),
                        ],
                        isCurved: true,
                        color: AppColors.accentGreen,
                      ),
                    ],
                    titlesData: const FlTitlesData(show: false),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
