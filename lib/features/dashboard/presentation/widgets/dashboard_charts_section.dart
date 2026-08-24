import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../core/utils/app_formatters.dart';

class DashboardChartsSection extends StatelessWidget {
  const DashboardChartsSection({
    super.key,
    required this.monthlyList,
    required this.yourShare,
    required this.companyShare,
    required this.totalProfit,
    required this.isLoss,
  });

  final List<Map<String, dynamic>> monthlyList;
  final double yourShare;
  final double companyShare;
  final double totalProfit;
  final bool isLoss;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;

    final pie = LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profit Distribution', style: AppTextStyles.headlineSm),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: _ProfitPie(
              yourShare: yourShare,
              companyShare: companyShare,
              totalProfit: totalProfit,
              isLoss: isLoss,
            ),
          ),
        ],
      ),
    );

    final trend = LiquidGlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Revenue vs Cost Trend',
                  style: AppTextStyles.headlineSm,
                ),
              ),
              Text(
                'YTD',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              _legendDot(AppColors.kpiRevenue, 'Revenue'),
              const SizedBox(width: 12),
              _legendDot(AppColors.kpiExpense, 'Cost'),
              const SizedBox(width: 12),
              _legendDot(AppColors.kpiProfit, 'Profit'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: monthlyList.isEmpty
                ? const Center(child: Text('No monthly data'))
                : LineChart(_trendChart(monthlyList)),
          ),
        ],
      ),
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 1, child: pie),
          const SizedBox(width: AppDimensions.spaceMd),
          Expanded(flex: 2, child: trend),
        ],
      );
    }

    return Column(
      children: [
        pie,
        const SizedBox(height: AppDimensions.spaceMd),
        trend,
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }

  LineChartData _trendChart(List<Map<String, dynamic>> monthly) {
    final revSpots = <FlSpot>[];
    final costSpots = <FlSpot>[];
    final profitSpots = <FlSpot>[];
    var maxY = 0.0;
    for (var i = 0; i < monthly.length; i++) {
      final m = monthly[i];
      final x = i.toDouble();
      final rev = _n(m['revenue']);
      final cost = _n(m['cost']) + _n(m['expense']);
      final profit = _n(m['net_profit']);
      revSpots.add(FlSpot(x, rev));
      costSpots.add(FlSpot(x, cost));
      profitSpots.add(FlSpot(x, profit));
      maxY = [maxY, rev, cost, profit.abs()].reduce((a, b) => a > b ? a : b);
    }

    // One month → no line segment; still show dots (Odoo needs ≥2 months for a trend).
    final showDots = monthly.length <= 2;
    final maxX = monthly.length <= 1 ? 1.0 : (monthly.length - 1).toDouble();
    final chartMax = maxY <= 0 ? 1.0 : maxY * 1.1;
    final yInterval = chartMax / 5;

    return LineChartData(
      minX: 0,
      maxX: maxX,
      minY: 0,
      maxY: chartMax,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: yInterval,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: AppColors.borderLight, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= monthly.length) return const SizedBox.shrink();
              final label = '${monthly[i]['month'] ?? ''}';
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  label.length > 7 ? label.substring(5) : label,
                  style: AppTextStyles.caption.copyWith(fontSize: 9),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: yInterval,
            getTitlesWidget: (v, meta) {
              if (v < 0) return const SizedBox.shrink();
              // Skip top label clutter when it sits on maxY.
              if ((v - meta.max).abs() < yInterval * 0.05) {
                return const SizedBox.shrink();
              }
              return Text(
                AppFormatters.compactMoney(v),
                style: AppTextStyles.caption.copyWith(fontSize: 9),
                textAlign: TextAlign.right,
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        _line(revSpots, AppColors.kpiRevenue, fill: true, showDots: showDots),
        _line(
          costSpots,
          AppColors.kpiExpense,
          width: 2,
          dashed: true,
          showDots: showDots,
        ),
        _line(
          profitSpots,
          AppColors.kpiProfit,
          width: 2.5,
          showDots: showDots,
        ),
      ],
    );
  }

  LineChartBarData _line(
    List<FlSpot> spots,
    Color color, {
    bool fill = false,
    double width = 2,
    bool dashed = false,
    bool showDots = false,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: spots.length > 2,
      color: color,
      barWidth: width,
      dashArray: dashed ? [4, 4] : null,
      dotData: FlDotData(show: showDots),
      belowBarData: fill
          ? BarAreaData(show: true, color: color.withValues(alpha: 0.1))
          : BarAreaData(show: false),
    );
  }

  double _n(dynamic v) => (v as num?)?.toDouble() ?? 0;
}

class _ProfitPie extends StatelessWidget {
  const _ProfitPie({
    required this.yourShare,
    required this.companyShare,
    required this.totalProfit,
    required this.isLoss,
  });

  final double yourShare;
  final double companyShare;
  final double totalProfit;
  final bool isLoss;

  static const _palette = [
    AppColors.primaryMid,
    AppColors.accentGreen,
    AppColors.accentOrange,
  ];

  @override
  Widget build(BuildContext context) {
    final total = yourShare + companyShare;
    if (total <= 0) {
      return const Center(child: Text('No profit data'));
    }

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 56,
                  sections: [
                    PieChartSectionData(
                      value: yourShare,
                      color: isLoss ? AppColors.accentRed : _palette[0],
                      title: '',
                      radius: 36,
                    ),
                    PieChartSectionData(
                      value: companyShare,
                      color: isLoss ? AppColors.accentOrange : _palette[1],
                      title: '',
                      radius: 36,
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    AppFormatters.money(totalProfit.abs()),
                    style: AppTextStyles.kpiValue.copyWith(fontSize: 16),
                  ),
                  Text(
                    isLoss ? 'Net Loss' : 'Net Profit',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _legend(
              isLoss ? 'Your Loss' : 'Your Share',
              isLoss ? AppColors.accentRed : _palette[0],
              yourShare,
            ),
            _legend(
              isLoss ? 'Company Loss' : 'Company Share',
              isLoss ? AppColors.accentOrange : _palette[1],
              companyShare,
            ),
          ],
        ),
      ],
    );
  }

  Widget _legend(String label, Color color, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
            Text(
              AppFormatters.money(value),
              style: AppTextStyles.captionBold.copyWith(fontSize: 11),
            ),
          ],
        ),
      ],
    );
  }
}
