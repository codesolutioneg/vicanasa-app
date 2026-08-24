import 'package:flutter/material.dart';

import '../../shell/domain/closed_month_option.dart';
import '../../shell/presentation/cubit/filter_cubit.dart';
import '../data/comparison_loader.dart';
import '../domain/comparison_card_data.dart';
import '../domain/comparison_mode.dart';
import '../domain/comparison_period.dart';
import '../domain/comparison_period_rules.dart';
import 'comparison_selection.dart';

/// Mutable session state + load for ComparisonPage.
class ComparisonSession {
  ComparisonSession(this._loader);

  final ComparisonLoader _loader;

  ComparisonMode mode = ComparisonMode.year;
  List<int> availableYears = [];
  List<int> selectedYears = [];

  /// Year chosen before picking months / custom ranges.
  int? scopeYear;

  List<String> selectedMonthKeys = [];
  List<ComparisonPeriod> customPeriods = [];
  List<ComparisonCardData> cards = [];
  String? error;
  String? validationError;
  bool loading = false;
  bool bootstrapped = false;
  int? lastBranchId;

  void bootstrap(FilterState filter) {
    final end = filter.closedEnd ?? DateTime.now();
    final maxYear = end.year;
    availableYears = [for (var y = maxYear - 5; y <= maxYear; y++) y];
    selectedYears = [
      if (maxYear - 2 >= availableYears.first) maxYear - 2,
      if (maxYear - 1 >= availableYears.first) maxYear - 1,
      maxYear,
    ];
    scopeYear = maxYear;
    bootstrapped = true;
    lastBranchId = filter.analyticId;
  }

  List<ComparisonPeriod> periods(FilterState filter) =>
      ComparisonSelection.periods(
        mode: mode,
        filter: filter,
        selectedYears: selectedYears,
        selectedMonthKeys: selectedMonthKeys,
        customPeriods: customPeriods,
      );

  Future<void> load(FilterState filter) async {
    if (!bootstrapped) return;
    final p = periods(filter);

    if (mode == ComparisonMode.custom) {
      validationError = ComparisonPeriodRules.assertSameDuration(p);
      if (validationError != null) {
        cards = [];
        loading = false;
        error = null;
        return;
      }
    } else {
      validationError = null;
    }

    if (!ComparisonPeriodRules.canLoad(p)) {
      cards = [];
      loading = false;
      error = null;
      validationError = 'Select at least 2 periods to compare.';
      return;
    }

    loading = true;
    error = null;

    final result = await _loader.load(
      mode: mode,
      filter: filter,
      selectedYears: selectedYears,
      periods: p,
    );

    if (result.error != null) {
      error = result.error;
      cards = [];
    } else {
      cards = result.cards;
      if (result.availableYears != null) {
        availableYears = result.availableYears!;
      }
      if (result.selectedYears != null) {
        selectedYears = result.selectedYears!;
      }
    }
    loading = false;
  }

  void setMode(ComparisonMode next) {
    mode = next;
    validationError = null;
    error = null;
    if (next != ComparisonMode.year &&
        scopeYear == null &&
        availableYears.isNotEmpty) {
      scopeYear = availableYears.last;
    }
  }

  void setScopeYear(int year) {
    scopeYear = year;
  }

  void toggleYear(int y) {
    if (selectedYears.contains(y)) {
      if (selectedYears.length > 1) {
        selectedYears = selectedYears.where((e) => e != y).toList();
      }
    } else {
      selectedYears = [...selectedYears, y]..sort();
    }
  }

  void toggleMonth(ClosedMonthOption m) {
    if (selectedMonthKeys.contains(m.key)) {
      if (selectedMonthKeys.length > 1) {
        selectedMonthKeys =
            selectedMonthKeys.where((e) => e != m.key).toList();
      }
    } else {
      selectedMonthKeys = [...selectedMonthKeys, m.key];
    }
  }

  void addCustom(DateTimeRange range) {
    customPeriods = [
      ...customPeriods,
      ComparisonPeriodRules.periodFromCustom(
        from: range.start,
        to: range.end,
      ),
    ];
  }

  void removeCustom(String id) {
    customPeriods = customPeriods.where((p) => p.id != id).toList();
  }

  bool consumeBranchChange(int? analyticId) {
    if (lastBranchId == analyticId || !bootstrapped) return false;
    lastBranchId = analyticId;
    return true;
  }
}
