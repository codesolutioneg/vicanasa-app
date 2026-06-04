import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../shimmer/shimmer.dart';
import '../theme/app_dimensions.dart';
import '../theme/app_text_styles.dart';
import '../theme/liquid_glass.dart';
import '../../l10n/app_localizations.dart';

/// Full-screen offline state shown when there is no network connection.
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({
    super.key,
    required this.onRetry,
    this.isRetrying = false,
  });

  final VoidCallback onRetry;
  final bool isRetrying;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Material(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceLg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: LiquidGlassModal(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.wifi_slash,
                        size: 72,
                        color: AppColors.accentOrange.withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: AppDimensions.spaceLg),
                      Text(
                        l10n.noInternetTitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineSm,
                      ),
                      const SizedBox(height: AppDimensions.spaceSm),
                      Text(
                        l10n.noInternetMessage,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMd,
                      ),
                      const SizedBox(height: AppDimensions.spaceXl),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: isRetrying ? null : onRetry,
                          icon: isRetrying
                              ? const SizedBox.shrink()
                              : const Icon(CupertinoIcons.arrow_clockwise),
                          label: isRetrying
                              ? CustomShimmer(
                                  baseColor: Colors.white.withValues(alpha: 0.25),
                                  highlightColor: Colors.white.withValues(alpha: 0.45),
                                  child: Container(
                                    height: 14,
                                    width: 64,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                )
                              : Text(l10n.retry),
                        ),
                      ),
                    ],
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
