import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:lista_compras/utils/app_utils.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    binding.platformDispatcher.localeTestValue = const Locale('pt', 'BR');
  });

  tearDown(() {
    binding.platformDispatcher.clearLocaleTestValue();
  });

  group('AppUtils Tests', () {
    test('deve formatar valores monetários corretamente', () {
      expect(AppUtils.formatMoney(0), contains('0,00'));
      expect(AppUtils.formatMoney(10), contains('10,00'));
      expect(AppUtils.formatMoney(10.5), contains('10,50'));
      expect(AppUtils.formatMoney(1000), contains('1.000,00'));
      expect(AppUtils.formatMoney(1234.56), contains('1.234,56'));
      expect(AppUtils.formatMoney(1000000), contains('1.000.000,00'));
    });

    test('deve formatar valores negativos corretamente', () {
      expect(AppUtils.formatMoney(-10), contains('-'));
      expect(AppUtils.formatMoney(-10), contains('10,00'));
      expect(AppUtils.formatMoney(-1234.56), contains('1.234,56'));
    });

    test('deve formatar valores decimais corretamente', () {
      expect(AppUtils.formatMoney(0.01), contains('0,01'));
      expect(AppUtils.formatMoney(0.99), contains('0,99'));
      expect(AppUtils.formatMoney(10.999), contains('11,00'));
    });

    test('deve respeitar mudanças de idioma com os formatos em cache', () {
      expect(AppUtils.formatMoney(1234.56), contains('1.234,56'));
      binding.platformDispatcher.localeTestValue = const Locale('en', 'US');
      expect(AppUtils.formatMoney(1234.56), r'$1,234.56');
      binding.platformDispatcher.localeTestValue = const Locale('fr', 'FR');
      expect(AppUtils.formatMoney(1234.56), contains('234,56'));
      expect(AppUtils.formatMoney(1234.56), contains('€'));
      binding.platformDispatcher.localeTestValue = const Locale('es', 'ES');
      expect(AppUtils.formatMoney(1234.56), contains('1.234,56'));
      expect(AppUtils.formatMoney(1234.56), contains('€'));
      binding.platformDispatcher.localeTestValue = const Locale('pt', 'BR');
      expect(AppUtils.formatMoney(1234.56), contains(r'R$'));
      expect(AppUtils.formatMoney(1234.56), contains('1.234,56'));
    });
  });
}
