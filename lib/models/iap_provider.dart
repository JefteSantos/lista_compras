import 'package:flutter/material.dart';
import '../services/hive_service.dart';

class IapProvider extends ChangeNotifier {
  bool _isPro = false;

  /// Retorna verdadeiro se o usuário tiver comprado a versão PRO.
  bool get isPro => _isPro;

  IapProvider() {
    _init();
  }

  void _init() {
    // Carrega o status do banco local (Hive)
    _isPro = HiveService.obterConfiguracao<bool>('usuario_pro') ?? false;
    notifyListeners();
  }

  /// COMPRA SIMULADA (MOCK)
  /// Simula a comunicação com o Google Pay. 
  /// Quando você tiver a conta do Google, nós trocaremos o conteúdo desta função
  /// pela chamada oficial: InAppPurchase.instance.buyNonConsumable(...)
  Future<bool> comprarProMock() async {
    try {
      // Simula o delay da janela de cartão de crédito do Google abrindo
      await Future.delayed(const Duration(seconds: 2));
      
      // Sucesso! Salva no banco de dados e notifica o app
      await HiveService.salvarConfiguracao('usuario_pro', true);
      _isPro = true;
      notifyListeners();
      return true; // Compra efetuada com sucesso
    } catch (e) {
      return false;
    }
  }

  /// RESTAURAR COMPRAS SIMULADO
  Future<bool> restaurarComprasMock() async {
    await Future.delayed(const Duration(seconds: 1));
    // Como é um mock, ele só reavalia o status atual.
    // Na versão real, ele perguntaria pro Google se há um recibo antigo.
    return _isPro;
  }
}
