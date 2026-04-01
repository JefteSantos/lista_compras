import 'package:flutter/material.dart';
import 'package:lista_compras/services/hive_service.dart';
import 'package:lista_compras/services/home_widget_service.dart';
import 'package:lista_compras/models/preco_historico.dart';
import 'lista_compras.dart';
import 'item.dart';
import '../services/drive_backup_service.dart';

class ListasProvider with ChangeNotifier {
  List<ListaCompras> _listas = [];
  bool _isLoading = false;
  
  // Backup state
  BackupStatus _backupStatus = BackupStatus.idle;
  String? _lastBackupError;
  DateTime? _lastBackupDate;

  List<ListaCompras> get listas => _listas;
  bool get isLoading => _isLoading;
  BackupStatus get backupStatus => _backupStatus;
  String? get lastBackupError => _lastBackupError;
  DateTime? get lastBackupDate => _lastBackupDate;

  List<ListaCompras> get listasAtivas =>
      _listas.where((l) => !l.finalizada).toList();
  List<ListaCompras> get listasFinalizadas =>
      _listas.where((l) => l.finalizada).toList();

  ListasProvider() {
    _lastBackupDate = HiveService.obterConfiguracao<String>('ultimo_backup') != null 
        ? DateTime.parse(HiveService.obterConfiguracao<String>('ultimo_backup')!)
        : null;
    carregarListas();
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
    final historico = box.get(nomeNormalizado) ?? PrecoHistorico(nomeItem: nome.trim());
    
    historico.adicionarEntrada(preco, DateTime.now());
    await box.put(nomeNormalizado, historico);
  }

  Future<void> finalizarLista(ListaCompras lista) async {
    lista.finalizarLista();
    
    // Salva os preços dos itens marcados como comprados no histórico
    for (var item in lista.itens) {
      if (item.comprado && item.preco != null && item.preco! > 0) {
        await adicionarPrecoAoHistorico(item.nome, item.preco!);
      }
    }
    
    await HiveService.salvarListaCompras(lista);
    notifyListeners();
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
      // Atualiza o widget da tela inicial com os dados mais recentes
      HomeWidgetService.atualizar(_listas);
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
    // Bug 1 fix: sincroniza o objeto em memória para evitar estado defasado
    final index = _listas.indexWhere((l) => l.id == lista.id);
    if (index != -1) _listas[index] = lista;
    notifyListeners();
  }

  Future<void> removerLista(String id) async {
    await HiveService.excluirListaCompras(id);
    await carregarListas();
  }

  Future<void> adicionarItem(ListaCompras lista, Item item) async {
    lista.adicionarItem(item);
    // Bug 2 fix: garante persistência explícita, independente de isInBox
    await HiveService.salvarListaCompras(lista);
    notifyListeners();
  }

  Future<void> atualizarItem(ListaCompras lista, Item item) async {
    lista.atualizarItem(item);
    // Bug 2 fix: garante persistência explícita, independente de isInBox
    await HiveService.salvarListaCompras(lista);
    notifyListeners();
  }

  Future<void> removerItem(ListaCompras lista, Item item) async {
    lista.removerItem(item);
    // Bug 2 fix: garante persistência explícita, independente de isInBox
    await HiveService.salvarListaCompras(lista);
    notifyListeners();
  }

  Future<void> alternarStatusItem(ListaCompras lista, Item item) async {
    final novoStatus = !item.comprado;
    final itemAtualizado = item.copyWith(
      comprado: novoStatus,
      dataCompra: novoStatus ? DateTime.now() : null,
    );
    lista.atualizarItem(itemAtualizado);
    // Bug 2 fix: garante persistência explícita, independente de isInBox
    await HiveService.salvarListaCompras(lista);
    notifyListeners();
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
      for (final lista in novasListas) {
        if (!substituir && _listas.any((l) => l.id == lista.id)) continue;
        await HiveService.salvarListaCompras(lista);
      }
      await carregarListas();
    } catch (e) {
      debugPrint('Erro ao importar listas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
}

enum BackupStatus { idle, loading, success, error }
