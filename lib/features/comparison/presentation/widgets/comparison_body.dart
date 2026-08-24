import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/error_retry.dart';
import '../../../shell/domain/closed_month_option.dart';
import '../../domain/comparison_card_data.dart';
import '../../domain/comparison_mode.dart';
import '../../domain/comparison_period.dart';
import 'comparison_mode_bar.dart';
import 'comparison_period_picker.dart';
import 'comparison_result_card.dart';

/// Scrollable body for Comparison (modes, picker, cards).
class ComparisonBody extends StatelessWidget {
  const ComparisonBody({
    super.key,
    required this.mode,
    required this.availableYears,
    required this.selectedYears,
    required this.scopeYear,
    required this.selectedMonthKeys,
    required this.customPeriods,
    required this.cards,
    required this.loading,
    required this.error,
    required this.validationError,
    required this.months,
    required this.onRetry,
    required this.onRefresh,
    required this.onModeChanged,
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
  final List<String> selectedMonthKeys;
  final List<ComparisonPeriod> customPeriods;
  final List<ComparisonCardData> cards;
  final bool loading;
  final String? error;
  final String? validationError;
  final List<ClosedMonthOption> months;
  final VoidCallback onRetry;
  final Future<void> Function() onRefresh;
  final ValueChanged<ComparisonMode> onModeChanged;
  final ValueChanged<int> onToggleYear;
  final ValueChanged<int> onScopeYear;
  final ValueChanged<ClosedMonthOption> onToggleMonth;
  final VoidCallback onAddCustom;
  final ValueChanged<String> onRemoveCustom;

  @override
  Widget build(BuildContext context) {
    if (loading && cards.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null && cards.isEmpty) {
      return ErrorRetry(message: error!, onRetry: onRetry);
    }

    return RefreshIndicator(
      color: AppColors.primaryMid,
      onRefresh: onRefresh,
      child: ListView(
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.spaceMd),
        children: [
          ComparisonModeBar(mode: mode, onChanged: onModeChanged),
          const SizedBox(height: AppDimensions.spaceMd),
          ComparisonPeriodPicker(
            mode: mode,
            availableYears: availableYears,
            selectedYears: selectedYears,
            scopeYear: scopeYear,
            availableMonths: months,
            selectedMonthKeys: selectedMonthKeys,
            customPeriods: customPeriods,
            validationError: validationError,
            onToggleYear: onToggleYear,
            onScopeYear: onScopeYear,
            onToggleMonth: onToggleMonth,
            onAddCustom: onAddCustom,
            onRemoveCustom: onRemoveCustom,
          ),
          const SizedBox(height: AppDimensions.spaceMd),
          if (loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            for (final c in cards) ...[
              ComparisonResultCard(data: c),
              const SizedBox(height: AppDimensions.spaceSm),
            ],
            if (cards.isEmpty && validationError == null)
              Text(
                'Select at least 2 periods to compare.',
                style: GoogleFonts.cairo(color: AppColors.textTertiary),
              ),
          ],
        ],
      ),
    );
  }
}
