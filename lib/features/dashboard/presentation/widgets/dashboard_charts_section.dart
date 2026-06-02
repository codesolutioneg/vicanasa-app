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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Monthly Revenue & Profit Trend', style: AppTextStyles.headlineSm),
        const SizedBox(height: AppDimensions.spaceSm),
        LiquidGlassCard(
          addTealShimmer: true,
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 220,
            child: monthlyList.isEmpty
                ? const Center(child: Text('No monthly data'))
                : LineChart(_trendChart(monthlyList)),
          ),
        ),
        const SizedBox(height: AppDimensions.spaceLg),
        Text('Profit Distribution', style: AppTextStyles.headlineSm),
        const SizedBox(height: AppDimensions.spaceSm),
        LiquidGlassCard(
          addTealShimmer: true,
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            height: 220,
            child: _ProfitPie(
              yourShare: yourShare,
              companyShare: companyShare,
              totalProfit: totalProfit,
              isLoss: isLoss,
            ),
          ),
        ),
      ],
    );
  }

  LineChartData _trendChart(List<Map<String, dynamic>> monthly) {
    List<FlSpot> revSpots = [];
    List<FlSpot> costSpots = [];
    List<FlSpot> profitSpots = [];
    for (var i = 0; i < monthly.length; i++) {
      final m = monthly[i];
      final x = i.toDouble();
      revSpots.add(FlSpot(x, _n(m['revenue'])));
      final cost = _n(m['cost']);
      final expense = _n(m['expense']);
      costSpots.add(FlSpot(x, cost + expense));
      profitSpots.add(FlSpot(x, _n(m['net_profit'])));
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (_) =>
            FlLine(color: Colors.black.withValues(alpha: 0.05)),
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
                  style: const TextStyle(fontSize: 9),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 48,
            getTitlesWidget: (v, _) => Text(
              AppFormatters.currency.format(v),
              style: const TextStyle(fontSize: 8),
            ),
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        _line(revSpots, AppColors.kpiRevenue, fill: true),
        _line(costSpots, AppColors.kpiExpense, width: 2),
        _line(profitSpots, AppColors.kpiProfit, width: 3),
      ],
    );
  }

  LineChartBarData _line(
    List<FlSpot> spots,
    Color color, {
    bool fill = false,
    double width = 2,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: width,
      dotData: const FlDotData(show: false),
      belowBarData: fill
          ? BarAreaData(
              show: true,
              color: color.withValues(alpha: 0.1),
            )
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

  @override
  Widget build(BuildContext context) {
    final total = yourShare + companyShare;
    if (total <= 0) {
      return const Center(child: Text('No profit data'));
    }
    final yourColor = isLoss ? AppColors.accentRed : AppColors.primaryMid;
    final companyColor = isLoss ? AppColors.primaryPale : AppColors.primaryDark;

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 56,
            sections: [
              PieChartSectionData(
                value: yourShare,
                color: yourColor,
                title: '',
                radius: 40,
              ),
              PieChartSectionData(
                value: companyShare,
                color: companyColor,
                title: '',
                radius: 40,
              ),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isLoss ? 'Total Loss' : 'Total Profit',
              style: AppTextStyles.caption,
            ),
            Text(
              AppFormatters.money(totalProfit),
              style: AppTextStyles.kpiValue.copyWith(
                color: isLoss ? AppColors.accentRed : AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Positioned(
          bottom: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(
                isLoss ? 'Your Loss' : 'Your Share',
                yourColor,
                yourShare,
              ),
              const SizedBox(width: 16),
              _legend(
                isLoss ? 'Company Loss' : 'Company Share',
                companyColor,
                companyShare,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legend(String label, Color color, double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text('$label: ${AppFormatters.money(value)}', style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}
