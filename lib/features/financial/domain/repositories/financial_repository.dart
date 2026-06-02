import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/partner_info.dart';

abstract interface class FinancialRepository {
  Future<Either<Failure, PartnerInfo>> getPartnerInfo();
  Future<Either<Failure, Map<String, dynamic>>> getPeriodInfo();
  Future<Either<Failure, Map<String, dynamic>>> getFinancialData({
    required String dateFrom,
    required String dateTo,
    int? analyticId,
  });
  Future<Either<Failure, Map<String, dynamic>>> getAccountDetails({
    required int accountId,
    required String dateFrom,
    required String dateTo,
    int? analyticId,
    int? accountGroupId,
  });
  Future<Either<Failure, Map<String, dynamic>>> getPnl({
    required int year,
    int? analyticId,
  });
  Future<Either<Failure, Map<String, dynamic>>> getComparison({
    required List<int> years,
    int? analyticId,
  });
  Future<Either<Failure, Map<String, dynamic>>> getGrowth({int? analyticId});
  Future<Either<Failure, Map<String, dynamic>>> getBranches({int? analyticId});
  Future<Either<Failure, Map<String, dynamic>>> getDistributions({
    required int year,
    int? analyticId,
  });
  Future<Either<Failure, Map<String, dynamic>>> getCapital({int? analyticId});
  Future<Either<Failure, List<int>>> downloadReport({
    required String format,
    required String reportType,
    int? year,
    String? dateFrom,
    String? dateTo,
    int? analyticId,
  });
}
