import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'constants.dart';

/// Runtime config from `.env` with safe fallbacks.
abstract final class Env {
  static const String odooBaseUrl = AppConstants.odooBaseUrl;
  static const String odooDb = AppConstants.odooDb;
  static const String fcmTopicAllUsers = AppConstants.fcmTopicAllUsers;
  static const String fcmTopicDevelopment = AppConstants.fcmTopicDevelopment;
  static const String fcmTopicAllDevices = AppConstants.fcmTopicAllDevices;
  static const String fcmTopicAllDevicesLower = AppConstants.fcmTopicAllDevicesLower;

  static String get mobileVersionsBaseUrl =>
      dotenv.env['MOBILE_VERSIONS_BASE_URL']?.trim().isNotEmpty == true
          ? dotenv.env['MOBILE_VERSIONS_BASE_URL']!.trim()
          : 'https://api.dev.hudoori.code-solution.org/api';

  static String get reviewEmail =>
      dotenv.env['REVIEW_EMAIL']?.trim().isNotEmpty == true
          ? dotenv.env['REVIEW_EMAIL']!.trim()
          : 'm.abbasy@vicanzagroup.com';

  static String get reviewPassword =>
      dotenv.env['REVIEW_PASSWORD']?.trim().isNotEmpty == true
          ? dotenv.env['REVIEW_PASSWORD']!.trim()
          : '123';
}
