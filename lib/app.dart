import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/connectivity_gate.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/shell/presentation/cubit/filter_cubit.dart';
import 'l10n/app_localizations.dart';

class VacansaApp extends StatefulWidget {
  const VacansaApp({super.key});

  @override
  State<VacansaApp> createState() => _VacansaAppState();
}

class _VacansaAppState extends State<VacansaApp> {
  late final AuthCubit _authCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>();
    _router = createAppRouter(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider(create: (_) => sl<FilterCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Vicanza',
        theme: AppTheme.light(),
        routerConfig: _router,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => ConnectivityGate(
          child: child ?? const SizedBox.shrink(),
        ),
      ),
    );
  }
}
