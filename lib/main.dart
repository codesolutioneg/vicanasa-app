import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/startup/app_startup.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: '.env');
    await configureDependencies();

    FlutterError.onError = (details) {
      Logger().e(
        'Flutter error',
        error: details.exception,
        stackTrace: details.stack,
      );
    };

    runApp(const VacansaBootstrap());
  }, (error, stack) {
    Logger().e('Uncaught error', error: error, stackTrace: stack);
  });
}

/// Shows UI immediately; Firebase / LiquidGlass run after the first frame.
///
/// Important: [VacansaApp] must stay mounted for the whole lifetime. Swapping
/// the root between bare app ↔ LiquidGlass wrap remounts GoRouter/splash and
/// makes the splash play twice.
class VacansaBootstrap extends StatefulWidget {
  const VacansaBootstrap({super.key});

  @override
  State<VacansaBootstrap> createState() => _VacansaBootstrapState();
}

class _VacansaBootstrapState extends State<VacansaBootstrap> {
  static const Key _appKey = ValueKey<String>('vacansa_app');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(AppStartup.schedule());
    });
  }

  @override
  Widget build(BuildContext context) {
    // Always wrap so the child Element for VacansaApp never moves/disposes
    // when LiquidGlass finishes initializing.
    return LiquidGlassWidgets.wrap(
      child: const VacansaApp(key: _appKey),
    );
  }
}
