import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/notifications/notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await LiquidGlassWidgets.initialize();
    await configureDependencies();
    if (!kIsWeb) {
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        await initNotifications();
      } catch (e) {
        Logger().w('Firebase not configured yet: $e');
      }
    }
    FlutterError.onError = (details) {
      Logger().e('Flutter error', error: details.exception, stackTrace: details.stack);
    };
    runApp(LiquidGlassWidgets.wrap(child: const VacansaApp()));
  }, (error, stack) {
    Logger().e('Uncaught error', error: error, stackTrace: stack);
  });
}
