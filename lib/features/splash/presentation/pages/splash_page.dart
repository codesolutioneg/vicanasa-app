import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/env.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/review/mobile_versions_service.dart';
import '../../../../core/review/review_mode_cubit.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/powered_by_code_solution.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

/// Vicansa splash — blue background, white circle, single app icon.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  static const Duration _splashHold = Duration(milliseconds: 1500);
  static const Duration _bootTimeout = Duration(seconds: 8);
  static const Duration _animationDuration = Duration(milliseconds: 1500);
  static const Duration _versionsTimeout = Duration(seconds: 10);

  final _log = Logger();

  late final AnimationController _controller;
  late final Animation<double> _phase1Fade;
  late final Animation<double> _phase2ShiftUp;
  late final Animation<double> _phase3Expand;

  Timer? _failsafeTimer;
  Timer? _absoluteFailsafe;
  bool _navigated = false;
  bool _animationComplete = false;
  bool _bootComplete = false;

  @override
  void initState() {
    super.initState();
    _log.i('App flow: splash initState (hash=$hashCode)');

    _controller = AnimationController(
      vsync: this,
      duration: _animationDuration,
    )..forward();

    _phase1Fade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.30, curve: Curves.easeIn),
      ),
    );

    _phase2ShiftUp = Tween<double>(begin: 0, end: -55).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.30, 0.60, curve: Curves.easeInOut),
      ),
    );

    _phase3Expand = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _log.i('App flow: splash animation COMPLETE');
        _animationComplete = true;
        _tryNavigate();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_boot());
    });

    _failsafeTimer = Timer(_splashHold, () {
      if (!mounted || _navigated || !_bootComplete) return;
      _log.w('App flow: splash short failsafe → navigate force');
      _navigateFromAuth(force: true);
    });
    _absoluteFailsafe = Timer(const Duration(seconds: 15), () {
      if (!mounted || _navigated) return;
      _log.w('App flow: splash ABSOLUTE failsafe 15s → navigate force');
      _bootComplete = true;
      _animationComplete = true;
      _navigateFromAuth(force: true);
    });
  }

  Future<void> _boot() async {
    _log.i('App flow: splash boot START');
    try {
      _log.i('App flow: splash → versions API');
      final reviewMode = await sl<MobileVersionsService>()
          .isCurrentVersionPublished()
          .timeout(_versionsTimeout, onTimeout: () {
        _log.w('App flow: splash versions TIMEOUT → reviewMode=false');
        return false;
      });

      if (!mounted) {
        _log.w('App flow: splash unmounted after versions');
        return;
      }

      _log.i('App flow: splash reviewMode=$reviewMode');

      if (reviewMode) {
        _log.i('App flow: splash REVIEW PATH → enable + auto-login');
        context.read<ReviewModeCubit>().enable();
        _log.i(
          'App flow: splash auto-login email=${Env.reviewEmail}',
        );
        await context.read<AuthCubit>().login(
              Env.reviewEmail,
              Env.reviewPassword,
            );
        if (!mounted) {
          _log.w('App flow: splash unmounted after auto-login');
          return;
        }
        final authState = context.read<AuthCubit>().state;
        _log.i(
          'App flow: splash auto-login done authState=${authState.runtimeType}',
        );
        _bootComplete = true;
        _tryNavigate();
        return;
      }

      _log.i('App flow: splash NORMAL PATH → checkSession');
      context.read<ReviewModeCubit>().disable();
      final auth = context.read<AuthCubit>();
      await auth.checkSession().timeout(_bootTimeout);
      _log.i(
        'App flow: splash checkSession done authState=${auth.state.runtimeType}',
      );
    } catch (e, st) {
      _log.w('App flow: splash boot ERROR', error: e, stackTrace: st);
    }
    if (!mounted) return;
    _bootComplete = true;
    _log.i('App flow: splash boot COMPLETE');
    _tryNavigate();
  }

  void _tryNavigate() {
    _log.i(
      'App flow: splash tryNavigate navigated=$_navigated '
      'boot=$_bootComplete anim=$_animationComplete',
    );
    if (_navigated || !_bootComplete || !_animationComplete) return;
    _navigateFromAuth();
  }

  Future<void> _navigateFromAuth({bool force = false}) async {
    if (_navigated && !force) {
      _log.i('App flow: splash navigate SKIP already navigated');
      return;
    }
    if (!mounted) return;

    final state = context.read<AuthCubit>().state;
    final isReview = context.read<ReviewModeCubit>().isReviewMode;
    _log.i(
      'App flow: splash navigate START force=$force '
      'auth=${state.runtimeType} review=$isReview',
    );

    if (!isReview && !onboardingDone()) {
      _navigated = true;
      _log.i('App flow: splash → /onboarding');
      context.go(AppRoutes.onboarding);
      return;
    }
    if (state is AuthUnauthenticated || (force && state is AuthLoading)) {
      _navigated = true;
      _log.i('App flow: splash → /login (unauthenticated/force loading)');
      context.go(AppRoutes.login);
      return;
    }
    if (state is AuthAccessDenied) {
      _navigated = true;
      _log.i('App flow: splash → /access-denied');
      context.go(AppRoutes.accessDenied);
      return;
    }
    if (state is AuthAuthenticated) {
      try {
        _log.i('App flow: splash loading period info');
        final period = await sl<FinancialRepository>()
            .getPeriodInfo()
            .timeout(_bootTimeout);
        if (!mounted) return;
        period.fold(
          (f) => _log.w('App flow: splash period FAILED ${f.message}'),
          (data) {
            context.read<FilterCubit>().applyPeriodCap(data);
            _log.i('App flow: splash period applied');
          },
        );
      } catch (e, st) {
        _log.w('App flow: splash period skipped', error: e, stackTrace: st);
      }
      if (!mounted) return;
      _navigated = true;
      _log.i('App flow: splash → /dashboard (authenticated, review=$isReview)');
      context.go(AppRoutes.dashboard);
      return;
    }
    if (state is AuthError || force) {
      _navigated = true;
      final err = state is AuthError ? state.message : 'force=$force';
      _log.i('App flow: splash → /login ($err)');
      context.go(AppRoutes.login);
    } else {
      _log.i('App flow: splash navigate WAIT state=${state.runtimeType}');
    }
  }

  @override
  void dispose() {
    _log.i('App flow: splash dispose (hash=$hashCode)');
    _failsafeTimer?.cancel();
    _absoluteFailsafe?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double ellipseW = 300;
    const double ellipseH = 288;
    final size = MediaQuery.sizeOf(context);
    final centerY = size.height / 2 + 8;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        _log.i(
          'App flow: splash AuthCubit listener state=${state.runtimeType} '
          'boot=$_bootComplete anim=$_animationComplete navigated=$_navigated',
        );
        if (!mounted || _navigated) return;
        if (_bootComplete && _animationComplete) {
          _navigateFromAuth();
        }
      },
      child: Scaffold(
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: AppColors.splashBackgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      final shift = _phase2ShiftUp.value;
                      final maxRadius = sqrt(
                        size.width * size.width + size.height * size.height,
                      );
                      const baseRadius = ellipseW / 2;
                      final expandedRadius = baseRadius +
                          (maxRadius - baseRadius) * _phase3Expand.value;

                      return Stack(
                        children: [
                          if (_phase3Expand.value > 0)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _ExpandingCirclePainter(
                                  center:
                                      Offset(size.width / 2, centerY + shift),
                                  radius: expandedRadius,
                                  color: AppColors.splashExpandFill,
                                ),
                              ),
                            ),
                          Opacity(
                            opacity: _phase1Fade.value,
                            child: Transform.translate(
                              offset: Offset(0, shift),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: (size.width - ellipseW) / 2,
                                    top: centerY - ellipseH / 2,
                                    child: Container(
                                      width: ellipseW,
                                      height: ellipseH,
                                      decoration: const BoxDecoration(
                                        color: AppColors.splashCircleFill,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: centerY - ellipseH / 2,
                                    left: 0,
                                    right: 0,
                                    child: SizedBox(
                                      height: ellipseH,
                                      child: Center(
                                        child: Image.asset(
                                          AppAssets.appIcon,
                                          width: 150,
                                          height: 150,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _phase1Fade.value,
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Center(
                          child: PoweredByCodeSolution(compact: true),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandingCirclePainter extends CustomPainter {
  const _ExpandingCirclePainter({
    required this.center,
    required this.radius,
    required this.color,
  });

  final Offset center;
  final double radius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(center, radius, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _ExpandingCirclePainter old) {
    return old.radius != radius || old.center != center || old.color != color;
  }
}
