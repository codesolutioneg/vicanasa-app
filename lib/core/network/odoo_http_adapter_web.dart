import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

/// Web: browser sends cookies with cross-origin requests when Odoo allows CORS.
void configureOdooHttp(Dio dio, {Object? cookieJar}) {
  dio.httpClientAdapter = BrowserHttpClientAdapter(withCredentials: true);
}
