import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final auth = context.read<AuthCubit>();
    await auth.checkSession();
    if (!mounted) return;

    final state = auth.state;

    if (!onboardingDone()) {
      context.go(AppRoutes.onboarding);
      return;
    }
    if (state is AuthUnauthenticated) {
      context.go(AppRoutes.login);
      return;
    }
    if (state is AuthAccessDenied) {
      context.go(AppRoutes.accessDenied);
      return;
    }
    if (state is AuthAuthenticated) {
      final period = await sl<FinancialRepository>().getPeriodInfo();
      if (!mounted) return;
      period.fold((_) {}, (data) {
        context.read<FilterCubit>().applyPeriodCap(data);
      });
      if (!mounted) return;
      context.go(AppRoutes.dashboard);
      return;
    }
    if (state is AuthError) {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Large transparent "V" on the right — decorative background element
          Positioned(
            right: -size.width * 0.18,
            top: 0,
            bottom: 0,
            child: Center(
              child: Text(
                'V',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: size.width * 1.05,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryMid.withValues(alpha: 0.045),
                  height: 1,
                  letterSpacing: -8,
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 3),
                Center(
                  child: Image.asset(
                    AppAssets.splashLogo,
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                ),
                const Spacer(flex: 3),
                const Center(
                  child: CupertinoActivityIndicator(
                    color: AppColors.primaryMid,
                    radius: 12,
                  ),
                ),
                const SizedBox(height: AppDimensions.spaceLg + AppDimensions.spaceMd),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
