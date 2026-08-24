import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/review/review_mode_cubit.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_fonts.dart';
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
        BlocProvider.value(value: sl<ReviewModeCubit>()),
        BlocProvider(create: (_) => sl<FilterCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Vicanza',
        theme: AppTheme.forLocale(const Locale('en')),
        routerConfig: _router,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (locale, supported) {
          if (locale == null) return const Locale('en');
          for (final s in supported) {
            if (s.languageCode == locale.languageCode) return s;
          }
          return const Locale('en');
        },
        builder: (context, child) {
          final locale = Localizations.localeOf(context);
          final themed = Theme(
            data: AppTheme.forLocale(locale),
            child: child ?? const SizedBox.shrink(),
          );
          if (!AppFonts.isArabic(locale)) {
            return ConnectivityGate(child: themed);
          }
          return ConnectivityGate(
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontFamily: AppFonts.tajawal),
              child: themed,
            ),
          );
        },
      ),
    );
  }
}
