import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../models/item.dart';
import '../models/lista_compras.dart';
import '../models/preco_historico.dart';
import '../models/categoria_item.dart';
import '../hive_registrar.g.dart';

class HiveService {
  static const _listaComprasBoxName = 'listas_compras';
  static const _itemBoxName = 'itens';
  static const _configBoxName = 'configuracoes';
  static const _historicoPrecosBoxName = 'historico_precos';
  static const _categoriasBoxName = 'categorias';

  static Box<ListaCompras>? _listaComprasBox;
  static Box<Item>? _itemBox;
  static Box? _configBox;
  static Box<PrecoHistorico>? _historicoPrecosBox;
  static Box<CategoriaItem>? _categoriasBox;

  static Future<void> init({
    Box<ListaCompras>? listaBox,
    Box<Item>? itemBox,
    Box? configBox,
    Box<PrecoHistorico>? historicoBox,
    Box<CategoriaItem>? categoriasBox,
  }) async {
    if (listaBox != null &&
        itemBox != null &&
        configBox != null &&
        historicoBox != null) {
      _listaComprasBox = listaBox;
      _itemBox = itemBox;
      _configBox = configBox;
      _historicoPrecosBox = historicoBox;
      _categoriasBox = categoriasBox;
      return;
    }

    await Hive.initFlutter();
    Hive.registerAdapters();

    // As caixas são independentes; suas leituras de disco podem se sobrepor.
    await Future.wait([
      Hive.openBox<ListaCompras>(_listaComprasBoxName).then((box) {
        _listaComprasBox = box;
      }),
      Hive.openBox<Item>(_itemBoxName).then((box) {
        _itemBox = box;
      }),
      Hive.openBox(_configBoxName).then((box) {
        _configBox = box;
      }),
      Hive.openBox<PrecoHistorico>(_historicoPrecosBoxName).then((box) {
        _historicoPrecosBox = box;
      }),
      Hive.openBox<CategoriaItem>(_categoriasBoxName).then((box) {
        _categoriasBox = box;
      }),
    ]);
  }

  static Box<ListaCompras> get listaComprasBox {
    if (_listaComprasBox == null) {
      throw Exception(
        'Hive não foi inicializado. Chame HiveService.init() primeiro.',
      );
    }
    return _listaComprasBox!;
  }

  static Box<Item> get itemBox {
    if (_itemBox == null) {
      throw Exception(
        'Hive não foi inicializado. Chame HiveService.init() primeiro.',
      );
    }
    return _itemBox!;
  }

  static Box get configBox {
    if (_configBox == null) {
      throw Exception(
        'Hive não foi inicializado. Chame HiveService.init() primeiro.',
      );
    }
    return _configBox!;
  }

  static Future<void> salvarListaCompras(ListaCompras lista) async {
    await listaComprasBox.put(lista.id, lista);
  }

  static Future<void> salvarListasCompras(Iterable<ListaCompras> listas) async {
    final porId = {for (final lista in listas) lista.id: lista};
    if (porId.isNotEmpty) await listaComprasBox.putAll(porId);
  }

  static ListaCompras? obterListaCompras(String id) {
    return listaComprasBox.get(id);
  }

  static List<ListaCompras> obterTodasListasCompras() {
    return listaComprasBox.values.toList();
  }

  static List<ListaCompras> obterListasAtivas() {
    return listaComprasBox.values.where((lista) => !lista.finalizada).toList();
  }

  static List<ListaCompras> obterListasFinalizadas() {
    return listaComprasBox.values.where((lista) => lista.finalizada).toList();
  }

  static Future<void> excluirListaCompras(String id) async {
    await listaComprasBox.delete(id);
  }

  static Future<void> salvarItem(Item item) async {
    await itemBox.put(item.id, item);
  }

  static Item? obterItem(String id) {
    return itemBox.get(id);
  }

  static List<Item> obterTodosItens() {
    return itemBox.values.toList();
  }

  static Future<void> excluirItem(String id) async {
    await itemBox.delete(id);
  }

  static Future<void> salvarConfiguracao(String chave, dynamic valor) async {
    await configBox.put(chave, valor);
  }

  static T? obterConfiguracao<T>(String chave) {
    return configBox.get(chave);
  }

  static Future<void> removerConfiguracao(String chave) async {
    await configBox.delete(chave);
  }

  static Box<PrecoHistorico> get historicoPrecosBox {
    if (_historicoPrecosBox == null) {
      throw Exception(
        'Hive não foi inicializado. Chame HiveService.init() primeiro.',
      );
    }
    return _historicoPrecosBox!;
  }

  static Future<void> limparTodosDados() async {
    await Future.wait([
      listaComprasBox.clear(),
      itemBox.clear(),
      configBox.clear(),
      if (_historicoPrecosBox != null) _historicoPrecosBox!.clear(),
    ]);
  }

  static Future<void> fecharBoxes() async {
    await Future.wait([
      if (_listaComprasBox != null) _listaComprasBox!.close(),
      if (_itemBox != null) _itemBox!.close(),
      if (_configBox != null) _configBox!.close(),
      if (_historicoPrecosBox != null) _historicoPrecosBox!.close(),
      if (_categoriasBox != null) _categoriasBox!.close(),
    ]);
  }

  static Box<CategoriaItem> get categoriasBox {
    if (_categoriasBox == null) {
      throw Exception(
        'Hive não foi inicializado. Chame HiveService.init() primeiro.',
      );
    }
    return _categoriasBox!;
  }

  static int get totalListas => listaComprasBox.length;
  static int get totalItens => itemBox.length;
  static int get listasAtivas =>
      listaComprasBox.values.where((lista) => !lista.finalizada).length;
  static int get listasFinalizadas =>
      listaComprasBox.values.where((lista) => lista.finalizada).length;
}
