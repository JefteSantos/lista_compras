import 'package:hive_flutter/hive_flutter.dart';
import '../models/item.dart';
import '../models/lista_compras.dart';

class HiveService {
  static const String _listaComprasBoxName = 'listas_compras';
  static const String _itemBoxName = 'itens';
  static const String _configBoxName = 'configuracoes';

  static Box<ListaCompras>? _listaComprasBox;
  static Box<Item>? _itemBox;
  static Box? _configBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ItemAdapter());
    Hive.registerAdapter(ListaComprasAdapter());
    _listaComprasBox = await Hive.openBox<ListaCompras>(_listaComprasBoxName);
    _itemBox = await Hive.openBox<Item>(_itemBoxName);
    _configBox = await Hive.openBox(_configBoxName);
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

  static Future<void> limparTodosDados() async {
    await listaComprasBox.clear();
    await itemBox.clear();
    await configBox.clear();
  }

  static Future<void> fecharBoxes() async {
    await _listaComprasBox?.close();
    await _itemBox?.close();
    await _configBox?.close();
  }

  static int get totalListas => listaComprasBox.length;
  static int get totalItens => itemBox.length;
  static int get listasAtivas => obterListasAtivas().length;
  static int get listasFinalizadas => obterListasFinalizadas().length;
}
