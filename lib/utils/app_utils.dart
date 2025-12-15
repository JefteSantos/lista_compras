import 'package:intl/intl.dart';

class AppUtils {
  static String formatMoney(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }
}
