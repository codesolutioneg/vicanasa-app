import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/powered_by_code_solution.dart';
import '../../../../l10n/app_localizations.dart';

class ResetPasswordSentPage extends StatelessWidget {
  const ResetPasswordSentPage({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                              color: AppColors.accentGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              CupertinoIcons.envelope_badge,
                              color: AppColors.accentGreen,
                              size: 30,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.resetPasswordSentTitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineLg.copyWith(fontSize: 26),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.resetPasswordSentMessage(email),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.resetPasswordSentHint,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySm
                              .copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 32),
                        FilledButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: Text(l10n.resetPasswordBackToLogin),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Center(child: PoweredByCodeSolution(compact: true)),
            ),
          ],
        ),
      ),
    );
  }
}
