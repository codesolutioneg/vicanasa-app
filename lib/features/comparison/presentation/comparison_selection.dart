import '../../../core/utils/bilingual_display.dart';
import '../../shell/domain/closed_month_option.dart';
import '../../shell/presentation/cubit/filter_cubit.dart';
import '../domain/comparison_mode.dart';
import '../domain/comparison_period.dart';
import '../domain/comparison_period_rules.dart';

/// Builds selectable months and current period list from FilterCubit state.
abstract final class ComparisonSelection {
  ComparisonSelection._();

  static List<ClosedMonthOption> months(FilterState filter) {
    if (filter.closedMonths.isNotEmpty) return filter.closedMonths;
    final end = filter.closedEnd ?? DateTime.now();
    final out = <ClosedMonthOption>[];
    var y = end.year;
    var m = end.month;
    for (var i = 0; i < 12; i++) {
      final from = DateTime(y, m, 1);
      final to = DateTime(y, m + 1, 0);
      final key = '$y-${m.toString().padLeft(2, '0')}';
      out.add(ClosedMonthOption(
        year: y,
        month: m,
        key: key,
        name: key,
        dateFrom: from,
        dateTo: to.isAfter(end) ? end : to,
      ));
      m -= 1;
      if (m == 0) {
        m = 12;
        y -= 1;
      }
    }
    return out;
  }

  /// Months for [year] only (newest first when from closed list).
  static List<ClosedMonthOption> monthsForYear(
    FilterState filter,
    int year,
  ) {
    return months(filter).where((m) => m.year == year).toList();
  }

  static List<ComparisonPeriod> periods({
    required ComparisonMode mode,
    required FilterState filter,
    required List<int> selectedYears,
    required List<String> selectedMonthKeys,
    required List<ComparisonPeriod> customPeriods,
  }) {
    switch (mode) {
      case ComparisonMode.year:
        return selectedYears
            .map((y) => ComparisonPeriodRules.periodFromYear(
                  y,
                  closedEnd: filter.closedEnd,
                ))
            .toList();
      case ComparisonMode.monthly:
        return months(filter)
            .where((m) => selectedMonthKeys.contains(m.key))
            .map((m) => ComparisonPeriod(
                  id: m.key,
                  label: BilingualDisplay.englishMonthLabel(m.name),
                  dateFrom: m.dateFrom,
                  dateTo: m.dateTo,
                ))
            .toList();
      case ComparisonMode.custom:
        return List<ComparisonPeriod>.from(customPeriods);
    }
  }
}
