import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

/// iOS frosted glass surface.
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurSigma = AppDimensions.blurRadius,
    this.tintColor,
    this.addTealShimmer = false,
    this.width,
    this.height,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double blurSigma;
  final Color? tintColor;
  final bool addTealShimmer;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppDimensions.radiusMd;

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            gradient: addTealShimmer
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.88),
                      (tintColor ?? AppColors.primaryLight).withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.75),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.88),
                      Colors.white.withValues(alpha: 0.72),
                    ],
                  ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: AppColors.glassBorder,
              width: AppDimensions.glassBorderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppColors.primaryMid.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppDimensions.spaceMd),
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}

/// Stronger blur for modals / bottom sheets.
class LiquidGlassModal extends StatelessWidget {
  const LiquidGlassModal({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      blurSigma: 40,
      borderRadius: AppDimensions.radiusXxl,
      padding: padding ?? const EdgeInsets.all(AppDimensions.spaceLg),
      child: child,
    );
  }
}
