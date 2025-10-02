import 'package:flutter/material.dart';
import 'lista_compras.dart';

class ListasProvider with ChangeNotifier {
  final List<ListaCompras> _listas = [];

  List<ListaCompras> get listas => _listas;

  ListaCompras? getListaPorId(String id) {
    try {
      return _listas.firstWhere((lista) => lista.id == id);
    } catch (e) {
      return null;
    }
  }

  void adicionarLista(ListaCompras lista) {
    _listas.add(lista);
    notifyListeners();
  }

  // Outros métodos para remover/atualizar listas...
}