import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/di/injection.dart';
import '../../../core/theme/liquid_glass.dart';
import '../../financial/domain/repositories/financial_repository.dart';
import '../../shell/presentation/cubit/filter_cubit.dart';

Future<void> showAccountDetailsSheet(
  BuildContext context, {
  required int accountId,
  int? accountGroupId,
  required FilterState filter,
}) async {
  final repo = sl<FinancialRepository>();
  final result = await repo.getAccountDetails(
    accountId: accountId,
    dateFrom: filter.dateFromStr,
    dateTo: filter.dateToStr,
    analyticId: filter.analyticId,
    accountGroupId: accountGroupId,
  );
  if (!context.mounted) return;
  await result.fold(
    (f) async {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message)));
    },
    (data) async {
      if (data['error'] != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('${data['error']}')));
        return;
      }
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, scroll) => LiquidGlassCard(
            borderRadius: 24,
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  '${data['account_code']} — ${data['account_name']}',
                  style: Theme.of(ctx).textTheme.titleMedium,
                ),
                Text('Total: ${NumberFormat('#,##0.00').format(data['total_amount'])}'),
                const Divider(),
                ...(data['transactions'] as List? ?? []).map((t) {
                  final m = Map<String, dynamic>.from(t as Map);
                  return ListTile(
                    dense: true,
                    title: Text(m['name']?.toString() ?? ''),
                    subtitle: Text(m['date']?.toString() ?? ''),
                    trailing: Text(NumberFormat('#,##0.00').format(m['amount'])),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    },
  );
}
