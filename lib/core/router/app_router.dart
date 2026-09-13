import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/pages/access_denied_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/reset_password_sent_page.dart';
import '../../features/auth/presentation/cubit/reset_password_cubit.dart';
import '../../features/branches/presentation/pages/branches_page.dart';
import '../../features/capital/presentation/pages/capital_page.dart';
import '../../features/comparison/presentation/pages/comparison_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/distributions/presentation/pages/distributions_page.dart';
import '../../features/growth/presentation/pages/growth_page.dart';
import '../../features/onboarding/data/onboarding_repository.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/pnl/presentation/pages/pnl_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/shell/presentation/pages/financial_shell_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../di/injection.dart';
import '../notifications/navigation_service.dart';
import 'app_page_transitions.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const forgotPassword = '/forgot-password';
  static const resetPasswordSent = '/reset-password-sent';
  static const accessDenied = '/access-denied';
  static const dashboard = '/dashboard';
  static const pnl = '/pnl';
  static const comparison = '/comparison';
  static const reports = '/reports';
  static const growth = '/growth';
  static const branches = '/branches';
  static const distributions = '/distributions';
  static const capital = '/capital';
}

final _routerLog = Logger();

GoRouter createAppRouter(AuthCubit authCubit) {
  return GoRouter(
    navigatorKey: NavigationService.rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthRefresh(authCubit),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final auth = authCubit.state;
      String? target;
      if (auth is AuthInitial) {
        if (loc != AppRoutes.splash) target = AppRoutes.splash;
      } else if (auth is AuthLoading) {
        // Stay on login/splash while signing in.
      } else if (auth is AuthUnauthenticated || auth is AuthError) {
        const publicLocs = {
          AppRoutes.login,
          AppRoutes.onboarding,
          AppRoutes.forgotPassword,
          AppRoutes.resetPasswordSent,
        };
        if (!publicLocs.contains(loc)) {
          target = AppRoutes.login;
        }
      } else if (auth is AuthAccessDenied) {
        if (loc != AppRoutes.accessDenied) target = AppRoutes.accessDenied;
      } else if (auth is AuthAuthenticated) {
        if (loc == AppRoutes.login ||
            loc == AppRoutes.onboarding ||
            loc == AppRoutes.forgotPassword ||
            loc == AppRoutes.resetPasswordSent) {
          target = AppRoutes.dashboard;
        }
      }
      _routerLog.i(
        'App flow: router redirect loc=$loc auth=${auth.runtimeType} '
        '→ ${target ?? 'stay'}',
      );
      return target;
    },
    routes: [
      GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashPage()),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (c, s) => iosSlidePage(key: s.pageKey, child: const OnboardingPage()),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (c, s) => iosSlidePage(key: s.pageKey, child: const LoginPage()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (c, s) => iosSlidePage(
          key: s.pageKey,
          child: BlocProvider(
            create: (_) => sl<ResetPasswordCubit>(),
            child: const ForgotPasswordPage(),
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.resetPasswordSent,
        pageBuilder: (c, s) => iosSlidePage(
          key: s.pageKey,
          child: ResetPasswordSentPage(
            email: s.extra is String ? s.extra as String : '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.accessDenied,
        pageBuilder: (c, s) => iosSlidePage(key: s.pageKey, child: const AccessDeniedPage()),
      ),
      ShellRoute(
        builder: (context, state, child) => FinancialShellPage(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (c, s) => iosSlidePage(key: s.pageKey, child: const DashboardPage()),
          ),
          GoRoute(
            path: AppRoutes.pnl,
            pageBuilder: (c, s) => iosSlidePage(key: s.pageKey, child: const PnlPage()),
          ),
          GoRoute(
            path: AppRoutes.comparison,
            pageBuilder: (c, s) => iosSlidePage(key: s.pageKey, child: const ComparisonPage()),
          ),
          GoRoute(
            path: AppRoutes.reports,
            pageBuilder: (c, s) => iosSlidePage(key: s.pageKey, child: const ReportsPage()),
          ),
          GoRoute(
            path: AppRoutes.growth,
            pageBuilder: (c, s) => iosSlidePage(key: s.pageKey, child: const GrowthPage()),
          ),
          GoRoute(
            path: AppRoutes.branches,
            pageBuilder: (c, s) => iosSlidePage(key: s.pageKey, child: const BranchesPage()),
          ),
          GoRoute(
            path: AppRoutes.distributions,
            pageBuilder: (c, s) =>
                iosSlidePage(key: s.pageKey, child: const DistributionsPage()),
          ),
          GoRoute(
            path: AppRoutes.capital,
            pageBuilder: (c, s) => iosSlidePage(key: s.pageKey, child: const CapitalPage()),
          ),
        ],
      ),
    ],
  );
}

class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(this._cubit) {
    _cubit.stream.listen((_) => notifyListeners());
  }
  final AuthCubit _cubit;
}

bool onboardingDone() => sl<OnboardingRepository>().isCompleted();
