import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
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

  final _log = Logger();

  late final AnimationController _controller;
  late final Animation<double> _phase1Fade;
  late final Animation<double> _phase2ShiftUp;
  late final Animation<double> _phase3Expand;

  Timer? _failsafeTimer;
  bool _navigated = false;
  bool _animationComplete = false;
  bool _bootComplete = false;

  @override
  void initState() {
    super.initState();

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
        _animationComplete = true;
        _tryNavigate();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_boot());
    });

    _failsafeTimer = Timer(_splashHold, () {
      if (!mounted || _navigated) return;
      _navigateFromAuth(force: true);
    });
  }

  Future<void> _boot() async {
    try {
      final auth = context.read<AuthCubit>();
      await auth.checkSession().timeout(_bootTimeout);
    } catch (e, st) {
      _log.w('Splash session check skipped', error: e, stackTrace: st);
    }
    if (!mounted) return;
    _bootComplete = true;
    _tryNavigate();
  }

  void _tryNavigate() {
    if (_navigated || !_bootComplete || !_animationComplete) return;
    _navigateFromAuth();
  }

  Future<void> _navigateFromAuth({bool force = false}) async {
    if (_navigated && !force) return;
    if (!mounted) return;

    final state = context.read<AuthCubit>().state;

    if (!onboardingDone()) {
      _navigated = true;
      context.go(AppRoutes.onboarding);
      return;
    }
    if (state is AuthUnauthenticated || (force && state is AuthLoading)) {
      _navigated = true;
      context.go(AppRoutes.login);
      return;
    }
    if (state is AuthAccessDenied) {
      _navigated = true;
      context.go(AppRoutes.accessDenied);
      return;
    }
    if (state is AuthAuthenticated) {
      try {
        final period = await sl<FinancialRepository>()
            .getPeriodInfo()
            .timeout(_bootTimeout);
        if (!mounted) return;
        period.fold((_) {}, (data) {
          context.read<FilterCubit>().applyPeriodCap(data);
        });
      } catch (e, st) {
        _log.w('Period info skipped', error: e, stackTrace: st);
      }
      if (!mounted) return;
      _navigated = true;
      context.go(AppRoutes.dashboard);
      return;
    }
    if (state is AuthError || force) {
      _navigated = true;
      context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _failsafeTimer?.cancel();
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
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Center(
                          child: const PoweredByCodeSolution(compact: true),
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
