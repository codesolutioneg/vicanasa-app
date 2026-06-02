import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterState extends Equatable {
  const FilterState({
    this.analyticId,
    required this.dateFrom,
    required this.dateTo,
    this.closedEnd,
    this.periodDisplay,
  });

  final int? analyticId;
  final DateTime dateFrom;
  final DateTime dateTo;
  final DateTime? closedEnd;
  final String? periodDisplay;

  String get dateFromStr =>
      '${dateFrom.year}-${dateFrom.month.toString().padLeft(2, '0')}-${dateFrom.day.toString().padLeft(2, '0')}';

  String get dateToStr =>
      '${dateTo.year}-${dateTo.month.toString().padLeft(2, '0')}-${dateTo.day.toString().padLeft(2, '0')}';

  FilterState copyWith({
    int? analyticId,
    bool clearAnalytic = false,
    DateTime? dateFrom,
    DateTime? dateTo,
    DateTime? closedEnd,
    String? periodDisplay,
  }) {
    return FilterState(
      analyticId: clearAnalytic ? null : (analyticId ?? this.analyticId),
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      closedEnd: closedEnd ?? this.closedEnd,
      periodDisplay: periodDisplay ?? this.periodDisplay,
    );
  }

  @override
  List<Object?> get props =>
      [analyticId, dateFrom, dateTo, closedEnd, periodDisplay];
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

  void setDateRange(DateTime from, DateTime to) =>
      emit(state.copyWith(dateFrom: from, dateTo: to));

  void applyPeriodCap(Map<String, dynamic> periodInfo) {
    if (periodInfo['has_closed_period'] != true) return;
    final closedStr = periodInfo['closed_end'] as String?;
    if (closedStr == null) return;
    final closed = DateTime.parse(closedStr);
    var to = state.dateTo;
    var from = state.dateFrom;
    if (to.isAfter(closed)) to = closed;
    if (from.isAfter(closed)) {
      from = DateTime(closed.year, 1, 1);
    }
    emit(state.copyWith(
      dateFrom: from,
      dateTo: to,
      closedEnd: closed,
      periodDisplay: periodInfo['display_text'] as String?,
    ));
  }

  void setMtd() {
    final now = DateTime.now();
    emit(state.copyWith(
      dateFrom: DateTime(now.year, now.month, 1),
      dateTo: now,
    ));
  }

  void setYtd() {
    final now = DateTime.now();
    emit(state.copyWith(
      dateFrom: DateTime(now.year, 1, 1),
      dateTo: now,
    ));
  }

  void setLastMonth() {
    final first = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final last = first.subtract(const Duration(days: 1));
    emit(state.copyWith(
      dateFrom: DateTime(last.year, last.month, 1),
      dateTo: last,
    ));
  }
}
