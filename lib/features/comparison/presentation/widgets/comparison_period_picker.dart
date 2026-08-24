import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../core/utils/bilingual_display.dart';
import '../../../shell/domain/closed_month_option.dart';
import '../../domain/comparison_mode.dart';
import '../../domain/comparison_period.dart';
import 'comparison_custom_period_list.dart';
import 'comparison_scope_year_chips.dart';


/// Period multi-select UI for Year / Monthly / Custom modes.
class ComparisonPeriodPicker extends StatelessWidget {
  const ComparisonPeriodPicker({
    super.key,
    required this.mode,
    required this.availableYears,
    required this.selectedYears,
    required this.scopeYear,
    required this.availableMonths,
    required this.selectedMonthKeys,
    required this.customPeriods,
    required this.validationError,
    required this.onToggleYear,
    required this.onScopeYear,
    required this.onToggleMonth,
    required this.onAddCustom,
    required this.onRemoveCustom,
  });

  final ComparisonMode mode;
  final List<int> availableYears;
  final List<int> selectedYears;
  final int? scopeYear;
  final List<ClosedMonthOption> availableMonths;
  final List<String> selectedMonthKeys;
  final List<ComparisonPeriod> customPeriods;
  final String? validationError;
  final ValueChanged<int> onToggleYear;
  final ValueChanged<int> onScopeYear;
  final ValueChanged<ClosedMonthOption> onToggleMonth;
  final VoidCallback onAddCustom;
  final ValueChanged<String> onRemoveCustom;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.calendar,
                color: AppColors.primaryMid,
                size: 20,
              ),
              const SizedBox(width: AppDimensions.spaceSm),
              Text(
                _title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          if (mode == ComparisonMode.year) _yearChips(),
          if (mode == ComparisonMode.monthly) _monthlyBody(),
          if (mode == ComparisonMode.custom) _customBody(),
          if (validationError != null) ...[
            const SizedBox(height: AppDimensions.spaceSm),
            Text(
              validationError!,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.accentRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String get _title {
    switch (mode) {
      case ComparisonMode.year:
        return 'Select years';
      case ComparisonMode.monthly:
        return 'Select year, then months';
      case ComparisonMode.custom:
        return 'Select year, then periods';
    }
  }

  Widget _scopeYear() => ComparisonScopeYearChips(
        availableYears: availableYears,
        scopeYear: scopeYear,
        onScopeYear: onScopeYear,
      );

  Widget _monthlyBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _scopeYear(),
        if (scopeYear != null) ...[
          const SizedBox(height: AppDimensions.spaceMd),
          Text(
            'Select months',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spaceSm),
          _monthChips(),
        ],
      ],
    );
  }

  Widget _customBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _scopeYear(),
        if (scopeYear != null) ...[
          const SizedBox(height: AppDimensions.spaceMd),
          ComparisonCustomPeriodList(
            scopeYear: scopeYear!,
            customPeriods: customPeriods,
            onAddCustom: onAddCustom,
            onRemoveCustom: onRemoveCustom,
          ),
        ],
      ],
    );
  }

  Widget _yearChips() {
    return Wrap(
      spacing: AppDimensions.spaceSm,
      runSpacing: AppDimensions.spaceSm,
      children: availableYears.map((y) {
        return FilterChip(
          label: Text('$y', style: GoogleFonts.cairo(fontSize: 12)),
          selected: selectedYears.contains(y),
          selectedColor: AppColors.primaryPale,
          checkmarkColor: AppColors.primaryDark,
          onSelected: (_) => onToggleYear(y),
        );
      }).toList(),
    );
  }

  Widget _monthChips() {
    if (availableMonths.isEmpty) {
      return Text(
        'No months available for $scopeYear.',
        style: GoogleFonts.cairo(fontSize: 13, color: AppColors.textTertiary),
      );
    }
    return Wrap(
      spacing: AppDimensions.spaceSm,
      runSpacing: AppDimensions.spaceSm,
      children: availableMonths.map((m) {
        return FilterChip(
          label: Text(
            BilingualDisplay.englishMonthLabel(m.name),
            style: GoogleFonts.cairo(fontSize: 12),
          ),
          selected: selectedMonthKeys.contains(m.key),
          selectedColor: AppColors.primaryPale,
          checkmarkColor: AppColors.primaryDark,
          onSelected: (_) => onToggleMonth(m),
        );
      }).toList(),
    );
  }
}
