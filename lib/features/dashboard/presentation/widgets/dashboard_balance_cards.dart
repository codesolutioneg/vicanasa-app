import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/portal_kpi_card.dart';

class DashboardBalanceCards extends StatelessWidget {
  const DashboardBalanceCards({
    super.key,
    required this.distributionBalance,
  });

  final double distributionBalance;

  @override
  Widget build(BuildContext context) {
    if (distributionBalance == 0) return const SizedBox.shrink();
    return PortalKpiCard(
      label: 'Distributions',
      value: distributionBalance,
      icon: CupertinoIcons.arrow_right_arrow_left,
      iconColor: AppColors.kpiDistrib,
      iconBackground: const Color(0xFFFDF2F8),
    );
  }
}
