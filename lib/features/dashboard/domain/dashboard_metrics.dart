import 'branch_share_line.dart';

/// Mirrors Odoo `portal_templates.xml` ratio and profit-distribution logic.
class DashboardMetrics {
  DashboardMetrics._();

  static double amount(Map<String, dynamic>? g) =>
      (g?['total_amount'] as num?)?.toDouble() ?? 0;

  static double salesVal(List<Map<String, dynamic>> revenueGrouped, double revenue) {
    return salesAndOtherIncome(
      revenue: revenue,
      revenueGrouped: revenueGrouped,
    ).sales;
  }

  static double otherIncomeVal(List<Map<String, dynamic>> revenueGrouped) {
    return salesAndOtherIncome(
      revenue: 0,
      revenueGrouped: revenueGrouped,
    ).otherIncome;
  }

  /// Sales = first `revenue_grouped` group; Other Income = second.
  ///
  /// When `analysis_level` is `none`, Odoo clears `revenue_grouped` but still
  /// sends `ratios.sales` (computed before sanitize). Fall back to that:
  /// Other Income = revenue − ratios.sales.
  static ({double sales, double otherIncome}) salesAndOtherIncome({
    required double revenue,
    required List<Map<String, dynamic>> revenueGrouped,
    Map<String, dynamic>? ratios,
  }) {
    if (revenueGrouped.length > 1) {
      return (
        sales: amount(revenueGrouped.first),
        otherIncome: amount(revenueGrouped[1]),
      );
    }
    final salesFromRatios = (ratios?['sales'] as num?)?.toDouble();
    if (salesFromRatios != null && salesFromRatios > 0) {
      return (
        sales: salesFromRatios,
        otherIncome: (revenue - salesFromRatios).clamp(0.0, revenue),
      );
    }
    if (revenueGrouped.isNotEmpty) {
      return (sales: amount(revenueGrouped.first), otherIncome: 0);
    }
    return (sales: revenue, otherIncome: 0);
  }

  /// Per-branch share lines. Does **not** average percentages.
  ///
  /// Each line: `branch_share = branch_net_profit × share_percentage / 100`
  /// (from Odoo `analytic_options`). Optional [analyticId] filters to one branch.
  static List<BranchShareLine> branchShares(
    Map<String, dynamic> data, {
    int? analyticId,
  }) {
    final raw = data['analytic_options'];
    if (raw is! List) return const [];
    final lines = <BranchShareLine>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      final id = (m['id'] as num?)?.toInt();
      if (id == null) continue;
      if (analyticId != null && id != analyticId) continue;
      lines.add(BranchShareLine(
        id: id,
        name: (m['name'] as String?)?.trim().isNotEmpty == true
            ? (m['name'] as String).trim()
            : 'Branch $id',
        sharePercentage: _n(m['share_percentage']),
        netProfit: _n(m['net_profit']),
        branchShare: _n(m['branch_share']),
        revenue: _n(m['revenue']),
        sales: _n(m['sales']),
        otherIncome: _n(m['other_income']),
        cost: _n(m['cost']),
        expense: _n(m['expense']),
        capital: _n(m['capital']),
        distribution: _n(m['distribution']),
      ));
    }
    return lines;
  }

  static double totalBranchShare(List<BranchShareLine> lines) =>
      lines.fold(0.0, (sum, l) => sum + l.branchShare);

  static double totalBranchRevenue(List<BranchShareLine> lines) =>
      lines.fold(0.0, (sum, l) => sum + l.revenue);

  static double totalBranchSales(List<BranchShareLine> lines) =>
      lines.fold(0.0, (sum, l) => sum + l.sales);

  static double totalBranchOtherIncome(List<BranchShareLine> lines) =>
      lines.fold(0.0, (sum, l) => sum + l.otherIncome);

  static double totalBranchDeductions(List<BranchShareLine> lines) =>
      lines.fold(0.0, (sum, l) => sum + l.deductions);

  /// Sales / Other Income lines for the Total Revenue card.
  ///
  /// Odoo web always renders `revenue_grouped`. The JSON API may clear that
  /// list when `analysis_level == 'none'`, but still returns `ratios.sales`
  /// (computed before sanitize). Fall back to that so the split still shows.
  static List<({String label, double amount})> revenueBreakdown({
    required double revenue,
    required List<Map<String, dynamic>> revenueGrouped,
    Map<String, dynamic>? ratios,
  }) {
    if (revenueGrouped.isNotEmpty) {
      return [
        for (final g in revenueGrouped)
          (
            label: ((g['group_name'] as String?)?.trim().isNotEmpty == true)
                ? (g['group_name'] as String).trim()
                : 'Revenue',
            amount: amount(g),
          ),
      ];
    }

    final salesFromRatios = (ratios?['sales'] as num?)?.toDouble();
    if (salesFromRatios != null && salesFromRatios > 0) {
      final other = (revenue - salesFromRatios).clamp(0.0, revenue);
      return [
        (label: 'Sales', amount: salesFromRatios),
        (label: 'Other Income', amount: other),
      ];
    }

    return const [];
  }

  static ({
    double expenseRatio,
    double costRatio,
    double otherIncomeRatio,
    double profitMargin,
    double partnerMargin,
  }) ratios(Map<String, dynamic> data) {
    final apiRatios = data['ratios'];
    if (apiRatios is Map) {
      final m = Map<String, dynamic>.from(apiRatios);
      return (
        expenseRatio: _n(m['expense_to_revenue_pct']),
        costRatio: _n(m['cost_of_sales_pct']),
        otherIncomeRatio: _n(m['other_income_pct']),
        profitMargin: _n(m['company_profit_margin_pct']),
        partnerMargin: _n(m['your_profit_margin_pct']),
      );
    }

    final revenueGrouped = _groups(data['revenue_grouped']);
    final sales = salesVal(revenueGrouped, _n(data['revenue']));
    final salesSafe = sales > 0 ? sales : 1.0;
    final expense = _n(data['expense']);
    final cost = _n(data['cost']);
    final netProfit = _n(data['net_profit']);
    final partnerShare = _n(data['partner_share']);
    final otherIncome = otherIncomeVal(revenueGrouped);

    return (
      expenseRatio: sales > 0 ? expense / salesSafe * 100 : 0,
      costRatio: sales > 0 ? cost / salesSafe * 100 : 0,
      otherIncomeRatio: sales > 0 ? otherIncome / salesSafe * 100 : 0,
      profitMargin: sales > 0 ? netProfit / salesSafe * 100 : 0,
      partnerMargin: sales > 0 ? partnerShare / salesSafe * 100 : 0,
    );
  }

  static ({
    double yourShare,
    double companyShare,
    double totalProfit,
    bool isLoss,
  }) profitDistribution(
    Map<String, dynamic> data, {
    int? analyticId,
  }) {
    final revenue = _n(data['revenue']);
    final cost = _n(data['cost']);
    final expense = _n(data['expense']);
    final grossProfit = revenue - cost - expense;
    final lines = branchShares(data, analyticId: analyticId);
    final partnerShare = lines.isNotEmpty
        ? totalBranchShare(lines)
        : _n(data['partner_share']);

    if (grossProfit >= 0) {
      final companyShare = grossProfit - partnerShare;
      return (
        yourShare: partnerShare.abs(),
        companyShare: companyShare.abs(),
        totalProfit: grossProfit,
        isLoss: false,
      );
    }
    final partnerLoss = partnerShare.abs();
    final totalLoss = grossProfit.abs();
    final companyLoss = totalLoss - partnerLoss;
    return (
      yourShare: partnerLoss,
      companyShare: companyLoss,
      totalProfit: totalLoss,
      isLoss: true,
    );
  }

  static List<Map<String, dynamic>> _groups(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  static double _n(dynamic v) => (v as num?)?.toDouble() ?? 0;
}
