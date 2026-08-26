import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/closed_month_option.dart';
import 'filter_state.dart';

export 'filter_state.dart';

/// Shared branch and date range across financial screens.
class FilterCubit extends Cubit<FilterState> {
  FilterCubit()
      : super(FilterState(
          dateFrom: _calendarLastMonthStart(),
          dateTo: _calendarLastMonthEnd(),
          periodPreset: 'LAST',
          filterYear: DateTime.now().year,
        ));

  static DateTime _calendarLastMonthStart() {
    final firstThisMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    final lastMonthEnd = firstThisMonth.subtract(const Duration(days: 1));
    return DateTime(lastMonthEnd.year, lastMonthEnd.month, 1);
  }

  static DateTime _calendarLastMonthEnd() {
    final firstThisMonth =
        DateTime(DateTime.now().year, DateTime.now().month, 1);
    return firstThisMonth.subtract(const Duration(days: 1));
  }

  void setBranch(int? id) => emit(state.copyWith(
        analyticId: id,
        clearAnalytic: id == null,
      ));

  void setDateRange(DateTime from, DateTime to) {
    final capped = _capRange(from, to);
    emit(state.copyWith(
      dateFrom: capped.$1,
      dateTo: capped.$2,
      periodPreset: 'CUSTOM',
      selectedMonthKeys: const [],
      filterYear: capped.$1.year,
    ));
  }

  /// Switch shell filter year and snap range to that year's last closed month.
  void setFilterYear(int year) {
    final months = state.closedMonthsForYear(year);
    if (months.isEmpty) {
      final bounds = state.pickerBoundsForYear(year);
      emit(state.copyWith(
        filterYear: year,
        dateFrom: bounds.$1,
        dateTo: bounds.$2,
        periodPreset: 'CUSTOM',
        selectedMonthKeys: const [],
      ));
      return;
    }
    final sorted = List<ClosedMonthOption>.from(months)
      ..sort((a, b) => b.month.compareTo(a.month));
    final last = sorted.first;
    emit(state.copyWith(
      filterYear: year,
      dateFrom: last.dateFrom,
      dateTo: last.dateTo,
      periodPreset: last.key,
      selectedMonthKeys: [last.key],
    ));
  }

  void applyPeriodCap(Map<String, dynamic> periodInfo) {
    final closedMonths = ClosedMonthOption.listFromPeriodInfo(periodInfo);
    if (periodInfo['has_closed_period'] != true) {
      if (closedMonths.isNotEmpty) {
        emit(state.copyWith(
          closedMonths: closedMonths,
          filterYear: closedMonths.first.year,
        ));
      }
      return;
    }
    final closedStr = periodInfo['closed_end'] as String?;
    if (closedStr == null) return;
    final closed = DateTime.parse(closedStr);

    final DateTime from;
    final DateTime to;
    final List<String> selectedKeys;
    final String preset;
    final int year;
    if (closedMonths.isNotEmpty) {
      final lastClosed = closedMonths.first;
      from = lastClosed.dateFrom;
      to = lastClosed.dateTo.isAfter(closed) ? closed : lastClosed.dateTo;
      selectedKeys = [lastClosed.key];
      preset = lastClosed.key;
      year = lastClosed.year;
    } else {
      from = DateTime(closed.year, closed.month, 1);
      to = closed;
      selectedKeys = const [];
      preset = 'LAST';
      year = closed.year;
    }

    emit(state.copyWith(
      dateFrom: from,
      dateTo: to,
      closedEnd: closed,
      periodDisplay: periodInfo['display_text'] as String?,
      closedMonths: closedMonths,
      periodPreset: preset,
      selectedMonthKeys: selectedKeys,
      filterYear: year,
    ));
  }

  void setYtd() {
    final year =
        state.filterYear ?? state.closedEnd?.year ?? DateTime.now().year;
    final months = state.closedMonthsForYear(year);
    if (months.isNotEmpty) {
      final sorted = List<ClosedMonthOption>.from(months)
        ..sort((a, b) => a.month.compareTo(b.month));
      emit(state.copyWith(
        dateFrom: sorted.first.dateFrom,
        dateTo: sorted.last.dateTo,
        periodPreset: 'YTD',
        selectedMonthKeys: sorted.map((m) => m.key).toList(),
        filterYear: year,
      ));
      return;
    }
    final end = state.closedEnd ?? DateTime.now();
    emit(state.copyWith(
      dateFrom: DateTime(year, 1, 1),
      dateTo: end.year == year ? end : DateTime(year, 12, 31),
      periodPreset: 'YTD',
      selectedMonthKeys: const [],
      filterYear: year,
    ));
  }

  void setClosedMonth(ClosedMonthOption month) {
    emit(state.copyWith(
      dateFrom: month.dateFrom,
      dateTo: month.dateTo,
      periodPreset: month.key,
      selectedMonthKeys: [month.key],
      filterYear: month.year,
    ));
  }

  void setClosedMonths(List<ClosedMonthOption> months) {
    if (months.isEmpty) return;
    final sorted = List<ClosedMonthOption>.from(months)
      ..sort((a, b) {
        final c = a.year.compareTo(b.year);
        return c != 0 ? c : a.month.compareTo(b.month);
      });
    emit(state.copyWith(
      dateFrom: sorted.first.dateFrom,
      dateTo: sorted.last.dateTo,
      periodPreset: 'MULTI',
      selectedMonthKeys: sorted.map((m) => m.key).toList(),
      filterYear: sorted.last.year,
    ));
  }

  void setMtd() {
    final end = state.closedEnd;
    final now = DateTime.now();
    if (end != null) {
      if (now.year > end.year ||
          (now.year == end.year && now.month > end.month)) {
        final last =
            state.closedMonths.isNotEmpty ? state.closedMonths.first : null;
        if (last != null) {
          setClosedMonth(last);
          return;
        }
        emit(state.copyWith(
          dateFrom: DateTime(end.year, end.month, 1),
          dateTo: end,
          periodPreset: 'MTD',
          filterYear: end.year,
        ));
        return;
      }
    }
    emit(state.copyWith(
      dateFrom: DateTime(now.year, now.month, 1),
      dateTo: _capDate(now),
      periodPreset: 'MTD',
      selectedMonthKeys: const [],
      filterYear: now.year,
    ));
  }

  void setLastMonth() {
    if (state.closedMonths.isNotEmpty) {
      setClosedMonth(state.closedMonths.first);
      return;
    }
    final from = _calendarLastMonthStart();
    final to = _calendarLastMonthEnd();
    emit(state.copyWith(
      dateFrom: from,
      dateTo: _capDate(to),
      periodPreset: 'LAST',
      selectedMonthKeys: const [],
      filterYear: from.year,
    ));
  }

  (DateTime, DateTime) _capRange(DateTime from, DateTime to) {
    final cap = state.closedEnd;
    if (cap == null) return (from, to);
    var f = from;
    var t = to;
    if (t.isAfter(cap)) t = cap;
    if (f.isAfter(cap)) f = DateTime(cap.year, 1, 1);
    if (f.isAfter(t)) f = DateTime(t.year, t.month, 1);
    return (f, t);
  }

  DateTime _capDate(DateTime d) {
    final cap = state.closedEnd;
    if (cap == null) return d;
    return d.isAfter(cap) ? cap : d;
  }
}
