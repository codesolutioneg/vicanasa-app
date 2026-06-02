import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import '../../../account_details/presentation/account_details_sheet.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

Future<void> showDashboardGroupedSheet(
  BuildContext context, {
  required String title,
  required Color headerColor,
  required List<Map<String, dynamic>> groups,
  required String analysisLevel,
  required List<int> allowedGroupIds,
  required double grandTotal,
  required String grandLabel,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scroll) => Material(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.all(16),
                children: [
                  if (groups.isEmpty)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No data in this period'),
                    ))
                  else
                    ...groups.map((g) => _GroupBlock(
                          group: g,
                          analysisLevel: analysisLevel,
                          allowedGroupIds: allowedGroupIds,
                        )),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: headerColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(grandLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          AppFormatters.money(grandTotal),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: headerColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _GroupBlock extends StatelessWidget {
  const _GroupBlock({
    required this.group,
    required this.analysisLevel,
    required this.allowedGroupIds,
  });

  final Map<String, dynamic> group;
  final String analysisLevel;
  final List<int> allowedGroupIds;

  bool get canSeeDetails =>
      analysisLevel == 'all_details' ||
      (analysisLevel == 'custom' &&
          allowedGroupIds.contains(group['group_id'] as int?));

  @override
  Widget build(BuildContext context) {
    final accounts = group['accounts'] as List? ?? [];
    final total = (group['total_amount'] as num?)?.toDouble() ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            title: Text(
              '${group['group_code'] ?? ''} ${group['group_name'] ?? ''}'.trim(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              AppFormatters.money(total),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (canSeeDetails && accounts.isNotEmpty)
            ...accounts.map((a) {
              final acc = Map<String, dynamic>.from(a as Map);
              return ListTile(
                dense: true,
                title: Text('${acc['code']} ${acc['name']}'),
                trailing: Text(AppFormatters.money((acc['amount'] as num?)?.toDouble() ?? 0)),
                onTap: acc['account_id'] != null
                    ? () {
                        Navigator.pop(context);
                        showAccountDetailsSheet(
                          context,
                          accountId: acc['account_id'] as int,
                          accountGroupId: group['group_id'] as int?,
                          filter: context.read<FilterCubit>().state,
                        );
                      }
                    : null,
              );
            }),
        ],
      ),
    );
  }
}

Future<void> showDeductionsSheet(
  BuildContext context, {
  required List<Map<String, dynamic>> costGrouped,
  required List<Map<String, dynamic>> expenseGrouped,
  required double costTotal,
  required double expenseTotal,
  required String analysisLevel,
  required List<int> allowedGroupIds,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      builder: (_, scroll) => Material(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: AppColors.accentRed,
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Expenses Analysis',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.xmark, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.all(16),
                children: [
                  if (costGrouped.isNotEmpty) ...[
                    const Text('Cost of Goods Sold',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...costGrouped.map((g) => _GroupBlock(
                          group: Map<String, dynamic>.from(g as Map),
                          analysisLevel: analysisLevel,
                          allowedGroupIds: allowedGroupIds,
                        )),
                    _totalRow('Total Cost of Goods Sold', costTotal, AppColors.accentRed),
                    const SizedBox(height: 16),
                  ],
                  if (expenseGrouped.isNotEmpty) ...[
                    const Text('Operating Expenses',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...expenseGrouped.map((g) => _GroupBlock(
                          group: Map<String, dynamic>.from(g as Map),
                          analysisLevel: analysisLevel,
                          allowedGroupIds: allowedGroupIds,
                        )),
                    _totalRow('Total Operating Expenses', expenseTotal, AppColors.accentOrange),
                  ],
                  _totalRow(
                    'Total Deductions',
                    costTotal + expenseTotal,
                    AppColors.accentRed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _totalRow(String label, double value, Color color) {
  return Container(
    margin: const EdgeInsets.only(top: 8, bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(AppFormatters.money(value), style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      ],
    ),
  );
}
