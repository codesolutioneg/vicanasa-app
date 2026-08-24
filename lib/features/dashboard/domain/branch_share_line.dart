/// One branch line from API `analytic_options` (+ P&L enrichment).
class BranchShareLine {
  const BranchShareLine({
    required this.id,
    required this.name,
    required this.sharePercentage,
    required this.netProfit,
    required this.branchShare,
    this.revenue = 0,
    this.sales = 0,
    this.otherIncome = 0,
    this.cost = 0,
    this.expense = 0,
    this.capital = 0,
    this.distribution = 0,
  });

  final int id;
  final String name;
  final double sharePercentage;
  final double netProfit;
  final double branchShare;
  final double revenue;
  final double sales;
  final double otherIncome;
  final double cost;
  final double expense;
  final double capital;
  final double distribution;

  double get deductions => cost + expense;
}
