import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../l10n/app_localizations.dart';
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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: BlocConsumer<AuthCubit, AuthState>(
                  listener: (context, state) {
                    if (state is AuthError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message)),
                      );
                    }
                  },
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    return LiquidGlassModal(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(
                            CupertinoIcons.lock_fill,
                            size: 48,
                            color: AppColors.primaryMid,
                          ),
                          const SizedBox(height: AppDimensions.spaceMd),
                          Text(
                            l10n.loginTitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.headlineMd,
                          ),
                          Text(
                            l10n.loginSubtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMd,
                          ),
                          const SizedBox(height: AppDimensions.spaceLg),
                          TextField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(labelText: l10n.loginEmail),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _password,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              labelText: l10n.loginPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? CupertinoIcons.eye_slash
                                      : CupertinoIcons.eye,
                                ),
                                onPressed: () => setState(() => _obscure = !_obscure),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spaceLg),
                          FilledButton(
                            onPressed: loading
                                ? null
                                : () => context.read<AuthCubit>().login(
                                      _email.text,
                                      _password.text,
                                    ),
                            child: loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CupertinoActivityIndicator(color: Colors.white),
                                  )
                                : Text(l10n.loginButton),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
