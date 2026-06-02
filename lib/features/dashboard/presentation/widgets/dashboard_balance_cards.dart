import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../core/utils/app_formatters.dart';

class DashboardBalanceCards extends StatelessWidget {
  const DashboardBalanceCards({
    super.key,
    required this.capitalBalance,
    required this.distributionBalance,
  });

  final double capitalBalance;
  final double distributionBalance;

  @override
  Widget build(BuildContext context) {
    if (capitalBalance == 0 && distributionBalance == 0) {
      return const SizedBox.shrink();
    }
    return Row(
      children: [
        Expanded(
          child: _GradientBalanceCard(
            label: 'CAPITAL BALANCE',
            value: capitalBalance,
            gradient: AppColors.capitalGradient,
            icon: CupertinoIcons.building_2_fill,
          ),
        ),
        const SizedBox(width: AppDimensions.spaceSm),
        Expanded(
          child: _GradientBalanceCard(
            label: 'DISTRIBUTIONS',
            value: distributionBalance,
            gradient: AppColors.distribGradient,
            icon: CupertinoIcons.money_dollar,
          ),
        ),
      ],
    );
  }
}

class _GradientBalanceCard extends StatelessWidget {
  const _GradientBalanceCard({
    required this.label,
    required this.value,
    required this.gradient,
    required this.icon,
  });

  final String label;
  final double value;
  final Gradient gradient;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      blurSigma: 16,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          gradient: gradient,
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppFormatters.money(value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
