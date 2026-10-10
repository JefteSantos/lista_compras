import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:lista_compras/services/hive_service.dart';
import 'package:lista_compras/services/home_widget_service.dart';
import 'package:lista_compras/models/preco_historico.dart';
import 'package:uuid/uuid.dart';

import 'lista_compras.dart';
import 'item.dart';
import '../services/drive_backup_service.dart';
import '../utils/list_summary.dart';

class ListasProvider with ChangeNotifier {
  List<ListaCompras> _listas = [];
  final Map<String, ListaCompras> _listasPorId = {};
  List<ListaCompras>? _listasAtivas;
  List<ListaCompras>? _listasFinalizadas;
  Map<String, String>? _ultimasCategorias;
  final Map<String, ListSummary> _resumosPorId = {};
  int _dataRevision = 0;
  bool _isLoading = false;

  // Backup state
  BackupStatus _backupStatus = BackupStatus.idle;
  String? _lastBackupError;
  DateTime? _lastBackupDate;

  List<ListaCompras> get listas => UnmodifiableListView(_listas);
  int get dataRevision => _dataRevision;
  bool get isLoading => _isLoading;
  BackupStatus get backupStatus => _backupStatus;
  String? get lastBackupError => _lastBackupError;
  DateTime? get lastBackupDate => _lastBackupDate;

  List<ListaCompras> get listasAtivas =>
      _listasAtivas ??= List.unmodifiable(_listas.where((l) => !l.finalizada));
  List<ListaCompras> get listasFinalizadas => _listasFinalizadas ??=
      List.unmodifiable(_listas.where((l) => l.finalizada));

  ListasProvider() {
    final ultimoBackup = HiveService.obterConfiguracao<String>('ultimo_backup');
    _lastBackupDate = ultimoBackup == null
        ? null
        : DateTime.tryParse(ultimoBackup);
    carregarListas();
  }

  void _invalidarDados({
    String? listaId,
    bool listasAlteradas = true,
    bool categoriasAlteradas = true,
  }) {
    if (listasAlteradas) {
      _listasAtivas = null;
      _listasFinalizadas = null;
    }
    if (categoriasAlteradas) _ultimasCategorias = null;
    if (listaId == null) {
      _resumosPorId.clear();
    } else {
      _resumosPorId.remove(listaId);
    }
    _dataRevision++;
  }

  void _recarregarDados() {
    _listas = HiveService.obterTodasListasCompras()
      ..sort((a, b) => b.dataCriacao.compareTo(a.dataCriacao));
    _listasPorId
      ..clear()
      ..addEntries(_listas.map((lista) => MapEntry(lista.id, lista)));
    _invalidarDados();
  }

  Future<void> _salvarLista(ListaCompras lista) {
    // O modelo já mudou: um rebuild durante o await não pode ler totais antigos.
    _resumosPorId.remove(lista.id);
    return HiveService.salvarListaCompras(lista);
  }

  void _sincronizarLista(
    ListaCompras lista, {
    bool reordenar = false,
    bool listasAlteradas = true,
    bool categoriasAlteradas = true,
  }) {
    final anterior = _listasPorId[lista.id];
    if (anterior == null || reordenar) {
      if (anterior != null) _listas.remove(anterior);
      // Mantém a ordem sem reler a caixa ou ordenar todas as listas.
      var inicio = 0;
      var fim = _listas.length;
      while (inicio < fim) {
        final meio = (inicio + fim) ~/ 2;
        if (_listas[meio].dataCriacao.isAfter(lista.dataCriacao)) {
          inicio = meio + 1;
        } else {
          fim = meio;
        }
      }
      _listas.insert(inicio, lista);
    } else if (!identical(anterior, lista)) {
      _listas[_listas.indexOf(anterior)] = lista;
    }
    _listasPorId[lista.id] = lista;
    _invalidarDados(
      listaId: lista.id,
      listasAlteradas: listasAlteradas || !identical(anterior, lista),
      categoriasAlteradas: categoriasAlteradas || !identical(anterior, lista),
    );
    notifyListeners();
  }

  /// Busca o último preço registrado para um item pelo nome
  double? obterUltimoPreco(String nome) {
    if (nome.trim().isEmpty) return null;
    final nomeNormalizado = nome.trim().toLowerCase();
    final historico = HiveService.historicoPrecosBox.get(nomeNormalizado);
    return historico?.ultimoPreco;
  }

  /// Busca o histórico completo para um item
  PrecoHistorico? obterHistorico(String nome) {
    if (nome.trim().isEmpty) return null;
    final nomeNormalizado = nome.trim().toLowerCase();
    return HiveService.historicoPrecosBox.get(nomeNormalizado);
  }

  Future<void> adicionarPrecoAoHistorico(String nome, double preco) async {
    if (nome.trim().isEmpty || preco <= 0) return;

    final nomeNormalizado = nome.trim().toLowerCase();
    final box = HiveService.historicoPrecosBox;

    // Busca ou cria o histórico para este item
    final historico =
        box.get(nomeNormalizado) ?? PrecoHistorico(nomeItem: nome.trim());

    historico.adicionarEntrada(preco, DateTime.now());
    await box.put(nomeNormalizado, historico);
  }

  Future<void> finalizarLista(ListaCompras lista) async {
    final agora = DateTime.now();
    lista.finalizada = true;
    lista.dataFinalizacao = agora;

    // Agrupa os históricos para realizar uma única gravação na caixa.
    final historicos = <String, PrecoHistorico>{};
    final box = HiveService.historicoPrecosBox;
    for (final item in lista.itens) {
      final nome = item.nome.trim();
      if (!item.comprado || nome.isEmpty || (item.preco ?? 0) <= 0) continue;
      final chave = nome.toLowerCase();
      final historico = historicos.putIfAbsent(
        chave,
        () => box.get(chave) ?? PrecoHistorico(nomeItem: nome),
      );
      historico.adicionarEntrada(item.preco!, agora);
    }
    if (historicos.isNotEmpty) await box.putAll(historicos);
    await _salvarLista(lista);
    _sincronizarLista(lista, categoriasAlteradas: false);
  }

  Future<void> reabrirLista(ListaCompras lista) async {
    lista.finalizada = false;
    lista.dataFinalizacao = null;
    await _salvarLista(lista);
    _sincronizarLista(lista, categoriasAlteradas: false);
  }

  Future<void> carregarListas() async {
    _isLoading = true;
    notifyListeners();
    try {
      _recarregarDados();
    } catch (e) {
      debugPrint('Erro ao carregar listas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      // Atualiza o widget da tela inicial com os dados mais recentes
      unawaited(HomeWidgetService.atualizar(_listas));
    }
  }

  ListaCompras? getListaPorId(String id) => _listasPorId[id];

  /// Reutiliza os totais até a próxima alteração desta lista pelo provider.
  /// Listas externas ainda não cadastradas são calculadas sem guardar cache.
  ListSummary obterResumoLista(ListaCompras lista) {
    if (!identical(_listasPorId[lista.id], lista)) {
      return ListSummary.fromItems(lista.itens);
    }
    return _resumosPorId.putIfAbsent(
      lista.id,
      () => ListSummary.fromItems(lista.itens),
    );
  }

  Future<void> adicionarLista(ListaCompras lista) async {
    await _salvarLista(lista);
    _sincronizarLista(lista, reordenar: true);
    unawaited(HomeWidgetService.atualizar(_listas));
  }

  Future<void> atualizarLista(ListaCompras lista) async {
    await _salvarLista(lista);
    _sincronizarLista(lista, reordenar: true);
  }

  Future<void> removerLista(String id) async {
    await HiveService.excluirListaCompras(id);
    final lista = _listasPorId.remove(id);
    if (lista == null) return;
    _listas.remove(lista);
    _invalidarDados(listaId: id);
    notifyListeners();
    unawaited(HomeWidgetService.atualizar(_listas));
  }

  /// Cria uma cópia da lista com novos IDs e itens desmarcados.
  Future<ListaCompras> duplicarLista(ListaCompras original) async {
    final novaLista = ListaCompras(
      id: const Uuid().v4(),
      nome: '${original.nome} (cópia)',
      descricao: original.descricao,
      dataCriacao: DateTime.now(),
      itens: original.itens
          .map(
            (item) => Item(
              id: const Uuid().v4(),
              nome: item.nome,
              quantidade: item.quantidade,
              preco: item.preco,
              observacoes: item.observacoes,
              dataCriacao: DateTime.now(),
              categoria: item.categoria,
            ),
          )
          .toList(),
    );
    await adicionarLista(novaLista);
    return novaLista;
  }

  Future<void> adicionarItem(ListaCompras lista, Item item) async {
    // Os métodos do modelo também salvam; aqui o provider controla o único put.
    lista.itens.add(item);
    await _salvarLista(lista);
    _sincronizarLista(
      lista,
      listasAlteradas: false,
      categoriasAlteradas: _possuiCategoria(item),
    );
  }

  Future<void> atualizarItem(ListaCompras lista, Item item) async {
    final index = lista.itens.indexWhere(
      (existente) => existente.id == item.id,
    );
    if (index == -1) return;
    final anterior = lista.itens[index];
    final categoriasAlteradas =
        identical(anterior, item) ||
        ((_possuiCategoria(anterior) || _possuiCategoria(item)) &&
            (anterior.nome != item.nome ||
                anterior.categoria != item.categoria));
    lista.itens[index] = item;
    await _salvarLista(lista);
    _sincronizarLista(
      lista,
      listasAlteradas: false,
      categoriasAlteradas: categoriasAlteradas,
    );
  }

  Future<void> removerItem(ListaCompras lista, Item item) async {
    final index = lista.itens.indexWhere(
      (existente) => existente.id == item.id,
    );
    if (index == -1) return;
    final removido = lista.itens.removeAt(index);
    await _salvarLista(lista);
    _sincronizarLista(
      lista,
      listasAlteradas: false,
      categoriasAlteradas: _possuiCategoria(removido),
    );
  }

  static bool _possuiCategoria(Item item) =>
      item.categoria != null && item.categoria!.isNotEmpty;

  Future<void> alternarStatusItem(ListaCompras lista, Item item) async {
    final novoStatus = !item.comprado;
    final itemAtualizado = item.copyWith(
      comprado: novoStatus,
      dataCompra: novoStatus ? DateTime.now() : null,
    );
    itemAtualizado.dataCompra = novoStatus ? itemAtualizado.dataCompra : null;
    await atualizarItem(lista, itemAtualizado);
  }

  /// Importa listas externas (do Drive ou de código de compartilhamento).
  /// [substituir] = true apaga tudo antes de importar.
  /// [substituir] = false mescla, pulando IDs já existentes.
  Future<void> importarListas(
    List<ListaCompras> novasListas, {
    bool substituir = false,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (substituir) {
        await HiveService.limparTodosDados();
      }
      await HiveService.salvarListasCompras(
        novasListas.where(
          (lista) => substituir || !_listasPorId.containsKey(lista.id),
        ),
      );
      _recarregarDados();
    } catch (e) {
      debugPrint('Erro ao importar listas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      unawaited(HomeWidgetService.atualizar(_listas));
    }
  }

  /// Realiza backup manual e atualiza o estado visual
  Future<void> realizarBackupNoDrive() async {
    _backupStatus = BackupStatus.loading;
    _lastBackupError = null;
    notifyListeners();

    try {
      await DriveBackupService.uploadBackup(_listas);
      _backupStatus = BackupStatus.success;
      _lastBackupDate = DateTime.now();
      notifyListeners();
    } catch (e) {
      _backupStatus = BackupStatus.error;
      _lastBackupError = e.toString();
      notifyListeners();
    }
  }

  /// Retorna a última categoria usada para um item com este nome,
  /// procurando em todas as listas (mais recentes primeiro).
  /// Retorna null se nunca foi categorizado.
  String? obterUltimaCategoria(String nomeItem) {
    final nomeNorm = nomeItem.trim().toLowerCase();
    if (nomeNorm.isEmpty) return null;

    // Constrói o índice somente na primeira consulta após uma alteração.
    if (_ultimasCategorias == null) {
      final categorias = <String, String>{};
      for (final lista in _listas) {
        for (final item in lista.itens) {
          final categoria = item.categoria;
          if (categoria != null && categoria.isNotEmpty) {
            categorias.putIfAbsent(
              item.nome.trim().toLowerCase(),
              () => categoria,
            );
          }
        }
      }
      _ultimasCategorias = categorias;
    }
    return _ultimasCategorias![nomeNorm];
  }
}

enum BackupStatus { idle, loading, success, error }
