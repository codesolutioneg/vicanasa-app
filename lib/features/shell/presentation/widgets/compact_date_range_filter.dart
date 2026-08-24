import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/filter_cubit.dart';

/// Mobile From/To date filter — mirrors Odoo portal `#dateFrom` / `#dateTo`.
/// Ranges are capped to [FilterState.closedEnd] and closed months only.
class CompactDateRangeFilter extends StatelessWidget {
  const CompactDateRangeFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<FilterCubit>().state;
    final fmt = DateFormat('MM/dd/yyyy');

    return Row(
      children: [
        Expanded(
          child: _DateChip(
            label: l10n.dateFrom,
            value: fmt.format(state.dateFrom),
            onTap: () => _pick(context, isFrom: true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DateChip(
            label: l10n.dateTo,
            value: fmt.format(state.dateTo),
            onTap: () => _pick(context, isFrom: false),
          ),
        ),
      ],
    );
  }

  Future<void> _pick(BuildContext context, {required bool isFrom}) async {
    final cubit = context.read<FilterCubit>();
    final filter = cubit.state;
    final lastDate = filter.maxSelectableDate;
    var initial = isFrom ? filter.dateFrom : filter.dateTo;
    if (initial.isAfter(lastDate)) initial = lastDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: lastDate,
      helpText: isFrom ? 'Start date' : 'End date',
    );
    if (picked == null || !context.mounted) return;
    if (!filter.isMonthSelectable(picked.year, picked.month)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Only closed months are available'),
        ),
      );
      return;
    }

    var from = filter.dateFrom;
    var to = filter.dateTo;
    if (isFrom) {
      from = picked;
      if (to.isBefore(from)) to = from;
    } else {
      to = picked;
      if (from.isAfter(to)) from = to;
    }
    cubit.setDateRange(from, to);
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.calendar,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
