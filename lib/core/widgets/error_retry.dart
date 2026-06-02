import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/liquid_glass.dart';

class ErrorRetry extends StatelessWidget {
  const ErrorRetry({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spaceLg),
        child: LiquidGlassCard(
          addTealShimmer: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_circle_fill,
                size: 48,
                color: AppColors.accentRed.withValues(alpha: 0.85),
              ),
              const SizedBox(height: AppDimensions.spaceMd),
              Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyMd),
              const SizedBox(height: AppDimensions.spaceMd),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}
