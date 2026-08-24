import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';

/// Single-select year chips used before months / custom ranges.
class ComparisonScopeYearChips extends StatelessWidget {
  const ComparisonScopeYearChips({
    super.key,
    required this.availableYears,
    required this.scopeYear,
    required this.onScopeYear,
  });

  final List<int> availableYears;
  final int? scopeYear;
  final ValueChanged<int> onScopeYear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Year',
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spaceSm),
        Wrap(
          spacing: AppDimensions.spaceSm,
          runSpacing: AppDimensions.spaceSm,
          children: availableYears.map((y) {
            return ChoiceChip(
              label: Text('$y', style: GoogleFonts.cairo(fontSize: 12)),
              selected: scopeYear == y,
              selectedColor: AppColors.primaryPale,
              onSelected: (_) => onScopeYear(y),
            );
          }).toList(),
        ),
      ],
    );
  }
}
