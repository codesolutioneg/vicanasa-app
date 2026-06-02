import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_formatters.dart';

/// Fintech-style hero balance card: big headline figure on a gradient surface.
class DashboardHeroCard extends StatelessWidget {
  const DashboardHeroCard({
    super.key,
    required this.netProfit,
    required this.revenue,
    required this.partnerShare,
    required this.sharePercentage,
    required this.isLoss,
  });

  final double netProfit;
  final double revenue;
  final double partnerShare;
  final double sharePercentage;
  final bool isLoss;

  @override
  Widget build(BuildContext context) {
    final margin = revenue > 0 ? netProfit / revenue * 100 : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMid.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isLoss ? 'Net Loss' : 'Net Profit',
                style: AppTextStyles.bodyMd.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLoss
                          ? CupertinoIcons.arrow_down_right
                          : CupertinoIcons.arrow_up_right,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${AppFormatters.percent1.format(margin.abs())}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              AppFormatters.money(netProfit.abs()),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Revenue',
                  value: AppFormatters.money(revenue),
                  icon: CupertinoIcons.chart_bar_alt_fill,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.20),
              ),
              Expanded(
                child: _MiniStat(
                  label: 'My Share (${AppFormatters.percent1.format(sharePercentage)}%)',
                  value: AppFormatters.money(partnerShare),
                  icon: CupertinoIcons.person_fill,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.75)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
