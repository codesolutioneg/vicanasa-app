import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import 'custom_shimmer.dart';

/// Reusable skeleton pieces sized like real Vicanza UI components.
abstract final class ShimmerLayouts {
  ShimmerLayouts._();

  static int kpiCrossCount(double width) {
    if (width >= 1200) return 6;
    if (width >= 900) return 3;
    return 2;
  }

  static double kpiAspectRatio(int crossCount) {
    if (crossCount >= 6) return 1.4;
    if (crossCount == 3) return 1.55;
    return 1.5;
  }

  /// Cell height matching [DashboardMainKpis] grid for a given content width.
  static double kpiCellHeight(double contentWidth, {int? crossCount}) {
    final cross = crossCount ?? kpiCrossCount(contentWidth);
    final spacing = AppDimensions.spaceSm * (cross - 1);
    final cellWidth = (contentWidth - spacing) / cross;
    return cellWidth / kpiAspectRatio(cross);
  }

  static Widget sectionTitle({double width = 140}) {
    return ShimmerBox(width: width, height: 18, borderRadius: 6);
  }

  /// Matches [DashboardHeroCard] — gradient card placeholder.
  static Widget heroCard() {
    return ShimmerBox(
      width: double.infinity,
      height: 168,
      borderRadius: AppDimensions.radiusLg,
    );
  }

  /// Matches [PortalKpiCard] — safe inside GridView, ListView, or fixed [height].
  static Widget kpiTile({double? height}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bounded = constraints.maxHeight.isFinite && constraints.maxHeight > 0;
        final cardHeight = height ?? (bounded ? constraints.maxHeight : 96.0);

        return CustomShimmer(
          child: Container(
            width: double.infinity,
            height: cardHeight,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.shimmerFill,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.shimmerFill,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerFill,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
                Container(
                  width: double.infinity,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerFill,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 72,
                  height: 10,
                  decoration: BoxDecoration(
                    color: AppColors.shimmerFill,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget kpiGrid(BuildContext context, {int count = 6}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cross = kpiCrossCount(constraints.maxWidth);
        final aspect = kpiAspectRatio(cross);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cross,
            mainAxisSpacing: AppDimensions.spaceSm,
            crossAxisSpacing: AppDimensions.spaceSm,
            childAspectRatio: aspect,
          ),
          itemCount: count,
          itemBuilder: (_, __) => kpiTile(),
        );
      },
    );
  }

  /// Single full-width KPI (e.g. distributions balance card).
  static Widget singleKpiCard(BuildContext context, {double? contentWidth}) {
    final w = contentWidth ??
        (MediaQuery.sizeOf(context).width - AppDimensions.spaceMd * 2);
    final h = kpiCellHeight(w, crossCount: 2);
    return SizedBox(height: h, child: kpiTile(height: h));
  }

  static Widget glassCard({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
  }) {
    return CustomShimmer(
      child: Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: child,
      ),
    );
  }

  static Widget chartBlock({double height = 200}) {
    final chartH = height > 48 ? height - 40 : 120.0;
    return glassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 100, height: 14, borderRadius: 4),
          const SizedBox(height: 16),
          ShimmerBox(width: double.infinity, height: chartH, borderRadius: 8),
        ],
      ),
    );
  }

  static Widget breakdownCard({int rows = 5}) {
    return glassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 10, height: 10, borderRadius: 5),
              const SizedBox(width: 12),
              ShimmerBox(width: 120, height: 14, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < rows; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            listMetricRow(),
          ],
        ],
      ),
    );
  }

  static Widget ratioCard({int items = 4}) {
    return glassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 90, height: 14, borderRadius: 4),
          const SizedBox(height: 12),
          for (var i = 0; i < items; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: ShimmerBox(height: 12, borderRadius: 4)),
                const SizedBox(width: 12),
                ShimmerBox(width: 48, height: 12, borderRadius: 4),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static Widget listMetricRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: 10, height: 10, borderRadius: 5),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: ShimmerBox(height: 12, borderRadius: 4)),
                  const SizedBox(width: 8),
                  ShimmerBox(width: 80, height: 12, borderRadius: 4),
                ],
              ),
              const SizedBox(height: 6),
              ShimmerBox(width: double.infinity, height: 5, borderRadius: 3),
            ],
          ),
        ),
      ],
    );
  }

  /// List row like branches / capital / grouped accounts.
  static Widget listCardRow({double height = 72}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceSm),
      child: CustomShimmer(
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 14,
                      width: 140,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerFill,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 10,
                      width: 90,
                      decoration: BoxDecoration(
                        color: AppColors.shimmerFill,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 14,
                width: 72,
                decoration: BoxDecoration(
                  color: AppColors.shimmerFill,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget filterBarCard() {
    return glassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 20, height: 20, borderRadius: 4),
              const SizedBox(width: 8),
              ShimmerBox(width: 80, height: 14, borderRadius: 4),
              const Spacer(),
              ShimmerBox(width: 56, height: 28, borderRadius: 8),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              4,
              (_) => ShimmerBox(width: 64, height: 32, borderRadius: 16),
            ),
          ),
        ],
      ),
    );
  }

  static Widget yearPickerCard() {
    return glassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ShimmerBox(width: 20, height: 20, borderRadius: 4),
          const SizedBox(width: 8),
          ShimmerBox(width: 48, height: 14, borderRadius: 4),
          const Spacer(),
          ShimmerBox(width: 72, height: 28, borderRadius: 8),
        ],
      ),
    );
  }

  static Widget accountSection({int rows = 5}) {
    return glassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 4, height: 20, borderRadius: 2),
              const SizedBox(width: 8),
              ShimmerBox(width: 130, height: 16, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rows; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            accountRow(),
          ],
        ],
      ),
    );
  }

  static Widget accountRow() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          ShimmerBox(width: 72, height: 12, borderRadius: 4),
          const SizedBox(width: 10),
          Expanded(child: ShimmerBox(height: 12, borderRadius: 4)),
          const SizedBox(width: 10),
          ShimmerBox(width: 64, height: 12, borderRadius: 4),
        ],
      ),
    );
  }

  static Widget comparisonYearCard() {
    return glassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 48, height: 18, borderRadius: 4),
          const SizedBox(height: 12),
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            listMetricRow(),
          ],
        ],
      ),
    );
  }

  static Widget reportsCard() {
    return glassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 48, height: 48, borderRadius: 12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120, height: 16, borderRadius: 4),
                    const SizedBox(height: 8),
                    ShimmerBox(width: double.infinity, height: 12, borderRadius: 4),
                    const SizedBox(height: 4),
                    ShimmerBox(width: 200, height: 12, borderRadius: 4),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const ShimmerButton(height: 48),
        ],
      ),
    );
  }

  /// Two KPI tiles side by side (growth page).
  static Widget kpiPairRow(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final half = (constraints.maxWidth - 12) / 2;
        final h = kpiCellHeight(constraints.maxWidth, crossCount: 2);
        return Row(
          children: [
            SizedBox(width: half, height: h, child: kpiTile(height: h)),
            const SizedBox(width: 12),
            SizedBox(width: half, height: h, child: kpiTile(height: h)),
          ],
        );
      },
    );
  }
}
