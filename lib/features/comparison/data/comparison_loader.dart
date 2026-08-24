import '../../financial/domain/repositories/financial_repository.dart';
import '../../shell/presentation/cubit/filter_cubit.dart';
import '../domain/comparison_card_data.dart';
import '../domain/comparison_mode.dart';
import '../domain/comparison_period.dart';

/// Result of a comparison load.
class ComparisonLoadResult {
  const ComparisonLoadResult({
    required this.cards,
    this.availableYears,
    this.selectedYears,
    this.error,
  });

  final List<ComparisonCardData> cards;
  final List<int>? availableYears;
  final List<int>? selectedYears;
  final String? error;
}

/// Loads comparison cards for year API or per-period `/api/data`.
class ComparisonLoader {
  ComparisonLoader(this._repo);

  final FinancialRepository _repo;

  Future<ComparisonLoadResult> load({
    required ComparisonMode mode,
    required FilterState filter,
    required List<int> selectedYears,
    required List<ComparisonPeriod> periods,
  }) async {
    if (mode == ComparisonMode.year) {
      return _loadYears(filter: filter, selectedYears: selectedYears);
    }
    return _loadRanges(filter: filter, periods: periods);
  }

  Future<ComparisonLoadResult> _loadYears({
    required FilterState filter,
    required List<int> selectedYears,
  }) async {
    final result = await _repo.getComparison(
      years: selectedYears,
      analyticId: filter.analyticId,
    );
    return result.fold(
      (f) => ComparisonLoadResult(cards: const [], error: f.message),
      (d) {
        final available =
            (d['available_years'] as List?)?.cast<int>() ?? selectedYears;
        final selected =
            (d['selected_years'] as List?)?.cast<int>() ?? selectedYears;
        final rows = d['comparison_data'] as List? ?? [];
        final cards = <ComparisonCardData>[
          for (final r in rows)
            if (r is Map)
              ComparisonCardData.fromApiMap(
                Map<String, dynamic>.from(r),
                label: '${r['year'] ?? ''}',
              ),
        ];
        return ComparisonLoadResult(
          cards: cards,
          availableYears: available,
          selectedYears: selected,
        );
      },
    );
  }

  Future<ComparisonLoadResult> _loadRanges({
    required FilterState filter,
    required List<ComparisonPeriod> periods,
  }) async {
    final cards = <ComparisonCardData>[];
    for (final p in periods) {
      final result = await _repo.getFinancialData(
        dateFrom: p.dateFromStr,
        dateTo: p.dateToStr,
        analyticId: filter.analyticId,
      );
      final card = result.fold<ComparisonCardData?>(
        (_) => null,
        (d) => ComparisonCardData.fromApiMap(d, label: p.label),
      );
      if (card == null) {
        return ComparisonLoadResult(
          cards: const [],
          error: 'Failed to load ${p.label}',
        );
      }
      cards.add(card);
    }
    return ComparisonLoadResult(cards: cards);
  }
}
