import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/shimmer/shimmer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/powered_by_code_solution.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';
import '../cubit/auth_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  static const _logoAsset = 'assets/images/vicanza_logo.png';

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            children: [
              Expanded(
                child: wide ? _buildSplitLayout() : _buildStackedLayout(),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Center(
                  child: PoweredByCodeSolution(compact: true),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitLayout() {
    return Row(
      children: [
        Expanded(child: _buildLoginPanel(compact: false)),
        const VerticalDivider(width: 1, color: AppColors.borderLight),
        const Expanded(child: _LogoPanel()),
      ],
    );
  }

  Widget _buildStackedLayout() {
    final l10n = AppLocalizations.of(context)!;
    return ColoredBox(
      color: AppColors.bgPrimary,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: BlocConsumer<AuthCubit, AuthState>(
              listenWhen: (prev, curr) =>
                  curr is AuthError ||
                  curr is AuthAuthenticated ||
                  curr is AuthAccessDenied,
              listener: (context, state) async {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                  return;
                }
                if (state is AuthAccessDenied) {
                  context.go(AppRoutes.accessDenied);
                  return;
                }
                if (state is AuthAuthenticated) {
                  final period =
                      await sl<FinancialRepository>().getPeriodInfo();
                  if (!context.mounted) return;
                  period.fold((_) {}, (data) {
                    context.read<FilterCubit>().applyPeriodCap(data);
                  });
                  if (!context.mounted) return;
                  context.go(AppRoutes.dashboard);
                }
              },
              builder: (context, state) {
                final loading = state is AuthLoading;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Blue gradient icon box
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          CupertinoIcons.chart_bar_alt_fill,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l10n.loginTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineLg.copyWith(fontSize: 26),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.loginSubtitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMd
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 32),
                    Text(l10n.loginEmail,
                        style: AppTextStyles.labelLg
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          hintText: 'Enter your email'),
                    ),
                    const SizedBox(height: 16),
                    Text(l10n.loginPassword,
                        style: AppTextStyles.labelLg
                            .copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: loading
                          ? null
                          : () {
                              final email = _email.text.trim();
                              final password = _password.text;
                              if (email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.loginError)),
                                );
                                return;
                              }
                              context
                                  .read<AuthCubit>()
                                  .login(email, password);
                            },
                      child: loading
                          ? CustomShimmer(
                              baseColor: Colors.white.withValues(alpha: 0.25),
                              highlightColor: Colors.white.withValues(alpha: 0.45),
                              child: Container(
                                height: 16,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            )
                          : Text(l10n.loginButton),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPanel({required bool compact}) {
    final l10n = AppLocalizations.of(context)!;

    return ColoredBox(
      color: AppColors.bgSecondary,
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 24 : 48,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: BlocConsumer<AuthCubit, AuthState>(
              listenWhen: (prev, curr) =>
                  curr is AuthError ||
                  curr is AuthAuthenticated ||
                  curr is AuthAccessDenied,
              listener: (context, state) async {
                if (state is AuthError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                  return;
                }
                if (state is AuthAccessDenied) {
                  context.go(AppRoutes.accessDenied);
                  return;
                }
                if (state is AuthAuthenticated) {
                  final period = await sl<FinancialRepository>().getPeriodInfo();
                  if (!context.mounted) return;
                  period.fold((_) {}, (data) {
                    context.read<FilterCubit>().applyPeriodCap(data);
                  });
                  if (!context.mounted) return;
                  context.go(AppRoutes.dashboard);
                }
              },
              builder: (context, state) {
                final loading = state is AuthLoading;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!compact) ...[
                      const Center(child: _BrandLogo.form()),
                      const SizedBox(height: 28),
                    ],
                    Text(
                      l10n.loginTitle,
                      style: AppTextStyles.headlineLg.copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.loginSubtitle, style: AppTextStyles.bodyMd),
                    const SizedBox(height: 32),
                    Text(
                      l10n.loginEmail,
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'Enter your email',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.loginPassword,
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? CupertinoIcons.eye_slash
                                : CupertinoIcons.eye,
                            color: AppColors.textMuted,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FilledButton(
                      onPressed: loading
                          ? null
                          : () {
                              final email = _email.text.trim();
                              final password = _password.text;
                              if (email.isEmpty || password.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(l10n.loginError)),
                                );
                                return;
                              }
                              context.read<AuthCubit>().login(email, password);
                            },
                      child: loading
                          ? CustomShimmer(
                              baseColor: Colors.white.withValues(alpha: 0.25),
                              highlightColor: Colors.white.withValues(alpha: 0.45),
                              child: Container(
                                height: 16,
                                width: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            )
                          : Text(l10n.loginButton),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// PNG has large top whitespace — crop to the wordmark via [Align.heightFactor].
class _BrandLogo extends StatelessWidget {
  const _BrandLogo.form()
      : maxWidth = 260,
        viewportHeight = 72,
        visibleFraction = 0.36;

  const _BrandLogo.hero({required this.maxWidth})
      : viewportHeight = 120,
        visibleFraction = 0.36;

  const _BrandLogo.compact()
      : maxWidth = 300,
        viewportHeight = 88,
        visibleFraction = 0.36;

  final double maxWidth;
  final double viewportHeight;
  final double visibleFraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: maxWidth,
      height: viewportHeight,
      child: ClipRect(
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: visibleFraction,
          child: Image.asset(
            _LoginPageState._logoAsset,
            width: maxWidth,
            fit: BoxFit.fitWidth,
            alignment: Alignment.bottomCenter,
            semanticLabel: 'Vicanza',
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) => Text(
              'VICANZA',
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineLg.copyWith(
                fontSize: viewportHeight * 0.55,
                letterSpacing: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoPanel extends StatelessWidget {
  const _LogoPanel({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.bgPrimary,
      child: SizedBox.expand(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (compact) {
                  return const _BrandLogo.compact();
                }
                final w = (constraints.maxWidth * 0.82).clamp(320.0, 520.0);
                return _BrandLogo.hero(maxWidth: w);
              },
            ),
          ),
        ),
      ),
    );
  }
}
