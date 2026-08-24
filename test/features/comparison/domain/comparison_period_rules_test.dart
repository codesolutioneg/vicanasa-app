import 'package:flutter_test/flutter_test.dart';

import 'package:vacansa/features/comparison/domain/comparison_period.dart';
import 'package:vacansa/features/comparison/domain/comparison_period_rules.dart';

void main() {
  group('ComparisonPeriodRules.inclusiveDayCount', () {
    test('counts inclusive single day', () {
      final d = DateTime(2026, 7, 1);
      expect(ComparisonPeriodRules.inclusiveDayCount(d, d), 1);
    });

    test('counts full July 2026', () {
      expect(
        ComparisonPeriodRules.inclusiveDayCount(
          DateTime(2026, 7, 1),
          DateTime(2026, 7, 31),
        ),
        31,
      );
    });

    test('counts leap February 2024', () {
      expect(
        ComparisonPeriodRules.inclusiveDayCount(
          DateTime(2024, 2, 1),
          DateTime(2024, 2, 29),
        ),
        29,
      );
    });

    test('returns 0 when end before start', () {
      expect(
        ComparisonPeriodRules.inclusiveDayCount(
          DateTime(2026, 7, 31),
          DateTime(2026, 7, 1),
        ),
        0,
      );
    });
  });

  group('ComparisonPeriodRules.assertSameDuration', () {
    test('ok when two customs share day count', () {
      final a = ComparisonPeriodRules.periodFromCustom(
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 1, 31),
      );
      final b = ComparisonPeriodRules.periodFromCustom(
        from: DateTime(2026, 3, 1),
        to: DateTime(2026, 3, 31),
      );
      expect(ComparisonPeriodRules.assertSameDuration([a, b]), isNull);
    });

    test('fails when durations differ', () {
      final a = ComparisonPeriodRules.periodFromCustom(
        from: DateTime(2026, 1, 1),
        to: DateTime(2026, 1, 31),
      );
      final b = ComparisonPeriodRules.periodFromCustom(
        from: DateTime(2026, 2, 1),
        to: DateTime(2026, 2, 28),
      );
      final err = ComparisonPeriodRules.assertSameDuration([a, b]);
      expect(err, isNotNull);
      expect(err!, contains('same duration'));
    });

    test('fails with fewer than 2 periods', () {
      final a = ComparisonPeriodRules.periodFromYear(2026);
      expect(
        ComparisonPeriodRules.assertSameDuration([a]),
        'Select at least 2 periods to compare.',
      );
    });
  });

  group('ComparisonPeriodRules.periodFromYear / periodFromMonth', () {
    test('year spans Jan–Dec', () {
      final p = ComparisonPeriodRules.periodFromYear(2025);
      expect(p.dateFrom, DateTime(2025, 1, 1));
      expect(p.dateTo, DateTime(2025, 12, 31));
      expect(p.label, '2025');
    });

    test('year capped by closedEnd', () {
      final p = ComparisonPeriodRules.periodFromYear(
        2026,
        closedEnd: DateTime(2026, 7, 31),
      );
      expect(p.dateFrom, DateTime(2026, 1, 1));
      expect(p.dateTo, DateTime(2026, 7, 31));
    });

    test('month spans full month', () {
      final p = ComparisonPeriodRules.periodFromMonth(2026, 7);
      expect(p.dateFrom, DateTime(2026, 7, 1));
      expect(p.dateTo, DateTime(2026, 7, 31));
      expect(p.id, 'm2026-07');
    });
  });

  group('ComparisonPeriodRules.canLoad', () {
    test('requires at least two periods', () {
      expect(ComparisonPeriodRules.canLoad(const []), isFalse);
      expect(
        ComparisonPeriodRules.canLoad([
          ComparisonPeriod(
            id: 'a',
            label: 'A',
            dateFrom: DateTime(2026, 1, 1),
            dateTo: DateTime(2026, 1, 31),
          ),
        ]),
        isFalse,
      );
      expect(
        ComparisonPeriodRules.canLoad([
          ComparisonPeriodRules.periodFromYear(2025),
          ComparisonPeriodRules.periodFromYear(2026),
        ]),
        isTrue,
      );
    });
  });
}
