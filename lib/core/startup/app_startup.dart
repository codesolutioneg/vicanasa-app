import 'package:flutter/foundation.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:logger/logger.dart';

import '../firebase/firebase_bootstrap.dart';
import '../notifications/notification_service.dart';

/// Heavy startup (Firebase, FCM, LiquidGlass) — runs after first frame.
class AppStartup {
  AppStartup._();

  static final _log = Logger();
  static Future<void>? _task;
  static bool liquidGlassReady = false;

  /// Schedules non-blocking init; safe to call multiple times.
  static Future<void> schedule() => _task ??= _run();

  static Future<void> _run() async {
    if (!kIsWeb) {
      try {
        await FirebaseBootstrap.initialize();
      } catch (e, st) {
        _log.w('Firebase startup skipped', error: e, stackTrace: st);
      }
      if (FirebaseBootstrap.isReady) {
        try {
          await initNotifications();
        } catch (e, st) {
          _log.w('FCM startup skipped', error: e, stackTrace: st);
        }
      }
    }

    try {
      await LiquidGlassWidgets.initialize();
      liquidGlassReady = true;
      _log.i('LiquidGlass ready');
    } catch (e, st) {
      _log.w('LiquidGlass startup skipped', error: e, stackTrace: st);
    }
  }
}
