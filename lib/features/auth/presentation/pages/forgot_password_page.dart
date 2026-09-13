import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/powered_by_code_solution.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/reset_password_cubit.dart';
import '../widgets/sending_email_overlay.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<ResetPasswordCubit>().submit(_email.text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
        listenWhen: (prev, curr) =>
            curr is ResetPasswordError || curr is ResetPasswordSuccess,
        listener: (context, state) {
          if (state is ResetPasswordError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is ResetPasswordSuccess) {
            context.go(
              AppRoutes.resetPasswordSent,
              extra: state.email,
            );
          }
        },
        builder: (context, state) {
          final loading = state is ResetPasswordLoading;
          return PopScope(
            canPop: !loading,
            child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: IconButton(
                        onPressed: loading ? null : () => context.pop(),
                        icon: const Icon(CupertinoIcons.back),
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Center(
                                  child: Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.primaryGradient,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.lock_rotation,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  l10n.forgotPasswordTitle,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.headlineLg
                                      .copyWith(fontSize: 26),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  l10n.forgotPasswordSubtitle,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodyMd
                                      .copyWith(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 32),
                                Text(
                                  l10n.loginEmail,
                                  style: AppTextStyles.labelLg
                                      .copyWith(color: AppColors.textSecondary),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: _email,
                                  enabled: !loading,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  autocorrect: false,
                                  onSubmitted: (_) => loading ? null : _submit(),
                                  decoration: InputDecoration(
                                    hintText: l10n.forgotPasswordHint,
                                  ),
                                ),
                                const SizedBox(height: 28),
                                FilledButton(
                                  onPressed: loading ? null : _submit,
                                  child: Text(l10n.forgotPasswordButton),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
              if (loading) const SendingEmailOverlay(),
            ],
          ),
        );
        },
      ),
    );
  }
}
