import 'package:dio/dio.dart';

import '../../../../core/network/odoo_client.dart';

class FinancialRemoteDataSource {
  FinancialRemoteDataSource(this._client);
  final OdooClient _client;

  Future<Map<String, dynamic>> partnerInfo() =>
      _client.jsonRpc('/my/financial/api/partner-info');

  Future<Map<String, dynamic>> periodInfo() =>
      _client.jsonRpc('/my/financial/api/period-info');

  Future<Map<String, dynamic>> financialData({
    required String dateFrom,
    required String dateTo,
    int? analyticId,
  }) =>
      _client.jsonRpc('/my/financial/api/data', params: {
        'date_from': dateFrom,
        'date_to': dateTo,
        if (analyticId != null) 'analytic_id': analyticId,
      });

  Future<Map<String, dynamic>> accountDetails({
    required int accountId,
    required String dateFrom,
    required String dateTo,
    int? analyticId,
    int? accountGroupId,
  }) =>
      _client.getJson('/my/financial/api/account-details', queryParameters: {
        'account_id': accountId,
        'date_from': dateFrom,
        'date_to': dateTo,
        if (analyticId != null) 'analytic_id': analyticId,
        if (accountGroupId != null) 'account_group_id': accountGroupId,
      });

  Future<Map<String, dynamic>> pnl({required int year, int? analyticId}) =>
      _client.jsonRpc('/my/financial/api/pnl', params: {
        'year': year,
        if (analyticId != null) 'analytic_id': analyticId,
      });

  Future<Map<String, dynamic>> comparison({
    required List<int> years,
    int? analyticId,
  }) =>
      _client.jsonRpc('/my/financial/api/comparison', params: {
        'years': years.join(','),
        if (analyticId != null) 'analytic_id': analyticId,
      });

  Future<Map<String, dynamic>> growth({int? analyticId}) =>
      _client.jsonRpc('/my/financial/api/growth', params: {
        if (analyticId != null) 'analytic_id': analyticId,
      });

  Future<Map<String, dynamic>> branches({int? analyticId}) =>
      _client.jsonRpc('/my/financial/api/branches', params: {
        if (analyticId != null) 'analytic_id': analyticId,
      });

  Future<Map<String, dynamic>> distributions({
    required int year,
    int? analyticId,
  }) =>
      _client.jsonRpc('/my/financial/api/distributions', params: {
        'year': year,
        if (analyticId != null) 'analytic_id': analyticId,
      });

  Future<Map<String, dynamic>> capital({int? analyticId}) =>
      _client.jsonRpc('/my/financial/api/capital', params: {
        if (analyticId != null) 'analytic_id': analyticId,
      });

  Future<List<int>> downloadBytes({
    required String path,
    Map<String, dynamic>? query,
  }) async {
    final response = await _client.dio.get<List<int>>(
      path,
      queryParameters: query,
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data ?? [];
  }
}
