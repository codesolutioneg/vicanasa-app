import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../../../../core/constants/env.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../core/theme/recommended_glass_settings.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../financial/domain/entities/partner_info.dart';
import '../widgets/branch_selector.dart';
import '../widgets/date_filter_bar.dart';

class FinancialShellPage extends StatefulWidget {
  const FinancialShellPage({super.key, required this.child});
  final Widget child;

  @override
  State<FinancialShellPage> createState() => _FinancialShellPageState();
}

class _FinancialShellPageState extends State<FinancialShellPage> {
  final _drawerKey = GlobalKey<ScaffoldState>();

  int _mobileIndex(String loc) {
    if (loc.startsWith(AppRoutes.pnl)) return 1;
    if (loc.startsWith(AppRoutes.comparison)) return 2;
    if (loc.startsWith(AppRoutes.reports)) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loc = GoRouterState.of(context).matchedLocation;
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final auth = context.watch<AuthCubit>().state;
    final partner = auth is AuthAuthenticated ? auth.partner : null;

    final navItems = [
      (AppRoutes.dashboard, l10n.navDashboard, CupertinoIcons.square_grid_2x2_fill),
      (AppRoutes.pnl, l10n.navPnl, CupertinoIcons.doc_text_fill),
      (AppRoutes.comparison, l10n.navComparison, CupertinoIcons.chart_bar_fill),
      (AppRoutes.reports, l10n.navReports, CupertinoIcons.arrow_down_doc_fill),
    ];

    final moreItems = [
      (AppRoutes.growth, l10n.navGrowth, CupertinoIcons.arrow_up_right),
      (AppRoutes.branches, l10n.navBranches, CupertinoIcons.building_2_fill),
      (AppRoutes.distributions, l10n.navDistributions, CupertinoIcons.chart_pie_fill),
      (AppRoutes.capital, l10n.navCapital, CupertinoIcons.money_dollar_circle_fill),
    ];

    if (wide) {
      return Scaffold(
        body: Row(
          children: [
            _Sidebar(
              partner: partner,
              navItems: navItems,
              moreItems: moreItems,
              current: loc,
              onLogout: () => context.read<AuthCubit>().logout(),
            ),
            Expanded(
              child: Column(
                children: [
                  _Header(partner: partner),
                  const DateFilterBar(),
                  const BranchSelector(),
                  Expanded(child: widget.child),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      key: _drawerKey,
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        child: _Sidebar(
          partner: partner,
          navItems: [...navItems, ...moreItems],
          moreItems: const [],
          current: loc,
          onLogout: () => context.read<AuthCubit>().logout(),
          inDrawer: true,
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.bars),
          onPressed: () => _drawerKey.currentState?.openDrawer(),
        ),
        title: Text(_titleFor(loc, l10n), style: AppTextStyles.headlineSm),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.ellipsis_vertical),
            onPressed: () => _showMore(context, moreItems),
          ),
        ],
      ),
      body: Column(
        children: [
          const DateFilterBar(),
          const BranchSelector(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppDimensions.bottomNavHeight),
              child: widget.child,
            ),
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: AdaptiveLiquidGlassLayer(
        settings: RecommendedGlassSettings.bottomBar,
        child: GlassBottomBar(
          tabs: navItems
              .map(
                (e) => GlassBottomBarTab(
                  label: e.$2,
                  icon: Icon(e.$3, color: AppColors.textMuted),
                  activeIcon: Icon(e.$3, color: AppColors.primaryDark),
                  glowColor: AppColors.primaryLight,
                ),
              )
              .toList(),
          selectedIndex: _mobileIndex(loc),
          onTabSelected: (i) => context.go(navItems[i].$1),
          glassSettings: RecommendedGlassSettings.bottomBar,
          selectedIconColor: AppColors.primaryDark,
          unselectedIconColor: AppColors.textMuted,
          indicatorColor: AppColors.primaryMid.withValues(alpha: 0.35),
          textStyle: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
  }

  String _titleFor(String loc, AppLocalizations l10n) {
    if (loc.startsWith(AppRoutes.pnl)) return l10n.navPnl;
    if (loc.startsWith(AppRoutes.comparison)) return l10n.navComparison;
    if (loc.startsWith(AppRoutes.reports)) return l10n.navReports;
    if (loc.startsWith(AppRoutes.growth)) return l10n.navGrowth;
    if (loc.startsWith(AppRoutes.branches)) return l10n.navBranches;
    if (loc.startsWith(AppRoutes.distributions)) return l10n.navDistributions;
    if (loc.startsWith(AppRoutes.capital)) return l10n.navCapital;
    return l10n.navDashboard;
  }

  void _showMore(BuildContext context, List<(String, String, IconData)> items) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => LiquidGlassModal(
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: items
                .map(
                  (e) => ListTile(
                    leading: Icon(e.$3, color: AppColors.primaryMid),
                    title: Text(e.$2),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.go(e.$1);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.partner});
  final PartnerInfo? partner;

  @override
  Widget build(BuildContext context) {
    if (partner == null) return const SizedBox.shrink();
    final avatarUrl =
        '${Env.odooBaseUrl}/web/image/res.partner/${partner!.partnerId}/avatar_128';
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spaceMd),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(avatarUrl),
            onBackgroundImageError: (_, __) {},
            child: const Icon(CupertinoIcons.person_fill, color: AppColors.primaryMid),
          ),
          const SizedBox(width: 12),
          Text(partner!.partnerName ?? '', style: AppTextStyles.headlineSm),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.navItems,
    required this.moreItems,
    required this.current,
    required this.onLogout,
    this.partner,
    this.inDrawer = false,
  });

  final List<(String, String, IconData)> navItems;
  final List<(String, String, IconData)> moreItems;
  final String current;
  final VoidCallback onLogout;
  final PartnerInfo? partner;
  final bool inDrawer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: inDrawer ? null : AppDimensions.sidebarWidth,
      decoration: const BoxDecoration(gradient: AppColors.splashGradient),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spaceMd,
                AppDimensions.spaceMd,
                AppDimensions.spaceMd,
                AppDimensions.spaceSm,
              ),
              child: LiquidGlassCard(
                borderRadius: AppDimensions.radiusLg,
                padding: const EdgeInsets.all(AppDimensions.spaceMd),
                blurSigma: 18,
                child: Column(
                  children: [
                    Text(
                      l10n.appTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineSm.copyWith(color: AppColors.textOnDark),
                    ),
                    if (partner != null) ...[
                      const SizedBox(height: AppDimensions.spaceXs),
                      Text(
                        partner!.partnerName ?? '',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.caption.copyWith(color: Colors.white70),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spaceSm),
                children: [
                  if (navItems.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.spaceSm,
                        bottom: AppDimensions.spaceXs,
                      ),
                      child: Text(
                        l10n.navSectionMain,
                        style: AppTextStyles.kpiLabel.copyWith(color: Colors.white54),
                      ),
                    ),
                  ...navItems.map(
                    (e) => _NavTile(
                      route: e.$1,
                      label: e.$2,
                      icon: e.$3,
                      current: current,
                      popDrawer: inDrawer,
                    ),
                  ),
                  if (moreItems.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spaceMd),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: AppDimensions.spaceSm,
                        bottom: AppDimensions.spaceXs,
                      ),
                      child: Text(
                        l10n.navSectionMore,
                        style: AppTextStyles.kpiLabel.copyWith(color: Colors.white54),
                      ),
                    ),
                    ...moreItems.map(
                      (e) => _NavTile(
                        route: e.$1,
                        label: e.$2,
                        icon: e.$3,
                        current: current,
                        popDrawer: inDrawer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spaceSm),
              child: _NavTile(
                route: '',
                label: l10n.logout,
                icon: CupertinoIcons.square_arrow_left,
                current: current,
                popDrawer: inDrawer,
                onTap: onLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.route,
    required this.label,
    required this.icon,
    required this.current,
    this.popDrawer = false,
    this.onTap,
  });

  final String route;
  final String label;
  final IconData icon;
  final String current;
  final bool popDrawer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final active = route.isNotEmpty && current.startsWith(route);
    final tile = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (popDrawer) Navigator.pop(context);
          if (onTap != null) {
            onTap!();
            return;
          }
          context.go(route);
        },
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceMd,
            vertical: AppDimensions.spaceSm,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: active ? AppColors.primaryPale : Colors.white60,
              ),
              const SizedBox(width: AppDimensions.spaceMd),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: active ? AppColors.textOnDark : Colors.white70,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              if (active)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (!active) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppDimensions.spaceXxs),
        child: tile,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spaceXxs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.22),
              Colors.white.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: tile,
      ),
    );
  }
}
