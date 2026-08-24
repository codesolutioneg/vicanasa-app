import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../account_details/presentation/account_details_sheet.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

class AnalysisAccountsTable extends StatelessWidget {
  const AnalysisAccountsTable({
    super.key,
    required this.accounts,
    required this.themeColor,
    required this.groupId,
    this.revenueBase,
    this.showRevPercent = false,
  });

  final List<Map<String, dynamic>> accounts;
  final Color themeColor;
  final int? groupId;
  final double? revenueBase;
  final bool showRevPercent;

  double? _pct(double amount) {
    final base = revenueBase;
    if (!showRevPercent || base == null || base <= 0) return null;
    return amount / base * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.bgTertiary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              const SizedBox(width: 88, child: Text('CODE', style: _header)),
              const Expanded(child: Text('ACCOUNT NAME', style: _header)),
              const Text('AMOUNT', style: _header),
              if (showRevPercent) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 52,
                  child: Text('% REV', style: _header, textAlign: TextAlign.end),
                ),
              ],
            ],
          ),
        ),
        for (final acc in accounts) _row(context, acc),
      ],
    );
  }

  static const _header = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    letterSpacing: 0.4,
  );

  Widget _row(BuildContext context, Map<String, dynamic> acc) {
    final amount = (acc['amount'] as num?)?.toDouble() ?? 0;
    final pct = _pct(amount);
    final accountId = acc['account_id'] as int?;

    return InkWell(
      onTap: accountId == null
          ? null
          : () {
              Navigator.pop(context);
              showAccountDetailsSheet(
                context,
                accountId: accountId,
                accountGroupId: groupId,
                filter: context.read<FilterCubit>().state,
              );
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.borderLight)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 88,
              child: Text(
                '${acc['code'] ?? ''}',
                style: const TextStyle(
                  color: Color(0xFFE11D48),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${acc['name'] ?? ''}',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              AppFormatters.money(amount),
              style: TextStyle(
                color: themeColor,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (showRevPercent) ...[
              const SizedBox(width: 8),
              SizedBox(
                width: 52,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.bgTertiary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      pct == null
                          ? '—'
                          : '${AppFormatters.percent1.format(pct)}%',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
