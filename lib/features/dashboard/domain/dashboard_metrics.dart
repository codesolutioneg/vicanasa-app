/// Mirrors Odoo `portal_templates.xml` ratio and profit-distribution logic.
class DashboardMetrics {
  DashboardMetrics._();

  static double amount(Map<String, dynamic>? g) =>
      (g?['total_amount'] as num?)?.toDouble() ?? 0;

  static double salesVal(List<Map<String, dynamic>> revenueGrouped, double revenue) {
    if (revenueGrouped.isNotEmpty) return amount(revenueGrouped.first);
    return revenue;
  }

  static double otherIncomeVal(List<Map<String, dynamic>> revenueGrouped) {
    if (revenueGrouped.length > 1) return amount(revenueGrouped[1]);
    return 0;
  }

  static ({
    double expenseRatio,
    double costRatio,
    double otherIncomeRatio,
    double profitMargin,
    double partnerMargin,
  }) ratios(Map<String, dynamic> data) {
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
  }) profitDistribution(Map<String, dynamic> data) {
    final revenue = _n(data['revenue']);
    final cost = _n(data['cost']);
    final expense = _n(data['expense']);
    final grossProfit = revenue - cost - expense;
    final partnerShare = _n(data['partner_share']);

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
