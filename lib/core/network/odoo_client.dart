import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants/env.dart';
import '../error/exceptions.dart';
import 'odoo_error_mapper.dart';
import 'odoo_http_adapter.dart'
    if (dart.library.html) 'odoo_http_adapter_web.dart';
import 'odoo_logging_interceptor.dart';

/// HTTP + JSON-RPC client for Odoo portal session auth.
class OdooClient {
  OdooClient({Dio? dio, Logger? logger, CookieJar? cookieJar})
      : _logger = logger ?? Logger(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: Env.odooBaseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 30),
              headers: {'Content-Type': 'application/json'},
            )) {
    configureOdooHttp(_dio, cookieJar: cookieJar);
    _dio.interceptors.add(OdooLoggingInterceptor());
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (e, handler) {
          if (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            return handler.reject(
              DioException(
                requestOptions: e.requestOptions,
                error: NetworkException(),
              ),
            );
          }
          handler.next(e);
        },
      ),
    );
  }

  final Dio _dio;
  final Logger _logger;

  Dio get dio => _dio;

  Future<Map<String, dynamic>> jsonRpc(
    String path, {
    Map<String, dynamic>? params,
  }) async {
    final body = {
      'jsonrpc': '2.0',
      'method': 'call',
      'params': params ?? <String, dynamic>{},
      'id': DateTime.now().millisecondsSinceEpoch,
    };
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final data = response.data;
      if (data == null) throw ServerException('Empty response');
      if (data['error'] != null) {
        final err = data['error'] as Map<String, dynamic>;
        final msg = err['data']?['message'] ?? err['message'] ?? 'RPC error';
        throw ServerException('$msg');
      }
      final result = data['result'];
      if (result is Map<String, dynamic>) {
        if (result['error'] != null) {
          throw ServerException('${result['error']}');
        }
        return result;
      }
      if (result is Map) {
        return Map<String, dynamic>.from(result);
      }
      return {'data': result};
    } on DioException catch (e) {
      if (e.error is NetworkException) rethrow;
      final status = e.response?.statusCode;
      if (status != null && status >= 500) {
        _logger.w('Odoo server error $status on $path');
      } else {
        _logger.e('JSON-RPC error', error: e);
      }
      throwMappedDio(e);
    }
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return response.data ?? {};
    } on DioException catch (e) {
      if (e.error is NetworkException) rethrow;
      throwMappedDio(e);
    }
  }

  /// Portal session login (CORS-enabled for Flutter web).
  static const authenticatePath = '/my/financial/api/auth/authenticate';
  static const logoutPath = '/my/financial/api/auth/logout';
  static const resetPasswordPath = '/my/financial/api/auth/reset-password';

  Future<void> authenticate({
    required String db,
    required String login,
    required String password,
  }) async {
    final result = await jsonRpc(
      authenticatePath,
      params: {'db': db, 'login': login, 'password': password},
    );
    final uid = result['uid'];
    final sessionId = result['session_id'];
    if ((uid == null || uid == false) &&
        (sessionId == null || sessionId == false || '$sessionId'.isEmpty)) {
      throw AuthException('Invalid credentials');
    }
  }

  Future<void> resetPassword({required String email}) async {
    final result = await jsonRpc(
      resetPasswordPath,
      params: {'email': email.trim()},
    );
    if (result['success'] == false) {
      throw ServerException('${result['error'] ?? 'Could not reset password'}');
    }
  }

  Future<void> logout() async {
    try {
      await jsonRpc(logoutPath);
    } catch (_) {
      try {
        await _dio.get('/web/session/logout');
      } catch (_) {}
    }
  }
}
