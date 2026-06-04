import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  });

  final int? analyticId;
  final DateTime dateFrom;
  final DateTime dateTo;
  final DateTime? closedEnd;
  final String? periodDisplay;
  final List<ClosedMonthOption> closedMonths;
  final List<String> selectedMonthKeys;
  final String periodPreset;

  String get dateFromStr =>
      '${dateFrom.year}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}';

  String get dateToStr =>
      '${dateTo.year}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}';

  DateTime get maxSelectableDate => closedEnd ?? DateTime.now();

  bool isMonthSelectable(int year, int month) {
    if (closedMonths.isEmpty) return true;
    return closedMonths.any((m) => m.year == year && m.month == month);
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
      ];
}

/// Shared branch and date range across financial screens.
class FilterCubit extends Cubit<FilterState> {
  FilterCubit()
      : super(FilterState(
          dateFrom: DateTime(DateTime.now().year, 1, 1),
          dateTo: DateTime.now(),
        ));

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
    ));
  }

  void applyPeriodCap(Map<String, dynamic> periodInfo) {
    final closedMonths = ClosedMonthOption.listFromPeriodInfo(periodInfo);
    if (periodInfo['has_closed_period'] != true) {
      if (closedMonths.isNotEmpty) {
        emit(state.copyWith(closedMonths: closedMonths));
      }
      return;
    }
    final closedStr = periodInfo['closed_end'] as String?;
    if (closedStr == null) return;
    final closed = DateTime.parse(closedStr);
    var to = state.dateTo;
    var from = state.dateFrom;
    if (to.isAfter(closed)) to = closed;
    if (from.isAfter(closed)) {
      from = DateTime(closed.year, 1, 1);
    }
    final lastKey = closedMonths.isNotEmpty ? closedMonths.first.key : null;
    emit(state.copyWith(
      dateFrom: from,
      dateTo: to,
      closedEnd: closed,
      periodDisplay: periodInfo['display_text'] as String?,
      closedMonths: closedMonths,
      periodPreset: 'YTD',
      selectedMonthKeys: lastKey != null ? [lastKey] : const [],
    ));
  }

  void setYtd() {
    final end = state.closedEnd ?? DateTime.now();
    emit(state.copyWith(
      dateFrom: DateTime(end.year, 1, 1),
      dateTo: end,
      periodPreset: 'YTD',
      selectedMonthKeys: state.closedMonths.map((m) => m.key).toList(),
    ));
  }

  void setClosedMonth(ClosedMonthOption month) {
    emit(state.copyWith(
      dateFrom: month.dateFrom,
      dateTo: month.dateTo,
      periodPreset: month.key,
      selectedMonthKeys: [month.key],
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
    ));
  }

  /// Legacy presets — capped to last closed month when applicable.
  void setMtd() {
    final end = state.closedEnd;
    final now = DateTime.now();
    if (end != null) {
      if (now.year > end.year ||
          (now.year == end.year && now.month > end.month)) {
        final last = state.closedMonths.isNotEmpty
            ? state.closedMonths.first
            : null;
        if (last != null) {
          setClosedMonth(last);
          return;
        }
        emit(state.copyWith(
          dateFrom: DateTime(end.year, end.month, 1),
          dateTo: end,
          periodPreset: 'MTD',
        ));
        return;
      }
    }
    emit(state.copyWith(
      dateFrom: DateTime(now.year, now.month, 1),
      dateTo: _capDate(now),
      periodPreset: 'MTD',
      selectedMonthKeys: const [],
    ));
  }

  void setLastMonth() {
    final end = state.closedEnd;
    if (end != null && state.closedMonths.length >= 2) {
      setClosedMonth(state.closedMonths[1]);
      return;
    }
    if (end != null && state.closedMonths.length == 1) {
      setClosedMonth(state.closedMonths.first);
      return;
    }
    final first = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final last = first.subtract(const Duration(days: 1));
    emit(state.copyWith(
      dateFrom: DateTime(last.year, last.month, 1),
      dateTo: _capDate(last),
      periodPreset: 'LAST',
      selectedMonthKeys: const [],
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
