import 'package:intl/intl.dart';
import 'dart:ui' as ui;

class AppUtils {
  /// Retorna o símbolo de moeda e locale corretos baseado no idioma do sistema.
  static String formatMoney(double value) {
    final locale = ui.PlatformDispatcher.instance.locale;

    // Mapeia idioma → moeda
    String currencySymbol;
    String numberLocale;

    switch (locale.languageCode) {
      case 'pt':
        currencySymbol = 'R\$';
        numberLocale = 'pt_BR';
        break;
      case 'es':
        currencySymbol = '€';
        numberLocale = 'es_ES';
        break;
      case 'fr':
        currencySymbol = '€';
        numberLocale = 'fr_FR';
        break;
      case 'en':
      default:
        currencySymbol = '\$';
        numberLocale = 'en_US';
        break;
    }

    return NumberFormat.currency(locale: numberLocale, symbol: currencySymbol)
        .format(value);
  }

  /// Retorna a quantidade formatada sem `.0` se for inteira.
  static String formatQuantity(double quantity) {
    return quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toString().replaceAll('.', ',');
  }
}
