import 'package:flutter/material.dart';

import '../theme/app_dimensions.dart';
import 'custom_shimmer.dart';
import 'shimmer_layouts.dart';

/// Full-page skeleton matching [DashboardPage] layout.
class DashboardPageShimmer extends StatelessWidget {
  const DashboardPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      children: [
        ShimmerLayouts.heroCard(),
        const SizedBox(height: AppDimensions.spaceLg),
        ShimmerLayouts.sectionTitle(),
        const SizedBox(height: AppDimensions.spaceSm),
        ShimmerLayouts.kpiGrid(context),
        const SizedBox(height: AppDimensions.spaceMd),
        ShimmerLayouts.singleKpiCard(context),
        const SizedBox(height: AppDimensions.spaceLg),
        ShimmerLayouts.sectionTitle(width: 80),
        const SizedBox(height: AppDimensions.spaceSm),
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 900;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: ShimmerLayouts.chartBlock(height: 220)),
                  const SizedBox(width: AppDimensions.spaceMd),
                  Expanded(flex: 2, child: ShimmerLayouts.chartBlock(height: 220)),
                ],
              );
            }
            return Column(
              children: [
                ShimmerLayouts.chartBlock(height: 200),
                const SizedBox(height: AppDimensions.spaceMd),
                ShimmerLayouts.chartBlock(height: 160),
              ],
            );
          },
        ),
        const SizedBox(height: AppDimensions.spaceLg),
        LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 900;
            if (wide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: ShimmerLayouts.breakdownCard()),
                  const SizedBox(width: AppDimensions.spaceMd),
                  Expanded(flex: 2, child: ShimmerLayouts.ratioCard()),
                ],
              );
            }
            return Column(
              children: [
                ShimmerLayouts.breakdownCard(),
                const SizedBox(height: AppDimensions.spaceMd),
                ShimmerLayouts.ratioCard(),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

/// P&L screen skeleton.
class PnlPageShimmer extends StatelessWidget {
  const PnlPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      children: [
        ShimmerLayouts.accountSection(rows: 4),
        const SizedBox(height: AppDimensions.spaceMd),
        ShimmerLayouts.accountSection(rows: 4),
        const SizedBox(height: AppDimensions.spaceMd),
        ShimmerLayouts.accountSection(rows: 3),
      ],
    );
  }
}

/// Comparison screen skeleton.
class ComparisonPageShimmer extends StatelessWidget {
  const ComparisonPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      children: [
        ShimmerLayouts.filterBarCard(),
        const SizedBox(height: AppDimensions.spaceMd),
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(height: AppDimensions.spaceSm),
          ShimmerLayouts.comparisonYearCard(),
        ],
      ],
    );
  }
}

/// Growth screen skeleton.
class GrowthPageShimmer extends StatelessWidget {
  const GrowthPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      children: [
        ShimmerLayouts.kpiPairRow(context),
        const SizedBox(height: AppDimensions.spaceMd),
        ShimmerLayouts.glassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLayouts.sectionTitle(width: 120),
              const SizedBox(height: 12),
              ShimmerBox(width: 180, height: 28, borderRadius: 6),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spaceMd),
        ShimmerLayouts.chartBlock(height: 220),
      ],
    );
  }
}

/// Branches, capital, distributions list-style pages.
class ListPageShimmer extends StatelessWidget {
  const ListPageShimmer({
    super.key,
    this.itemCount = 6,
    this.showHeader = true,
    this.rowHeight = 72,
  });

  final int itemCount;
  final bool showHeader;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      children: [
        if (showHeader) ...[
          ShimmerLayouts.listCardRow(height: 56),
          const SizedBox(height: AppDimensions.spaceSm),
        ],
        for (var i = 0; i < itemCount; i++)
          ShimmerLayouts.listCardRow(height: rowHeight),
      ],
    );
  }
}

/// Distributions — header + quarterly rows.
class DistributionsPageShimmer extends StatelessWidget {
  const DistributionsPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      children: [
        ShimmerBox(width: 100, height: 18, borderRadius: 4),
        const SizedBox(height: 8),
        ShimmerBox(width: 160, height: 14, borderRadius: 4),
        const SizedBox(height: 16),
        ShimmerLayouts.sectionTitle(width: 90),
        const SizedBox(height: 8),
        for (var i = 0; i < 4; i++) ShimmerLayouts.listCardRow(height: 56),
        const SizedBox(height: 16),
        ShimmerLayouts.sectionTitle(width: 90),
        const SizedBox(height: 8),
        for (var i = 0; i < 4; i++) ShimmerLayouts.listCardRow(height: 56),
      ],
    );
  }
}

/// Reports export card (static page; button busy state only).
class ReportsPageShimmer extends StatelessWidget {
  const ReportsPageShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      children: [ShimmerLayouts.reportsCard()],
    );
  }
}
