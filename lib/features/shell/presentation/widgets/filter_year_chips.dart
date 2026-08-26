import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/filter_cubit.dart';

/// Compact year chips for shell date filter (newest first).
class FilterYearChips extends StatelessWidget {
  const FilterYearChips({super.key});

  @override
  Widget build(BuildContext context) {
    final filter = context.watch<FilterCubit>().state;
    final years = filter.availableFilterYears;
    if (years.isEmpty) return const SizedBox.shrink();
    final selected = filter.filterYear ?? years.first;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: years.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final y = years[index];
          final isSelected = y == selected;
          return ChoiceChip(
            label: Text(
              '$y',
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryDark
                    : AppColors.textSecondary,
              ),
            ),
            selected: isSelected,
            selectedColor: AppColors.primaryPale,
            backgroundColor: AppColors.bgSecondary,
            side: BorderSide(
              color: isSelected ? AppColors.primaryMid : AppColors.borderLight,
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            onSelected: (_) => context.read<FilterCubit>().setFilterYear(y),
          );
        },
      ),
    );
  }
}
