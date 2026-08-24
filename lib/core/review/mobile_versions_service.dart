import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/env.dart';

/// Calls GetAllMobileVersions and compares with the installed app version.
class MobileVersionsService {
  MobileVersionsService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;
  final _log = Logger();

  /// Returns `true` when the current app version has `isPublish == "true"`.
  Future<bool> isCurrentVersionPublished() async {
    final url =
        '${Env.mobileVersionsBaseUrl}/Authenticate/GetAllMobileVersions';
    _log.i('App flow: versions check START url=$url');
    try {
      final info = await PackageInfo.fromPlatform();
      final currentVersion = info.version;
      final buildNumber = info.buildNumber;
      _log.i(
        'App flow: package info version=$currentVersion '
        'build=$buildNumber package=${info.packageName}',
      );

      final response = await _dio.get<List<dynamic>>(
        url,
        options: Options(
          headers: const {
            'accept': 'application/json',
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
          },
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );

      _log.i('App flow: versions HTTP status=${response.statusCode}');

      final versions = response.data;
      if (versions == null || versions.isEmpty) {
        _log.w('App flow: versions empty → reviewMode=false');
        return false;
      }

      _log.i('App flow: versions payload=$versions');

      for (final raw in versions) {
        if (raw is! Map) continue;
        final version = raw['version']?.toString();
        final rawPublish = raw['isPublish'];
        _log.i(
          'App flow: versions row version=$version '
          'isPublishRaw=$rawPublish match=${version == currentVersion}',
        );
        if (version != currentVersion) continue;
        final published = _parseIsPublish(rawPublish);
        _log.i(
          'App flow: versions MATCH version=$currentVersion '
          'isPublish=$published → reviewMode=$published',
        );
        return published;
      }

      _log.w(
        'App flow: versions NO MATCH for $currentVersion → reviewMode=false',
      );
      return false;
    } catch (e, st) {
      _log.w(
        'App flow: versions check FAILED → reviewMode=false',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  bool _parseIsPublish(Object? value) {
    if (value is bool) return value;
    final s = value?.toString().trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }
}
