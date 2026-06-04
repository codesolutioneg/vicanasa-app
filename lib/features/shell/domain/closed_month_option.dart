import 'package:equatable/equatable.dart';

/// One closed accounting month from `/my/financial/api/period-info`.
class ClosedMonthOption extends Equatable {
  const ClosedMonthOption({
    required this.year,
    required this.month,
    required this.key,
    required this.name,
    required this.dateFrom,
    required this.dateTo,
  });

  final int year;
  final int month;
  final String key;
  final String name;
  final DateTime dateFrom;
  final DateTime dateTo;

  static ClosedMonthOption? fromMap(Map<String, dynamic> raw) {
    final year = raw['year'] as int?;
    final month = raw['month'] as int?;
    final key = raw['key'] as String?;
    final fromStr = raw['date_from'] as String?;
    final toStr = raw['date_to'] as String?;
    if (year == null || month == null || key == null || fromStr == null || toStr == null) {
      return null;
    }
    return ClosedMonthOption(
      year: year,
      month: month,
      key: key,
      name: raw['name'] as String? ?? key,
      dateFrom: DateTime.parse(fromStr),
      dateTo: DateTime.parse(toStr),
    );
  }

  static List<ClosedMonthOption> listFromPeriodInfo(Map<String, dynamic> periodInfo) {
    final raw = periodInfo['closed_months'] as List?;
    if (raw == null) return const [];
    return raw
        .map((e) => ClosedMonthOption.fromMap(Map<String, dynamic>.from(e as Map)))
        .whereType<ClosedMonthOption>()
        .toList();
  }

  @override
  List<Object?> get props => [year, month, key, name, dateFrom, dateTo];
}
