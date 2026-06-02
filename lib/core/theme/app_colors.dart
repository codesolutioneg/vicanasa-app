import 'package:flutter/material.dart';

/// Design tokens — iOS liquid glass teal palette.
abstract final class AppColors {
  AppColors._();

  // Primary teal
  static const Color primaryDark = Color(0xFF006B6B);
  static const Color primaryMid = Color(0xFF009999);
  static const Color primaryLight = Color(0xFF00C2C2);
  static const Color primaryPale = Color(0xFFE0F7F7);

  // Semantic accents (iOS system colors)
  static const Color accentGreen = Color(0xFF34C759);
  static const Color accentBlue = Color(0xFF007AFF);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentRed = Color(0xFFFF3B30);
  static const Color accentPurple = Color(0xFFAF52DE);

  // Text
  static const Color textPrimary = Color(0xFF1C1C1E);
  static const Color textSecondary = Color(0xFF3C3C43);
  static const Color textTertiary = Color(0xFF48484A);
  static const Color textMuted = Color(0xFF8E8E93);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // Backgrounds — cool gray canvas so white glass cards read clearly
  static const Color bgPrimary = Color(0xFFE8ECF1);
  static const Color bgSecondary = Color(0xFFFFFFFF);
  static const Color bgTertiary = Color(0xFFD8DEE6);

  // Glass / frosted
  static const Color glassFill = Color(0xD9FFFFFF);
  static const Color glassBorder = Color(0x66FFFFFF);
  static const Color glassShimmer = Color(0x1AFFFFFF);
  static const Color glassOverlay = Color(0x0D009999);

  // Borders
  static const Color border = Color(0xFFC6C6C8);
  static const Color borderLight = Color(0xFFE5E5EA);

  // Dashboard KPI semantic
  static const Color kpiRevenue = Color(0xFF34C759);
  static const Color kpiCost = Color(0xFFFF9500);
  static const Color kpiExpense = Color(0xFFFF3B30);
  static const Color kpiProfit = Color(0xFF007AFF);
  static const Color kpiCapital = Color(0xFF5856D6);
  static const Color kpiDistrib = Color(0xFFFF2D55);

  // Warning
  static const Color warningBg = Color(0xFFFFF9C4);
  static const Color warningBorder = Color(0xFFFFCC00);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryLight],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF004F4F), Color(0xFF007A7A), Color(0xFF00AAAA)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xCCFFFFFF), Color(0x88FFFFFF)],
  );

  static const LinearGradient capitalGradient = LinearGradient(
    colors: [Color(0xFF5856D6), Color(0xFF7B79E8)],
  );

  static const LinearGradient distribGradient = LinearGradient(
    colors: [Color(0xFFFF2D55), Color(0xFFFF6B8A)],
  );
}
