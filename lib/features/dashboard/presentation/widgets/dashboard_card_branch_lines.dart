import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/branch_share_line.dart';
import 'dashboard_card_headline.dart';

/// Name on top, amount under — used inside Overview KPI cards.
class DashboardCardBranchLines extends StatelessWidget {
  const DashboardCardBranchLines({
    super.key,
    required this.lines,
    required this.amountOf,
    required this.accent,
    this.title,
    this.showTotal = false,
    this.total,
  });

  final List<BranchShareLine> lines;
  final double Function(BranchShareLine line) amountOf;
  final Color accent;
  final String? title;
  final bool showTotal;
  final double? total;

  @override
  Widget build(BuildContext context) {
    if (lines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          DashboardCardHeadline(
            text: title!,
            color: accent,
            fontSize: 10.5,
          ),
          const SizedBox(height: 8),
        ],
        for (var i = 0; i < lines.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          Text(
            lines[i].name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            AppFormatters.money(amountOf(lines[i])),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: amountOf(lines[i]) < 0 ? AppColors.accentRed : accent,
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
        if (showTotal && total != null) ...[
          const SizedBox(height: 8),
          Container(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 6),
          Text(
            AppFormatters.money(total!),
            style: TextStyle(
              color: accent,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ],
    );
  }
}
