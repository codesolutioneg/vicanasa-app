import 'dart:ui';

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';

/// Clean white surface card (Partner Financial Portal style).
class LiquidGlassCard extends StatelessWidget {
  const LiquidGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.blurSigma = 0,
    this.tintColor,
    this.addTealShimmer = false,
    this.width,
    this.height,
    this.onTap,
    this.elevated = true,
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
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? 12;

    Widget surface = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppDimensions.spaceMd),
        child: child,
      ),
    );

    if (blurSigma > 0) {
      surface = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: surface,
        ),
      );
    }

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: surface,
        ),
      );
    }
    return surface;
  }
}

/// Rounded sheet container for modals.
class LiquidGlassModal extends StatelessWidget {
  const LiquidGlassModal({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LiquidGlassCard(
      borderRadius: AppDimensions.radiusXxl,
      padding: padding ?? const EdgeInsets.all(AppDimensions.spaceLg),
      elevated: true,
      child: child,
    );
  }
}
