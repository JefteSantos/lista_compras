import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AppUtils {
  // Existem apenas quatro formatos suportados. Reutilizá-los evita analisar
  // os padrões de moeda para cada preço exibido durante a rolagem.
  static final Map<String, NumberFormat> _currencyFormats = {};

  /// Retorna o símbolo de moeda e locale corretos baseado no idioma do sistema.
  static String formatMoney(double value) {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;

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

    final formatter = _currencyFormats.putIfAbsent(
      numberLocale,
      () => NumberFormat.currency(locale: numberLocale, symbol: currencySymbol),
    );
    return formatter.format(value);
  }

  /// Retorna a quantidade formatada sem `.0` se for inteira.
  static String formatQuantity(double quantity) {
    return quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toString().replaceAll('.', ',');
  }
}
