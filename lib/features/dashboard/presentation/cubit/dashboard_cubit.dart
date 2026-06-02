import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    result.fold(
      (f) => emit(DashboardError(f.message)),
      (data) => emit(DashboardLoaded(data)),
    );
  }
}
