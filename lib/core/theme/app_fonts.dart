import 'package:flutter/material.dart';

/// Bundled and remote font families used by [AppTheme].
abstract final class AppFonts {
  AppFonts._();

  /// Tajawal — bundled under `assets/fonts/Tajawal/` (Arabic UI).
  static const String tajawal = 'Tajawal';

  /// DM Sans via Google Fonts (English UI).
  static const String dmSans = 'DM Sans';

  static bool isArabic(Locale locale) => locale.languageCode == 'ar';
}
