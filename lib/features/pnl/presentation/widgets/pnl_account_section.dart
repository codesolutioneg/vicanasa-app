import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_formatters.dart';
import 'pnl_group_tile.dart';

/// Expandable P&L section (Revenue / Costs / Expenses) with permission-aware groups.
class PnlAccountSection extends StatelessWidget {
  const PnlAccountSection({
    super.key,
    required this.title,
    required this.groups,
    required this.accent,
    required this.analysisLevel,
    required this.allowedGroupIds,
    this.fallbackTotal,
    this.initiallyExpanded = true,
  });

  final String title;
  final List<Map<String, dynamic>> groups;
  final Color accent;
  final String analysisLevel;
  final List<int> allowedGroupIds;
  final double? fallbackTotal;
  final bool initiallyExpanded;

  double get _sectionTotal {
    if (groups.isEmpty) return fallbackTotal ?? 0;
    return groups.fold(
      0.0,
      (s, g) => s + ((g['total_amount'] as num?)?.toDouble() ?? 0),
    );
  }

  TextStyle _cairo({
    double size = 15,
    FontWeight weight = FontWeight.w600,
    Color? color,
  }) {
    return GoogleFonts.cairo(
      fontSize: size,
      fontWeight: weight,
      color: color ?? AppColors.textPrimary,
      letterSpacing: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.bgSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accent.withValues(alpha: 0.28)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(CupertinoIcons.list_bullet, size: 18, color: accent),
          ),
          title: Text(title, style: _cairo(size: 15, weight: FontWeight.w700)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              AppFormatters.money(_sectionTotal),
              style: _cairo(size: 15, weight: FontWeight.w800, color: accent),
            ),
          ),
          children: [
            if (groups.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  analysisLevel == 'none'
                      ? 'Account names are hidden for this selection because '
                          'analysis level is none. Totals above still follow the '
                          'branch filter — raise the branch Financial analysis '
                          'level in Odoo to see account names.'
                      : 'No accounts in this period.',
                  textAlign: TextAlign.right,
                  style: _cairo(
                    size: 13,
                    weight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              )
            else
              for (final g in groups)
                PnlGroupTile(
                  group: g,
                  accent: accent,
                  analysisLevel: analysisLevel,
                  allowedGroupIds: allowedGroupIds,
                ),
          ],
        ),
      ),
    );
  }
}
