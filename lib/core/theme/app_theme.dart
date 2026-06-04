import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_fonts.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData forLocale(Locale locale) => light(locale);

  static TextTheme _englishTextTheme(TextTheme base) {
    return GoogleFonts.dmSansTextTheme(base).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
  }

  static TextTheme _arabicTextTheme(TextTheme base) {
    TextStyle withTajawal(TextStyle? s) {
      if (s == null) return const TextStyle(fontFamily: AppFonts.tajawal);
      return s.copyWith(
        fontFamily: AppFonts.tajawal,
        letterSpacing: 0,
      );
    }

    return TextTheme(
      displayLarge: withTajawal(base.displayLarge),
      displayMedium: withTajawal(base.displayMedium),
      displaySmall: withTajawal(base.displaySmall),
      headlineLarge: withTajawal(base.headlineLarge),
      headlineMedium: withTajawal(base.headlineMedium),
      headlineSmall: withTajawal(base.headlineSmall),
      titleLarge: withTajawal(base.titleLarge),
      titleMedium: withTajawal(base.titleMedium),
      titleSmall: withTajawal(base.titleSmall),
      bodyLarge: withTajawal(base.bodyLarge),
      bodyMedium: withTajawal(base.bodyMedium),
      bodySmall: withTajawal(base.bodySmall),
      labelLarge: withTajawal(base.labelLarge),
      labelMedium: withTajawal(base.labelMedium),
      labelSmall: withTajawal(base.labelSmall),
    ).apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );
  }

  static TextStyle _buttonText(Locale locale) {
    if (AppFonts.isArabic(locale)) {
      return const TextStyle(
        fontFamily: AppFonts.tajawal,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
    }
    return GoogleFonts.dmSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
  }

  static TextStyle _titleText(Locale locale) {
    if (AppFonts.isArabic(locale)) {
      return const TextStyle(
        fontFamily: AppFonts.tajawal,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );
    }
    return GoogleFonts.dmSans(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle _navLabel(Locale locale, {required bool selected}) {
    if (AppFonts.isArabic(locale)) {
      return TextStyle(
        fontFamily: AppFonts.tajawal,
        fontSize: 12,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        color: selected ? AppColors.primaryMid : AppColors.textMuted,
      );
    }
    return GoogleFonts.dmSans(
      fontSize: 12,
      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
      color: selected ? AppColors.primaryMid : AppColors.textMuted,
    );
  }

  static TextStyle _snackText(Locale locale) {
    if (AppFonts.isArabic(locale)) {
      return const TextStyle(
        fontFamily: AppFonts.tajawal,
        fontSize: 14,
        color: Colors.white,
      );
    }
    return GoogleFonts.dmSans(fontSize: 14, color: Colors.white);
  }

  static ThemeData light(Locale locale) {
    final isAr = AppFonts.isArabic(locale);
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryMid,
        brightness: Brightness.light,
        primary: AppColors.primaryMid,
        secondary: AppColors.accentGreen,
        surface: AppColors.bgSecondary,
      ),
    );

    final textTheme =
        isAr ? _arabicTextTheme(base.textTheme) : _englishTextTheme(base.textTheme);

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgSecondary,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: _titleText(locale),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        toolbarHeight: 52,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgSecondary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryMid, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(
          fontFamily: isAr ? AppFonts.tajawal : null,
        ),
        labelStyle: AppTextStyles.labelLg.copyWith(
          color: AppColors.textSecondary,
          fontFamily: isAr ? AppFonts.tajawal : null,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryMid,
          foregroundColor: Colors.white,
          textStyle: _buttonText(locale),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgSecondary,
        indicatorColor: AppColors.primaryPale,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return _navLabel(locale, selected: selected);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primaryMid, size: 24);
          }
          return const IconThemeData(color: AppColors.textMuted, size: 24);
        }),
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        height: AppDimensions.bottomNavHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgTertiary,
        selectedColor: AppColors.primaryPale,
        labelStyle: AppTextStyles.bodySm.copyWith(
          fontFamily: isAr ? AppFonts.tajawal : null,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bgSecondary,
        modalBackgroundColor: AppColors.bgSecondary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary.withValues(alpha: 0.92),
        contentTextStyle: _snackText(locale),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primaryPale,
        iconColor: AppColors.primaryMid,
        textColor: AppColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: AppColors.primaryMid,
        scaffoldBackgroundColor: AppColors.bgPrimary,
        barBackgroundColor: AppColors.bgSecondary,
      ),
    );
  }
}
