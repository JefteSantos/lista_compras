import 'package:flutter/material.dart';
import 'package:lista_compras/services/hive_service.dart';
import 'lista_compras.dart';
import 'item.dart';

class ListasProvider with ChangeNotifier {
  List<ListaCompras> _listas = [];
  bool _isLoading = false;

  List<ListaCompras> get listas => _listas;
  bool get isLoading => _isLoading;

  List<ListaCompras> get listasAtivas =>
      _listas.where((l) => !l.finalizada).toList();
  List<ListaCompras> get listasFinalizadas =>
      _listas.where((l) => l.finalizada).toList();

  ListasProvider() {
    carregarListas();
  }

  Future<void> carregarListas() async {
    _isLoading = true;
    notifyListeners();
    try {
      _listas = HiveService.obterTodasListasCompras();
      _listas.sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
    } catch (e) {
      debugPrint('Erro ao carregar listas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ListaCompras? getListaPorId(String id) {
    try {
      return _listas.firstWhere((lista) => lista.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> adicionarLista(ListaCompras lista) async {
    await HiveService.salvarListaCompras(lista);
    // Recarrega tudo para garantir ordem e consistência
    await carregarListas();
  }

  Future<void> atualizarLista(ListaCompras lista) async {
    await HiveService.salvarListaCompras(lista);
    notifyListeners();
  }

  Future<void> removerLista(String id) async {
    await HiveService.excluirListaCompras(id);
    await carregarListas();
  }

  Future<void> adicionarItem(ListaCompras lista, Item item) async {
    lista.adicionarItem(item);
    notifyListeners();
  }

  Future<void> atualizarItem(ListaCompras lista, Item item) async {
    lista.atualizarItem(item);
    notifyListeners();
  }

  Future<void> removerItem(ListaCompras lista, Item item) async {
    lista.removerItem(item);
    notifyListeners();
  }

  Future<void> alternarStatusItem(ListaCompras lista, Item item) async {
    final novoStatus = !item.comprado;
    final itemAtualizado = item.copyWith(
      comprado: novoStatus,
      dataCompra: novoStatus ? DateTime.now() : null,
    );
    lista.atualizarItem(itemAtualizado);
    notifyListeners();
  }
}
