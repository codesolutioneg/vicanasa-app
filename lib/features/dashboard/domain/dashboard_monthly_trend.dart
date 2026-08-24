/// Normalize Odoo monthly trend payload for the Revenue vs Cost chart.
///
/// `/api/data` extras overwrite `monthly_data` with chart arrays:
/// `{ months, revenue, cost, profit }` — not the list from
/// `get_financial_data()` (`[{ month, revenue, cost, expense, net_profit }]`).
class DashboardMonthlyTrend {
  DashboardMonthlyTrend._();

  static List<Map<String, dynamic>> from(Map<String, dynamic> data) {
    final raw = data['monthly_data'] ?? data['monthly_chart'];
    if (raw is List) {
      return [
        for (final e in raw)
          if (e is Map) Map<String, dynamic>.from(e),
      ];
    }
    if (raw is! Map) return const [];
    return _fromChartMap(Map<String, dynamic>.from(raw));
  }

  static List<Map<String, dynamic>> _fromChartMap(Map<String, dynamic> chart) {
    final months = chart['months'];
    final revenues = chart['revenue'];
    final costs = chart['cost'];
    final profits = chart['profit'];
    if (months is! List || revenues is! List || costs is! List) {
      return const [];
    }
    final out = <Map<String, dynamic>>[];
    for (var i = 0; i < months.length; i++) {
      final rev = _n(i < revenues.length ? revenues[i] : 0);
      final cost = _n(i < costs.length ? costs[i] : 0);
      // Chart "profit" is partner share (often 0 for All Branches); legend is company Profit.
      final apiProfit =
          profits is List && i < profits.length ? _n(profits[i]) : 0.0;
      out.add({
        'month': '${months[i] ?? ''}',
        'revenue': rev,
        'cost': cost,
        'expense': 0.0,
        'net_profit': apiProfit != 0 ? apiProfit : rev - cost,
      });
    }
    return out;
  }

  static double _n(dynamic v) => (v as num?)?.toDouble() ?? 0;
}
