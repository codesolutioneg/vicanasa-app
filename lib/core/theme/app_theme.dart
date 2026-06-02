import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryMid,
        brightness: Brightness.light,
        primary: AppColors.primaryMid,
        secondary: AppColors.accentBlue,
        surface: AppColors.bgSecondary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgPrimary.withValues(alpha: 0.85),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.headlineSm,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
        toolbarHeight: 52,
      ),
      cardTheme: CardThemeData(
        color: AppColors.bgSecondary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd,
          vertical: AppDimensions.spaceSm + 4,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.borderLight, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          borderSide: const BorderSide(color: AppColors.primaryMid, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMd,
        labelStyle: AppTextStyles.labelLg,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryMid,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.headlineSm.copyWith(color: Colors.white),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceLg,
            vertical: AppDimensions.spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          elevation: 0,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.bgSecondary.withValues(alpha: 0.85),
        indicatorColor: AppColors.primaryPale,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTextStyles.caption.copyWith(
              color: AppColors.primaryMid,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTextStyles.caption.copyWith(color: AppColors.textMuted);
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
        thickness: 0.5,
        space: 0,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgTertiary,
        selectedColor: AppColors.primaryPale,
        labelStyle: AppTextStyles.bodySm,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXxl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary.withValues(alpha: 0.92),
        contentTextStyle: AppTextStyles.bodyMd.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: AppColors.primaryPale,
        iconColor: AppColors.primaryMid,
        textColor: AppColors.textPrimary,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.spaceMd,
          vertical: AppDimensions.spaceXs,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusSm)),
        ),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: AppColors.primaryMid,
        scaffoldBackgroundColor: AppColors.bgPrimary,
        barBackgroundColor: AppColors.bgSecondary,
        textTheme: CupertinoTextThemeData(
          primaryColor: AppColors.primaryMid,
        ),
      ),
    );
  }
}
