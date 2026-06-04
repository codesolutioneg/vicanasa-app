import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/bilingual_display.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/liquid_glass.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../financial/domain/entities/partner_info.dart';
import '../../domain/closed_month_option.dart';
import '../cubit/filter_cubit.dart';
import '../widgets/branch_selector.dart';
import '../widgets/closed_months_picker_sheet.dart';
import '../widgets/date_filter_bar.dart';

class FinancialShellPage extends StatefulWidget {
  const FinancialShellPage({super.key, required this.child});
  final Widget child;

  @override
  State<FinancialShellPage> createState() => _FinancialShellPageState();
}

class _FinancialShellPageState extends State<FinancialShellPage> {
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
      backgroundColor: AppColors.bgPrimary,
      body: Column(
        children: [
          _MobileHeader(partner: partner, l10n: l10n),
          Expanded(child: widget.child),
        ],
      ),
      bottomNavigationBar: _MobileBottomNav(
        navItems: navItems,
        moreItems: moreItems,
        currentLoc: loc,
        onLogout: () => context.read<AuthCubit>().logout(),
        onMore: () => _showMore(context, moreItems),
      ),
    );
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

// ─── Shared desktop/wide header ───────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({this.partner});
  final PartnerInfo? partner;

  @override
  Widget build(BuildContext context) {
    if (partner == null) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(bottom: BorderSide(color: AppColors.borderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.welcomeBack, style: AppTextStyles.caption),
          Text(
            partner!.partnerName ?? '',
            style: AppTextStyles.headlineSm,
          ),
        ],
      ),
    );
  }
}

// ─── Mobile sticky header (HTML design) ───────────────────────────────────────
class _MobileHeader extends StatelessWidget {
  const _MobileHeader({required this.partner, required this.l10n});
  final PartnerInfo? partner;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgSecondary,
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
          decoration: const BoxDecoration(
            color: AppColors.bgSecondary,
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.welcomeBack,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.textTertiary)),
                  Text(
                    partner?.partnerName ?? '...',
                    style: AppTextStyles.headlineSm,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const _CompactFiltersRow(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Compact filter row: period preset + branch ────────────────────────────────
class _CompactFiltersRow extends StatelessWidget {
  const _CompactFiltersRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: _PeriodDropdown()),
        const SizedBox(width: 8),
        Expanded(child: _MinibranchSelector()),
      ],
    );
  }
}

class _PeriodDropdown extends StatelessWidget {
  const _PeriodDropdown();

  String _displayLabel(FilterState s) {
    if (s.periodPreset == 'YTD') return 'This Year';
    if (s.periodPreset == 'MULTI' && s.selectedMonthKeys.length > 1) {
      return '${s.selectedMonthKeys.length} months';
    }
    if (s.closedMonths.isNotEmpty) {
      for (final m in s.closedMonths) {
        if (m.key == s.periodPreset) return BilingualDisplay.swapMonthLabel(m.name);
      }
    }
    return '${s.dateFrom.month}/${s.dateFrom.year} – ${s.dateTo.month}/${s.dateTo.year}';
  }

  Future<void> _openMultiPicker(BuildContext context, FilterState state) async {
    final picked = await showClosedMonthsPickerSheet(
      context: context,
      closedMonths: state.closedMonths,
      initialSelectedKeys: state.selectedMonthKeys,
    );
    if (picked == null || picked.isEmpty || !context.mounted) return;
    context.read<FilterCubit>().setClosedMonths(picked);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<FilterCubit>().state;
    final cubit = context.read<FilterCubit>();
    final hasClosed = state.closedMonths.isNotEmpty;
    final display = _displayLabel(state);

    if (!hasClosed) {
      return _FilterBox(
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: state.periodPreset == 'MTD' ||
                    state.periodPreset == 'YTD' ||
                    state.periodPreset == 'LAST'
                ? state.periodPreset
                : null,
            hint: Text(
              display,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
            isExpanded: true,
            isDense: true,
            icon: const Icon(CupertinoIcons.chevron_down,
                size: 13, color: AppColors.textSecondary),
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
            items: const [
              DropdownMenuItem(value: 'YTD', child: Text('This Year', style: TextStyle(fontSize: 12))),
              DropdownMenuItem(value: 'MTD', child: Text('This Month', style: TextStyle(fontSize: 12))),
              DropdownMenuItem(value: 'LAST', child: Text('Last Month', style: TextStyle(fontSize: 12))),
            ],
            onChanged: (v) {
              if (v == 'MTD') cubit.setMtd();
              if (v == 'YTD') cubit.setYtd();
              if (v == 'LAST') cubit.setLastMonth();
            },
          ),
        ),
      );
    }

    final menuKeys = <String>['YTD', 'MULTI', ...state.closedMonths.map((m) => m.key)];

    return _FilterBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: menuKeys.contains(state.periodPreset) ? state.periodPreset : null,
          hint: Text(
            display,
            style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
          isExpanded: true,
          isDense: true,
          icon: const Icon(CupertinoIcons.chevron_down,
              size: 13, color: AppColors.textSecondary),
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          items: [
            const DropdownMenuItem(
              value: 'YTD',
              child: Text('This Year', style: TextStyle(fontSize: 12)),
            ),
            const DropdownMenuItem(
              value: 'MULTI',
              child: Text('Select months…', style: TextStyle(fontSize: 12)),
            ),
            ...state.closedMonths.map(
              (ClosedMonthOption m) => DropdownMenuItem(
                value: m.key,
                child: BilingualDisplay.monthLabel(
                  m.name,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
          onChanged: (v) async {
            if (v == null) return;
            if (v == 'YTD') {
              cubit.setYtd();
              return;
            }
            if (v == 'MULTI') {
              await _openMultiPicker(context, state);
              return;
            }
            for (final m in state.closedMonths) {
              if (m.key == v) {
                cubit.setClosedMonth(m);
                break;
              }
            }
          },
        ),
      ),
    );
  }
}

class _MinibranchSelector extends StatelessWidget {
  const _MinibranchSelector();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthCubit>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    final options = auth.partner.analyticOptions;
    if (options.isEmpty) return const SizedBox.shrink();
    final filter = context.watch<FilterCubit>().state;

    return _FilterBox(
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: filter.analyticId,
          isExpanded: true,
          isDense: true,
          icon: const Icon(CupertinoIcons.chevron_down,
              size: 13, color: AppColors.textSecondary),
          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
          hint: const Text('All Branches',
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
              overflow: TextOverflow.ellipsis),
          items: [
            const DropdownMenuItem<int?>(
                value: null,
                child: Text('All Branches',
                    style: TextStyle(fontSize: 12))),
            ...options.map((o) => DropdownMenuItem<int?>(
                  value: o.id,
                  child: Text(o.name,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                )),
          ],
          onChanged: (v) => context.read<FilterCubit>().setBranch(v),
        ),
      ),
    );
  }
}

class _FilterBox extends StatelessWidget {
  const _FilterBox({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

// ─── Simple mobile bottom nav (HTML design) ────────────────────────────────────
class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav({
    required this.navItems,
    required this.moreItems,
    required this.currentLoc,
    required this.onLogout,
    required this.onMore,
  });

  final List<(String, String, IconData)> navItems;
  final List<(String, String, IconData)> moreItems;
  final String currentLoc;
  final VoidCallback onLogout;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            children: [
              ...navItems.map(
                (e) => _NavBtn(
                  icon: e.$3,
                  label: e.$2,
                  active: currentLoc.startsWith(e.$1),
                  onTap: () => context.go(e.$1),
                ),
              ),
              if (moreItems.isNotEmpty)
                _NavBtn(
                  icon: CupertinoIcons.ellipsis_circle,
                  label: 'More',
                  active: moreItems.any((e) => currentLoc.startsWith(e.$1)),
                  onTap: onMore,
                ),
              _NavBtn(
                icon: CupertinoIcons.square_arrow_left,
                label: 'Logout',
                active: false,
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primaryMid : AppColors.textTertiary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                    active ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
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
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(right: BorderSide(color: AppColors.borderLight)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      CupertinoIcons.chart_bar_alt_fill,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.appTitle, style: AppTextStyles.headlineSm),
                        if (partner != null)
                          Text(
                            partner!.partnerName ?? '',
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
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
                        style: AppTextStyles.kpiLabel,
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
                        style: AppTextStyles.kpiLabel,
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
                color: active ? AppColors.primaryMid : AppColors.textMuted,
              ),
              const SizedBox(width: AppDimensions.spaceMd),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: active ? AppColors.primaryMid : AppColors.textSecondary,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  ),
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
          borderRadius: BorderRadius.circular(10),
          color: AppColors.primaryPale,
        ),
        child: tile,
      ),
    );
  }
}
