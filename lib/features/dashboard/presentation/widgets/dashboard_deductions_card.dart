import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../domain/branch_share_line.dart';
import 'dashboard_card_branch_lines.dart';
import 'dashboard_card_headline.dart';

/// Total Deductions: Costs | Expenses per branch (same sequence as hero).
class DashboardDeductionsCard extends StatelessWidget {
  const DashboardDeductionsCard({
    super.key,
    required this.cost,
    required this.expense,
    required this.branchLines,
    this.onTap,
  });

  final double cost;
  final double expense;
  final List<BranchShareLine> branchLines;
  final VoidCallback? onTap;

  bool get _expand => branchLines.length > 3;

  @override
  Widget build(BuildContext context) {
    final total = cost + expense;
    final tappable = onTap != null;
    final costsCol = DashboardCardBranchLines(
      title: 'COSTS',
      lines: branchLines,
      amountOf: (l) => l.cost,
      accent: AppColors.kpiCost,
      showTotal: true,
      total: cost,
    );
    final expensesCol = DashboardCardBranchLines(
      title: 'EXPENSES',
      lines: branchLines,
      amountOf: (l) => l.expense,
      accent: AppColors.accentRed,
      showTotal: true,
      total: expense,
    );

    return Material(
      color: AppColors.bgSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: tappable
              ? AppColors.accentRed.withValues(alpha: 0.35)
              : AppColors.cardBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.accentRed.withValues(alpha: 0.12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(tappable, total),
              if (branchLines.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.borderLight,
                ),
                const SizedBox(height: 10),
                if (_expand) ...[
                  costsCol,
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 12),
                  expensesCol,
                ] else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: costsCol),
                      Container(
                        width: 1,
                        constraints: BoxConstraints(
                          minHeight: 56,
                          maxHeight: 28.0 + branchLines.length * 40,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: AppColors.borderLight,
                      ),
                      Expanded(child: expensesCol),
                    ],
                  ),
              ],
              if (tappable) ...[
                const SizedBox(height: 8),
                Text(
                  'Tap for details',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accentRed,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(bool tappable, double total) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            CupertinoIcons.arrow_down_right,
            size: 18,
            color: AppColors.kpiExpense,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DashboardCardHeadline(
                text: 'TOTAL DEDUCTIONS',
                color: AppColors.accentRed,
                trailing: tappable
                    ? Icon(
                        CupertinoIcons.chevron_right,
                        size: 16,
                        color: AppColors.accentRed.withValues(alpha: 0.8),
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  AppFormatters.money(total),
                  style: AppTextStyles.kpiValue.copyWith(
                    fontSize: 22,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
