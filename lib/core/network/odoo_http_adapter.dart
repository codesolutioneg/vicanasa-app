import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

/// Mobile/desktop: session cookies via cookie_jar.
void configureOdooHttp(Dio dio, {CookieJar? cookieJar}) {
  dio.interceptors.add(CookieManager(cookieJar ?? CookieJar()));
}
