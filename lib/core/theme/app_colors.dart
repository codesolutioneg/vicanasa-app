import 'package:flutter/material.dart';

/// Partner Financial Portal — slate canvas + blue primary (web mockup).
abstract final class AppColors {
  AppColors._();

  // Primary blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryMid = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryPale = Color(0xFFEFF6FF);

  // Semantic accents
  static const Color accentGreen = Color(0xFF10B981);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color accentOrange = Color(0xFFF59E0B);
  static const Color accentRed = Color(0xFFEF4444);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF06B6D4);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Backgrounds
  static const Color bgPrimary = Color(0xFFF8FAFC);
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgTertiary = Color(0xFFF1F5F9);

  // Surfaces
  static const Color cardBorder = Color(0xFFF3F4F6);
  static const Color glassFill = Color(0xFFFFFFFF);
  static const Color glassBorder = Color(0xFFE5E7EB);
  static const Color glassShimmer = Color(0x00000000);
  static const Color glassOverlay = Color(0x00000000);

  // Borders
  static const Color border = Color(0xFFD1D5DB);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Shimmer — white base + light blue sweep
  static const Color shimmerBase = Color(0xFFFFFFFF);
  static const Color shimmerHighlight = Color(0xFFBFDBFE);
  /// Inner placeholder blocks on white cards
  static const Color shimmerFill = Color(0xFFEFF6FF);

  // Dashboard KPI semantic
  static const Color kpiRevenue = Color(0xFF2563EB);
  static const Color kpiCost = Color(0xFFF59E0B);
  static const Color kpiExpense = Color(0xFFEF4444);
  static const Color kpiProfit = Color(0xFF10B981);
  static const Color kpiShare = Color(0xFF8B5CF6);
  static const Color kpiCapital = Color(0xFF06B6D4);
  static const Color kpiDistrib = Color(0xFFEC4899);

  // Warning
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningBorder = Color(0xFFF59E0B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
  );

  /// Splash animation — light blue canvas, white circle + expand
  static const Color splashSurface = Color(0xFFEFF6FF);
  static const Color splashCircleFill = bgSecondary;
  static const Color splashExpandFill = bgSecondary;

  static const LinearGradient splashBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8FAFC)],
  );

  static const LinearGradient capitalGradient = LinearGradient(
    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
  );

  static const LinearGradient distribGradient = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
  );
}
