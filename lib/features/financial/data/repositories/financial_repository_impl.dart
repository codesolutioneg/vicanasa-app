import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/partner_info.dart';
import '../../domain/repositories/financial_repository.dart';
import '../datasources/financial_remote_datasource.dart';

class FinancialRepositoryImpl implements FinancialRepository {
  FinancialRepositoryImpl(this._remote);
  final FinancialRemoteDataSource _remote;

  @override
  Future<Either<Failure, PartnerInfo>> getPartnerInfo() async {
    try {
      final data = await _remote.partnerInfo();
      final options = (data['analytic_options'] as List? ?? [])
          .map((e) {
            final m = Map<String, dynamic>.from(e as Map);
            return AnalyticOption(
              id: m['id'] as int,
              name: m['name'] as String? ?? '',
              sharePercentage: (m['share_percentage'] as num?)?.toDouble() ?? 0,
            );
          })
          .toList();
      return Right(PartnerInfo(
        isFinancialPartner: data['is_financial_partner'] == true,
        partnerId: data['partner_id'] as int?,
        partnerName: data['partner_name'] as String?,
        analyticOptions: options,
      ));
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> _map(
    Future<Map<String, dynamic>> Function() call,
  ) async {
    try {
      return Right(await call());
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPeriodInfo() =>
      _map(_remote.periodInfo);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFinancialData({
    required String dateFrom,
    required String dateTo,
    int? analyticId,
  }) =>
      _map(() => _remote.financialData(
            dateFrom: dateFrom,
            dateTo: dateTo,
            analyticId: analyticId,
          ));

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAccountDetails({
    required int accountId,
    required String dateFrom,
    required String dateTo,
    int? analyticId,
    int? accountGroupId,
  }) =>
      _map(() => _remote.accountDetails(
            accountId: accountId,
            dateFrom: dateFrom,
            dateTo: dateTo,
            analyticId: analyticId,
            accountGroupId: accountGroupId,
          ));

  @override
  Future<Either<Failure, Map<String, dynamic>>> getPnl({
    required int year,
    int? analyticId,
  }) =>
      _map(() => _remote.pnl(year: year, analyticId: analyticId));

  @override
  Future<Either<Failure, Map<String, dynamic>>> getComparison({
    required List<int> years,
    int? analyticId,
  }) =>
      _map(() => _remote.comparison(years: years, analyticId: analyticId));

  @override
  Future<Either<Failure, Map<String, dynamic>>> getGrowth({int? analyticId}) =>
      _map(() => _remote.growth(analyticId: analyticId));

  @override
  Future<Either<Failure, Map<String, dynamic>>> getBranches({int? analyticId}) =>
      _map(() => _remote.branches(analyticId: analyticId));

  @override
  Future<Either<Failure, Map<String, dynamic>>> getDistributions({
    required int year,
    int? analyticId,
  }) =>
      _map(() => _remote.distributions(year: year, analyticId: analyticId));

  @override
  Future<Either<Failure, Map<String, dynamic>>> getCapital({int? analyticId}) =>
      _map(() => _remote.capital(analyticId: analyticId));

  @override
  Future<Either<Failure, List<int>>> downloadReport({
    required String format,
    required String reportType,
    int? year,
    String? dateFrom,
    String? dateTo,
    int? analyticId,
  }) async {
    try {
      final path = format == 'excel'
          ? '/my/financial/reports/download/excel'
          : '/my/financial/reports/download/pdf';
      final bytes = await _remote.downloadBytes(
        path: path,
        query: {
          'report_type': reportType,
          if (year != null) 'year': year,
          if (dateFrom != null) 'date_from': dateFrom,
          if (dateTo != null) 'date_to': dateTo,
          if (analyticId != null) 'analytic_id': analyticId,
        },
      );
      return Right(bytes);
    } on NetworkException {
      return const Left(NetworkFailure());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
