import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/dashboard_metrics.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardLoaded extends DashboardState {
  const DashboardLoaded(this.data);
  final Map<String, dynamic> data;
  @override
  List<Object?> get props => [data];
}

final class DashboardError extends DashboardState {
  const DashboardError(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit(this._repo) : super(DashboardInitial());

  final FinancialRepository _repo;

  Future<void> load(FilterState filter) async {
    emit(DashboardLoading());
    final result = await _repo.getFinancialData(
      dateFrom: filter.dateFromStr,
      dateTo: filter.dateToStr,
      analyticId: filter.analyticId,
    );
    await result.fold(
      (f) async => emit(DashboardError(f.message)),
      (data) async {
        final pnl = await _enrichBranchPnl(data, filter);
        final capitalFuture =
            _enrichLifetimeCapital(pnl, filter.analyticId);
        final trendFuture = _fetchYearlyTrend(filter, pnl);
        final capital = await capitalFuture;
        final trend = await trendFuture;
        emit(DashboardLoaded({
          ...capital,
          if (trend != null) ...{
            'monthly_data': trend,
            'monthly_chart': trend,
          },
        }));
      },
    );
  }

  /// `/api/data` analytic_options omit P&L lines; fetch per branch for same dates.
  Future<Map<String, dynamic>> _enrichBranchPnl(
    Map<String, dynamic> data,
    FilterState filter,
  ) async {
    final raw = data['analytic_options'];
    if (raw is! List || raw.isEmpty) return data;

    final options = raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final futures = options.map((opt) async {
      final id = (opt['id'] as num?)?.toInt();
      if (id == null) return opt;
      if (filter.analyticId != null && filter.analyticId != id) {
        return opt;
      }
      if (filter.analyticId == id) {
        _applyPnlFields(opt, data);
        return opt;
      }
      final branch = await _repo.getFinancialData(
        dateFrom: filter.dateFromStr,
        dateTo: filter.dateToStr,
        analyticId: id,
      );
      return branch.fold((_) => opt, (bd) {
        _applyPnlFields(opt, bd);
        return opt;
      });
    });

    final enriched = await Future.wait(futures);
    return {...data, 'analytic_options': enriched};
  }

  void _applyPnlFields(Map<String, dynamic> opt, Map<String, dynamic> src) {
    final revenue = (src['revenue'] as num?)?.toDouble() ?? 0;
    final groups = _groups(src['revenue_grouped']);
    final ratios = src['ratios'] is Map
        ? Map<String, dynamic>.from(src['ratios'] as Map)
        : null;
    final split = DashboardMetrics.salesAndOtherIncome(
      revenue: revenue,
      revenueGrouped: groups,
      ratios: ratios,
    );
    opt['revenue'] = revenue;
    opt['sales'] = split.sales;
    opt['other_income'] = split.otherIncome;
    opt['cost'] = src['cost'];
    opt['expense'] = src['expense'];
    opt['net_profit'] = src['net_profit'];
  }

  /// Lifetime capital and distributions from `/api/capital` — ignores From/To.
  Future<Map<String, dynamic>> _enrichLifetimeCapital(
    Map<String, dynamic> data,
    int? analyticId,
  ) async {
    final result = await _repo.getCapital(analyticId: analyticId);
    return result.fold((_) => data, (src) {
      final byName = <String, ({double capital, double distribution})>{};
      final rawBranches = src['branch_capital_data'];
      if (rawBranches is List) {
        for (final e in rawBranches) {
          if (e is! Map) continue;
          final m = Map<String, dynamic>.from(e);
          final name = '${m['name'] ?? ''}'.trim();
          if (name.isEmpty) continue;
          byName[name] = (
            capital: (m['capital'] as num?)?.toDouble() ?? 0,
            distribution: (m['distributions'] as num?)?.toDouble() ?? 0,
          );
        }
      }
      final raw = data['analytic_options'];
      if (raw is! List) {
        return {
          ...data,
          'capital_balance': src['total_capital'],
          'distribution_balance': src['total_distributions'],
        };
      }
      final options = raw
          .whereType<Map>()
          .map((e) {
            final opt = Map<String, dynamic>.from(e);
            final row = byName['${opt['name'] ?? ''}'.trim()];
            if (row != null) {
              opt['capital'] = row.capital;
              opt['distribution'] = row.distribution;
            }
            return opt;
          })
          .toList();
      return {
        ...data,
        'analytic_options': options,
        'capital_balance': src['total_capital'] ?? data['capital_balance'],
        'distribution_balance':
            src['total_distributions'] ?? data['distribution_balance'],
      };
    });
  }

  /// Current-year monthly trend — ignores dashboard From/To (Jan → closed end).
  Future<dynamic> _fetchYearlyTrend(
    FilterState filter,
    Map<String, dynamic> data,
  ) async {
    final end = _yearTrendEnd(filter, data);
    final from = DateTime(end.year, 1, 1);
    final result = await _repo.getFinancialData(
      dateFrom: _ymd(from),
      dateTo: _ymd(end),
      analyticId: filter.analyticId,
    );
    return result.fold(
      (_) => null,
      (src) => src['monthly_data'] ?? src['monthly_chart'],
    );
  }

  DateTime _yearTrendEnd(FilterState filter, Map<String, dynamic> data) {
    if (filter.closedEnd != null) return filter.closedEnd!;
    final closed = data['closed_end'];
    if (closed is String && closed.isNotEmpty) {
      return DateTime.parse(closed);
    }
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  String _ymd(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<Map<String, dynamic>> _groups(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
