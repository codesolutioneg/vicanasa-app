import 'package:intl/intl.dart';

/// Currency/percent formatting matching Odoo portal `{:,.2f}` display.
abstract final class AppFormatters {
  static final NumberFormat currency = NumberFormat('#,##0.00', 'en_US');

  static final NumberFormat percent1 = NumberFormat('#,##0.0', 'en_US');

  static final NumberFormat percent2 = NumberFormat('#,##0.00', 'en_US');

  static String money(double value) => currency.format(value);

  static String moneyParen(double value) => '(${currency.format(value.abs())})';
}
