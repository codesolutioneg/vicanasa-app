/// App-wide constants (Odoo, Firebase, branding).
abstract final class AppConstants {
  static const String appName = 'Vicanza';

  /// Odoo Online portal — [codesolutioneg-jouma](https://codesolutioneg-jouma.odoo.com/)
  static const String odooBaseUrl = 'https://codesolutioneg-jouma.odoo.com';

  static const String odooDb = 'codesolutioneg-jouma-main-25164041';

  static const String firebaseProjectId = 'vacanca-app';

  static const String fcmTopicAllUsers = 'all_users';

  static const String fcmTopicDevelopment = 'development';

  /// Broadcast topics used by the working Hesham Tarek FCM sender.
  static const String fcmTopicAllDevices = 'allDevices';

  static const String fcmTopicAllDevicesLower = 'alldevices';

  static const String fcmAndroidChannelId = 'high_importance_channel';

  static const String androidApplicationId = 'com.codesolution.vacansa';

  static const String iosBundleId = 'com.codesolution.vacansa';
}
