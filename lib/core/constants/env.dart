import 'constants.dart';

/// Back-compat alias — prefer [AppConstants] for Odoo/Firebase values.
abstract final class Env {
  static const String odooBaseUrl = AppConstants.odooBaseUrl;
  static const String odooDb = AppConstants.odooDb;
  static const String fcmTopicAllUsers = AppConstants.fcmTopicAllUsers;
}
