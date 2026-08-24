import 'package:intl/intl.dart';

/// Currency/percent formatting matching Odoo portal `{:,.2f}` display.
abstract final class AppFormatters {
  static final NumberFormat currency = NumberFormat('#,##0.00', 'en_US');

  static final NumberFormat percent1 = NumberFormat('#,##0.0', 'en_US');

  static final NumberFormat percent2 = NumberFormat('#,##0.00', 'en_US');

  static String money(double value) => currency.format(value);

  static String moneyParen(double value) => '(${currency.format(value.abs())})';

  /// Axis labels: `1.5k`, `50m` (1m = 1,000,000).
  static String compactMoney(double value) {
    final abs = value.abs();
    final sign = value < 0 ? '-' : '';
    if (abs >= 1000000) {
      final m = abs / 1000000;
      final text = (m >= 10 || (m - m.roundToDouble()).abs() < 0.05)
          ? m.round().toString()
          : m.toStringAsFixed(1);
      return '$sign${text}m';
    }
    if (abs >= 1000) {
      final k = abs / 1000;
      final text = (k >= 10 || (k - k.roundToDouble()).abs() < 0.05)
          ? k.round().toString()
          : k.toStringAsFixed(1);
      return '$sign${text}k';
    }
    return '$sign${abs.round()}';
  }
}
