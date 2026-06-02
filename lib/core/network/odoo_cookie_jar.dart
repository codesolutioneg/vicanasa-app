import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Persists Odoo `session_id` cookies on mobile/desktop so users stay signed in.
/// Web uses the browser cookie jar via [withCredentials] (no file storage).
Future<CookieJar?> createOdooCookieJar() async {
  if (kIsWeb) return null;
  final dir = await getApplicationDocumentsDirectory();
  return PersistCookieJar(
    storage: FileStorage('${dir.path}/odoo_cookies'),
  );
}
