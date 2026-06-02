import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Colored API logger: outbound cyan, success green, failure red.
abstract final class OdooApiLog {
  static final Logger instance = Logger(
    filter: _DebugLogFilter(),
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 0,
      colors: true,
      printEmojis: true,
      lineLength: 100,
      levelColors: {
        Level.debug: AnsiColor.fg(36), // cyan — outbound request
        Level.info: AnsiColor.fg(32), // green — success
        Level.error: AnsiColor.fg(31), // red — failure
      },
    ),
  );
}

class _DebugLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => kDebugMode;
}

/// Logs Odoo HTTP traffic in debug builds (passwords redacted).
class OdooLoggingInterceptor extends Interceptor {
  OdooLoggingInterceptor([Logger? logger]) : _log = logger ?? OdooApiLog.instance;

  final Logger _log;

  static const _sensitiveKeys = {'password', 'passwd', 'token', 'session_id'};

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['_odooRequestStart'] = DateTime.now();
    _log.d('API → ${options.method} ${options.uri}');
    final body = options.data;
    if (body != null) {
      _log.d('    ${_sanitize(body)}');
    }
    final query = options.queryParameters;
    if (query.isNotEmpty) {
      _log.d('    query: $query');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final start = response.requestOptions.extra['_odooRequestStart'] as DateTime?;
    final ms = start != null
        ? DateTime.now().difference(start).inMilliseconds
        : null;
    final path = response.requestOptions.path;
    final code = response.statusCode ?? 0;
    final ok = code >= 200 && code < 300;

    if (ok) {
      _log.i(
        'API ✓ $code $path${ms != null ? ' (${ms}ms)' : ''}',
      );
    } else {
      _log.e(
        'API ✗ $code $path${ms != null ? ' (${ms}ms)' : ''}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final path = err.requestOptions.path;
    final status = err.response?.statusCode;
    _log.e(
      'API ✗ ${err.requestOptions.method} $path'
      '${status != null ? ' [$status]' : ''}: ${err.message}',
    );
    handler.next(err);
  }

  String _sanitize(Object body) {
    if (body is Map) {
      return Map<String, dynamic>.from(body).map((k, v) {
        if (_sensitiveKeys.contains(k.toString().toLowerCase())) {
          return MapEntry(k, '***');
        }
        if (k == 'params' && v is Map) {
          return MapEntry(k, _sanitize(v));
        }
        return MapEntry(k, v);
      }).toString();
    }
    return body.toString();
  }
}
