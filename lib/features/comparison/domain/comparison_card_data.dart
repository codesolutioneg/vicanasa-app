/// Metrics for one Comparison result card.
class ComparisonCardData {
  const ComparisonCardData({
    required this.label,
    required this.revenue,
    required this.netProfit,
    required this.partnerShare,
  });

  final String label;
  final double revenue;
  final double netProfit;
  final double partnerShare;

  factory ComparisonCardData.fromApiMap(
    Map<String, dynamic> m, {
    required String label,
  }) {
    double n(dynamic v) => (v as num?)?.toDouble() ?? 0;
    return ComparisonCardData(
      label: label,
      revenue: n(m['revenue'] ?? m['total_revenue']),
      netProfit: n(m['net_profit']),
      partnerShare: n(m['partner_share']),
    );
  }
}
