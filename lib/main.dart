import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:logger/logger.dart';

import 'app.dart';
import 'core/di/injection.dart';
import 'core/startup/app_startup.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await configureDependencies();

    FlutterError.onError = (details) {
      Logger().e('Flutter error', error: details.exception, stackTrace: details.stack);
    };

    runApp(const VacansaBootstrap());
  }, (error, stack) {
    Logger().e('Uncaught error', error: error, stackTrace: stack);
  });
}

/// Shows UI immediately; Firebase / LiquidGlass run after the first frame.
class VacansaBootstrap extends StatefulWidget {
  const VacansaBootstrap({super.key});

  @override
  State<VacansaBootstrap> createState() => _VacansaBootstrapState();
}

class _VacansaBootstrapState extends State<VacansaBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await AppStartup.schedule();
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    const app = VacansaApp();
    if (AppStartup.liquidGlassReady) {
      return LiquidGlassWidgets.wrap(child: app);
    }
    return app;
  }
}
