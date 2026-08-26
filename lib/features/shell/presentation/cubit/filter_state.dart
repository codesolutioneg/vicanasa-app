import 'package:equatable/equatable.dart';

import '../../domain/closed_month_option.dart';

class FilterState extends Equatable {
  const FilterState({
    this.analyticId,
    required this.dateFrom,
    required this.dateTo,
    this.closedEnd,
    this.periodDisplay,
    this.closedMonths = const [],
    this.selectedMonthKeys = const [],
    this.periodPreset = 'YTD',
    this.filterYear,
  });

  final int? analyticId;
  final DateTime dateFrom;
  final DateTime dateTo;
  final DateTime? closedEnd;
  final String? periodDisplay;
  final List<ClosedMonthOption> closedMonths;
  final List<String> selectedMonthKeys;
  final String periodPreset;

  /// Year selected in the shell date filter (scopes From/To picker).
  final int? filterYear;

  String get dateFromStr =>
      '${dateFrom.year}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}';

  String get dateToStr =>
      '${dateTo.year}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}';

  DateTime get maxSelectableDate => closedEnd ?? DateTime.now();

  static const int _yearLookback = 5;

  /// Selectable years: closed-end year and [ _yearLookback ] prior years.
  List<int> get availableFilterYears {
    final maxYear = closedEnd?.year ?? DateTime.now().year;
    final minYear = maxYear - _yearLookback;
    return [for (var y = maxYear; y >= minYear; y--) y];
  }

  List<ClosedMonthOption> closedMonthsForYear(int year) =>
      closedMonths.where((m) => m.year == year).toList();

  bool isMonthSelectable(int year, int month) {
    if (closedMonths.isEmpty) return _withinClosedEnd(year, month);
    final forYear = closedMonthsForYear(year);
    if (forYear.isEmpty) return _withinClosedEnd(year, month);
    return forYear.any((m) => m.month == month);
  }

  bool _withinClosedEnd(int year, int month) {
    final cap = maxSelectableDate;
    if (year > cap.year) return false;
    if (year < cap.year) return true;
    return month <= cap.month;
  }

  /// Date picker bounds for the active filter year.
  (DateTime first, DateTime last) pickerBoundsForYear(int year) {
    final months = closedMonthsForYear(year);
    final absoluteLast = maxSelectableDate;
    if (months.isEmpty) {
      final first = DateTime(year, 1, 1);
      var last = DateTime(year, 12, 31);
      if (last.isAfter(absoluteLast)) last = absoluteLast;
      return (first, last.isBefore(first) ? first : last);
    }
    final sorted = List<ClosedMonthOption>.from(months)
      ..sort((a, b) => a.month.compareTo(b.month));
    final first = sorted.first.dateFrom;
    var last = sorted.last.dateTo;
    if (last.isAfter(absoluteLast)) last = absoluteLast;
    return (first, last);
  }

  FilterState copyWith({
    int? analyticId,
    bool clearAnalytic = false,
    DateTime? dateFrom,
    DateTime? dateTo,
    DateTime? closedEnd,
    String? periodDisplay,
    List<ClosedMonthOption>? closedMonths,
    List<String>? selectedMonthKeys,
    String? periodPreset,
    int? filterYear,
  }) {
    return FilterState(
      analyticId: clearAnalytic ? null : (analyticId ?? this.analyticId),
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      closedEnd: closedEnd ?? this.closedEnd,
      periodDisplay: periodDisplay ?? this.periodDisplay,
      closedMonths: closedMonths ?? this.closedMonths,
      selectedMonthKeys: selectedMonthKeys ?? this.selectedMonthKeys,
      periodPreset: periodPreset ?? this.periodPreset,
      filterYear: filterYear ?? this.filterYear,
    );
  }

  @override
  List<Object?> get props => [
        analyticId,
        dateFrom,
        dateTo,
        closedEnd,
        periodDisplay,
        closedMonths,
        selectedMonthKeys,
        periodPreset,
        filterYear,
      ];
}
