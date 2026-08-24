import 'comparison_period.dart';

/// Pure helpers for Comparison multi-period selection and validation.
abstract final class ComparisonPeriodRules {
  ComparisonPeriodRules._();

  /// Inclusive day count (from and to both count as a day).
  static int inclusiveDayCount(DateTime from, DateTime to) {
    final a = DateTime(from.year, from.month, from.day);
    final b = DateTime(to.year, to.month, to.day);
    if (b.isBefore(a)) return 0;
    return b.difference(a).inDays + 1;
  }

  /// Returns an error message when durations differ; otherwise null.
  static String? assertSameDuration(List<ComparisonPeriod> periods) {
    if (periods.length < 2) {
      return 'Select at least 2 periods to compare.';
    }
    final first = inclusiveDayCount(periods.first.dateFrom, periods.first.dateTo);
    if (first <= 0) {
      return 'Each period must have a valid start and end date.';
    }
    for (var i = 1; i < periods.length; i++) {
      final days = inclusiveDayCount(periods[i].dateFrom, periods[i].dateTo);
      if (days != first) {
        return 'Custom periods must have the same duration '
            '(${periods.first.label}: $first days, '
            '${periods[i].label}: $days days).';
      }
    }
    return null;
  }

  /// Full calendar year, optionally capped by [closedEnd].
  static ComparisonPeriod periodFromYear(int year, {DateTime? closedEnd}) {
    final from = DateTime(year, 1, 1);
    var to = DateTime(year, 12, 31);
    if (closedEnd != null &&
        closedEnd.year == year &&
        closedEnd.isBefore(to)) {
      to = DateTime(closedEnd.year, closedEnd.month, closedEnd.day);
    }
    return ComparisonPeriod(
      id: 'y$year',
      label: '$year',
      dateFrom: from,
      dateTo: to,
    );
  }

  /// Calendar month (1–12).
  static ComparisonPeriod periodFromMonth(int year, int month) {
    final from = DateTime(year, month, 1);
    final to = DateTime(year, month + 1, 0);
    final label =
        '${_monthShort(month)} ${year.toString().substring(2)}';
    return ComparisonPeriod(
      id: 'm$year-${month.toString().padLeft(2, '0')}',
      label: label,
      dateFrom: from,
      dateTo: to,
    );
  }

  static ComparisonPeriod periodFromCustom({
    required DateTime from,
    required DateTime to,
    String? label,
  }) {
    final a = DateTime(from.year, from.month, from.day);
    final b = DateTime(to.year, to.month, to.day);
    final id =
        'c${_ymd(a)}_${_ymd(b)}_${a.microsecondsSinceEpoch}';
    return ComparisonPeriod(
      id: id,
      label: label ?? '${_fmt(a)} – ${_fmt(b)}',
      dateFrom: a,
      dateTo: b.isBefore(a) ? a : b,
    );
  }

  /// Toggle [item] in [current]; returns a new sorted list.
  static List<T> toggleMulti<T>(
    List<T> current,
    T item, {
    required bool Function(T a, T b) equals,
    required int Function(T a, T b) compare,
  }) {
    final exists = current.any((e) => equals(e, item));
    final next = exists
        ? current.where((e) => !equals(e, item)).toList()
        : [...current, item];
    next.sort(compare);
    return next;
  }

  /// True when selection has enough periods to load.
  static bool canLoad(List<ComparisonPeriod> periods) => periods.length >= 2;

  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static String _fmt(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  static String _monthShort(int month) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[month - 1];
  }
}
