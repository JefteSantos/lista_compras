import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:lista_compras/utils/app_utils.dart';

import '../models/lista_compras.dart';

/// Serviço responsável por enviar dados para o widget da tela inicial.
/// Usa o pacote home_widget como ponte entre Flutter e o AppWidget nativo.
class HomeWidgetService {
  HomeWidgetService._();

  static const _appGroupId = 'com.example.lista_compras';
  static const _qualifiedAndroidName =
      'com.example.lista_compras.ListaComprasWidget';

  /// Inicializa o home_widget. Deve ser chamado no main().
  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Atualiza o widget com os dados mais recentes das listas.
  static Future<void> atualizar(List<ListaCompras> listas) async {
    try {
      final ativas = listas.where((l) => !l.finalizada).toList();
      final totalItens = ativas.fold<int>(
        0,
        (sum, l) => sum + l.itens.where((i) => !i.comprado).length,
      );
      final totalValor = ativas.fold<double>(
        0,
        (sum, l) => sum + (l.precoTotal - l.precoComprado),
      );

      await Future.wait([
        HomeWidget.saveWidgetData<int>('listas_ativas', ativas.length),
        HomeWidget.saveWidgetData<int>('itens_pendentes', totalItens),
        HomeWidget.saveWidgetData<String>(
          'total_valor',
          AppUtils.formatMoney(totalValor),
        ),
        HomeWidget.saveWidgetData<String>(
          'ultima_atualizacao',
          _formatHora(DateTime.now()),
        ),
      ]);

      await HomeWidget.updateWidget(
        androidName: _qualifiedAndroidName,
      );

      debugPrint(
        '[HomeWidget] Atualizado — '
        '${ativas.length} listas | $totalItens itens | ${AppUtils.formatMoney(totalValor)}',
      );
    } catch (e) {
      debugPrint('[HomeWidget] Erro ao atualizar: $e');
    }
  }

  static String _formatHora(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
