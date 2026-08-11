import 'package:flutter/services.dart';

/// Formatter de moeda estilo aplicativo de banco.
///
/// Ao digitar, os dígitos preenchem da direita para a esquerda,
/// mantendo a vírgula (separador decimal) sempre na posição fixa
/// com 2 casas decimais.
///
/// Exemplos de digitação sequencial:
///   1       → 0,01
///   12      → 0,12
///   123     → 1,23
///   1234    → 12,34
///   12345   → 123,45
///   1234567 → 12.345,67  (com separador de milhar)
class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extrai apenas os dígitos do novo valor
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    // Se ficou vazio, limpa tudo
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Converte para centavos (inteiro) e depois formata
    final value = int.parse(digitsOnly);

    // Formata: divide por 100 para ter 2 casas decimais
    final reais = value ~/ 100;
    final centavos = (value % 100).toString().padLeft(2, '0');

    // Formata a parte inteira com separador de milhar (ponto)
    final parteInteira = _formatarComMilhar(reais);

    final formatted = '$parteInteira,$centavos';

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  /// Formata um inteiro com separador de milhar (ponto).
  /// Ex: 1234567 → "1.234.567"
  String _formatarComMilhar(int valor) {
    final str = valor.toString();
    if (str.length <= 3) return str;

    final buffer = StringBuffer();
    final mod = str.length % 3;

    for (int i = 0; i < str.length; i++) {
      if (i != 0 && (i - mod) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }

    return buffer.toString();
  }
}
