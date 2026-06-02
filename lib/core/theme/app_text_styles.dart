import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLg = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.37,
  );

  static const TextStyle headlineLg = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.36,
  );

  static const TextStyle headlineMd = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.35,
  );

  static const TextStyle headlineSm = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.41,
  );

  static const TextStyle bodyLg = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    letterSpacing: -0.41,
  );

  static const TextStyle bodyMd = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: -0.24,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: -0.08,
  );

  static const TextStyle labelLg = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    letterSpacing: 0,
  );

  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textTertiary,
  );

  static const TextStyle kpiValue = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.36,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static const TextStyle kpiLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    letterSpacing: 0.5,
  );

  static const TextStyle financial = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
