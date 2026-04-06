import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lista_compras/models/item.dart';
import 'package:lista_compras/models/lista_compras.dart';
import 'package:lista_compras/models/preco_historico.dart';
import 'package:lista_compras/services/hive_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late Box<ListaCompras> listaBox;
  late Box<Item> itemBox;
  late Box configBox;
  late Box<PrecoHistorico> historicoBox;

  setUpAll(() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ItemAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ListaComprasAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(PrecoHistoricoAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(PrecoEntradaAdapter());
    }
  });

  setUp(() async {
    listaBox = await Hive.openBox<ListaCompras>('integ_test_listas');
    itemBox = await Hive.openBox<Item>('integ_test_itens');
    configBox = await Hive.openBox('integ_test_config');
    historicoBox = await Hive.openBox<PrecoHistorico>('integ_test_historico');

    await HiveService.init(
      listaBox: listaBox,
      itemBox: itemBox,
      configBox: configBox,
      historicoBox: historicoBox,
    );
  });

  tearDown(() async {
    await listaBox.clear();
    await itemBox.clear();
    await configBox.clear();
    await historicoBox.clear();
    await listaBox.close();
    await itemBox.close();
    await configBox.close();
    await historicoBox.close();
  });

  group('HiveService Integration Tests', () {
    test('Deve salvar e obter uma lista de compras', () async {
      final lista = ListaCompras(
        id: 'lista-1',
        nome: 'Teste',
        dataCriacao: DateTime.now(),
      );

      await HiveService.salvarListaCompras(lista);
      final obtida = HiveService.obterListaCompras('lista-1');

      expect(obtida, isNotNull);
      expect(obtida!.nome, 'Teste');
    });

    test('Deve retornar null para lista inexistente', () {
      final obtida = HiveService.obterListaCompras('inexistente');
      expect(obtida, isNull);
    });

    test('Deve obter todas as listas', () async {
      await HiveService.salvarListaCompras(
        ListaCompras(
          id: 'lista-1',
          nome: 'Lista 1',
          dataCriacao: DateTime.now(),
        ),
      );
      await HiveService.salvarListaCompras(
        ListaCompras(
          id: 'lista-2',
          nome: 'Lista 2',
          dataCriacao: DateTime.now(),
        ),
      );

      final todas = HiveService.obterTodasListasCompras();
      expect(todas.length, 2);
    });

    test('Deve filtrar listas ativas', () async {
      final ativa = ListaCompras(
        id: '1',
        nome: 'Ativa',
        dataCriacao: DateTime.now(),
      );
      final finalizada = ListaCompras(
        id: '2',
        nome: 'Finalizada',
        dataCriacao: DateTime.now(),
      );
      finalizada.finalizarLista();

      await HiveService.salvarListaCompras(ativa);
      await HiveService.salvarListaCompras(finalizada);

      final ativas = HiveService.obterListasAtivas();
      expect(ativas.length, 1);
      expect(ativas.first.nome, 'Ativa');
    });

    test('Deve filtrar listas finalizadas', () async {
      final ativa = ListaCompras(
        id: '1',
        nome: 'Ativa',
        dataCriacao: DateTime.now(),
      );
      final finalizada = ListaCompras(
        id: '2',
        nome: 'Finalizada',
        dataCriacao: DateTime.now(),
      );
      finalizada.finalizarLista();

      await HiveService.salvarListaCompras(ativa);
      await HiveService.salvarListaCompras(finalizada);

      final finalizadas = HiveService.obterListasFinalizadas();
      expect(finalizadas.length, 1);
      expect(finalizadas.first.nome, 'Finalizada');
    });

    test('Deve excluir uma lista', () async {
      await HiveService.salvarListaCompras(
        ListaCompras(id: 'lista-1', nome: 'Teste', dataCriacao: DateTime.now()),
      );

      await HiveService.excluirListaCompras('lista-1');
      final obtida = HiveService.obterListaCompras('lista-1');

      expect(obtida, isNull);
    });

    test('Deve salvar e obter configuração', () async {
      await HiveService.salvarConfiguracao('chave', 'valor');
      final valor = HiveService.obterConfiguracao<String>('chave');

      expect(valor, 'valor');
    });

    test('Deve remover configuração', () async {
      await HiveService.salvarConfiguracao('chave', 'valor');
      await HiveService.removerConfiguracao('chave');
      final valor = HiveService.obterConfiguracao<String>('chave');

      expect(valor, isNull);
    });

    test('Deve limpar todos os dados', () async {
      await HiveService.salvarListaCompras(
        ListaCompras(id: '1', nome: 'L1', dataCriacao: DateTime.now()),
      );
      await HiveService.salvarItem(
        Item(id: 'i1', nome: 'Item', dataCriacao: DateTime.now()),
      );
      await HiveService.salvarConfiguracao('chave', 'valor');

      await HiveService.limparTodosDados();

      expect(HiveService.totalListas, 0);
      expect(HiveService.totalItens, 0);
    });
  });
}
