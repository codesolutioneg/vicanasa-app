/// One comparable date range (year, month, or custom).
class ComparisonPeriod {
  const ComparisonPeriod({
    required this.id,
    required this.label,
    required this.dateFrom,
    required this.dateTo,
  });

  final String id;
  final String label;
  final DateTime dateFrom;
  final DateTime dateTo;

  String get dateFromStr => _ymd(dateFrom);
  String get dateToStr => _ymd(dateTo);

  static String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
