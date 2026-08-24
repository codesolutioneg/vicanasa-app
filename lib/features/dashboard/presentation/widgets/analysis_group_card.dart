import 'package:flutter/material.dart';

import 'analysis_accounts_table.dart';
import 'analysis_group_chrome.dart';
import 'analysis_permission.dart';

/// One account-group block (header + optional table + subtotal).
class AnalysisGroupCard extends StatelessWidget {
  const AnalysisGroupCard({
    super.key,
    required this.group,
    required this.themeColor,
    required this.analysisLevel,
    required this.allowedGroupIds,
    this.revenueBase,
    this.showRevPercent = false,
    this.headerSolid = true,
  });

  final Map<String, dynamic> group;
  final Color themeColor;
  final String analysisLevel;
  final List<int> allowedGroupIds;
  final double? revenueBase;
  final bool showRevPercent;
  final bool headerSolid;

  @override
  Widget build(BuildContext context) {
    final groupId = group['group_id'] as int?;
    final code = '${group['group_code'] ?? ''}';
    final name = '${group['group_name'] ?? 'Undefined Group'}';
    final total = (group['total_amount'] as num?)?.toDouble() ?? 0;
    final accounts = (group['accounts'] as List? ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    final canSee = canSeeGroupDetails(
      analysisLevel: analysisLevel,
      allowedGroupIds: allowedGroupIds,
      groupId: groupId,
    );
    final locked = showGroupLockIcon(
      analysisLevel: analysisLevel,
      canSeeDetails: canSee,
    );
    final pct = _pct(total);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor.withValues(alpha: 0.25)),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnalysisGroupHeader(
            code: code,
            name: name,
            total: total,
            themeColor: themeColor,
            canSee: canSee,
            locked: locked,
            headerSolid: headerSolid,
            percent: pct,
          ),
          if (canSee && accounts.isNotEmpty)
            AnalysisAccountsTable(
              accounts: accounts,
              themeColor: themeColor,
              groupId: groupId,
              revenueBase: revenueBase,
              showRevPercent: showRevPercent,
            ),
          AnalysisGroupFooter(
            label: 'Total $name',
            total: total,
            themeColor: themeColor,
            percent: pct,
          ),
        ],
      ),
    );
  }

  double? _pct(double amount) {
    final base = revenueBase;
    if (!showRevPercent || base == null || base <= 0) return null;
    return amount / base * 100;
  }
}
