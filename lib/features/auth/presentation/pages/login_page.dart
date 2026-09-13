import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/powered_by_code_solution.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../financial/domain/repositories/financial_repository.dart';
import '../../../shell/presentation/cubit/filter_cubit.dart';
import '../cubit/auth_cubit.dart';
import '../widgets/waiting_clock_overlay.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _signingIn = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 720;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgSecondary,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: BlocConsumer<AuthCubit, AuthState>(
            listenWhen: (prev, curr) =>
                curr is AuthError ||
                curr is AuthAuthenticated ||
                curr is AuthAccessDenied ||
                curr is AuthUnauthenticated,
            listener: _onAuthState,
            builder: (context, state) {
              final loading = _signingIn;
              return PopScope(
                canPop: !loading,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: wide
                              ? _buildSplitLayout(loading: loading)
                              : _buildStackedLayout(loading: loading),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
                          child: Center(
                            child: PoweredByCodeSolution(compact: true),
                          ),
                        ),
                      ],
                    ),
                    if (loading)
                      WaitingClockOverlay(
                        title: l10n.signingInTitle,
                        subtitle: l10n.signingInSubtitle,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _onAuthState(BuildContext context, AuthState state) async {
    if (_signingIn &&
        (state is AuthError ||
            state is AuthAuthenticated ||
            state is AuthAccessDenied ||
            state is AuthUnauthenticated)) {
      if (mounted) setState(() => _signingIn = false);
    }
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
  }

  Widget _buildSplitLayout({required bool loading}) {
    return Row(
      children: [
        Expanded(child: _buildLoginPanel(compact: false, loading: loading)),
        const VerticalDivider(width: 1, color: AppColors.borderLight),
        const Expanded(child: _LogoPanel()),
      ],
    );
  }

  Widget _buildStackedLayout({required bool loading}) {
    final l10n = AppLocalizations.of(context)!;
    return ColoredBox(
      color: AppColors.bgSecondary,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(child: _BrandLogo()),
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
                  enabled: !loading,
                  keyboardType: TextInputType.emailAddress,
                  decoration:
                      const InputDecoration(hintText: 'Enter your email'),
                ),
                const SizedBox(height: 16),
                Text(l10n.loginPassword,
                    style: AppTextStyles.labelLg
                        .copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _password,
                  enabled: !loading,
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
                      onPressed: loading
                          ? null
                          : () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: loading
                        ? null
                        : () => context.push(AppRoutes.forgotPassword),
                    child: Text(l10n.forgotPassword),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: loading ? null : _submitLogin,
                  child: Text(l10n.loginButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginPanel({required bool compact, required bool loading}) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!compact) ...[
                  const Center(child: _BrandLogo()),
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
                  enabled: !loading,
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
                  enabled: !loading,
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
                      onPressed: loading
                          ? null
                          : () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: loading
                        ? null
                        : () => context.push(AppRoutes.forgotPassword),
                    child: Text(l10n.forgotPassword),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: loading ? null : _submitLogin,
                  child: Text(l10n.loginButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitLogin() {
    final l10n = AppLocalizations.of(context)!;
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.loginError)),
      );
      return;
    }
    setState(() => _signingIn = true);
    context.read<AuthCubit>().login(email, password);
  }
}

/// Centered Vicanza mark — same asset as splash, no crop (crop shifted it right).
class _BrandLogo extends StatelessWidget {
  const _BrandLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.appIcon,
      height: 96,
      fit: BoxFit.contain,
      alignment: Alignment.center,
      semanticLabel: 'Vicanza',
      filterQuality: FilterQuality.high,
    );
  }
}

class _LogoPanel extends StatelessWidget {
  const _LogoPanel();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.bgSecondary,
      child: SizedBox.expand(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: _BrandLogo(),
          ),
        ),
      ),
    );
  }
}
