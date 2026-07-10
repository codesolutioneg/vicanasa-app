import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

import '../../firebase_options.dart';

/// Guards Firebase / FCM usage when setup is incomplete (e.g. missing APNs key).
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static final _log = Logger();
  static bool _initialized = false;

  /// True after [initialize] succeeds on mobile.
  static bool get isReady => _initialized;

  /// Initializes the default Firebase app. Safe to call multiple times.
  static Future<bool> initialize() async {
    if (kIsWeb) return false;
    if (_initialized) return true;
    if (Firebase.apps.isNotEmpty) {
      _initialized = true;
      return true;
    }
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      if (kDebugMode) {
        _log.i('Firebase initialized');
      }
      return true;
    } catch (e, st) {
      _log.w('Firebase init skipped — app continues without FCM', error: e, stackTrace: st);
      return false;
    }
  }
}
