import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/auth_cubit.dart';

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SizedBox.expand(
        child: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppColors.splashGradient),
          child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.spaceXl),
            child: LiquidGlassModal(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.hand_raised_fill,
                    size: 64,
                    color: AppColors.accentRed,
                  ),
                  const SizedBox(height: AppDimensions.spaceMd),
                  Text(l10n.accessDeniedTitle, style: AppTextStyles.headlineMd),
                  const SizedBox(height: AppDimensions.spaceSm),
                  Text(
                    l10n.accessDeniedMessage,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMd,
                  ),
                  const SizedBox(height: AppDimensions.spaceLg),
                  FilledButton(
                    onPressed: () => context.read<AuthCubit>().logout(),
                    child: Text(l10n.logout),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
      ),
    );
  }
}
