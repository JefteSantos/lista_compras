import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lista_compras/models/item.dart';
import 'package:lista_compras/models/lista_compras.dart';
import 'package:lista_compras/models/listas_provider.dart';
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
    listaBox = await Hive.openBox<ListaCompras>('provider_integ_test_listas');
    itemBox = await Hive.openBox<Item>('provider_integ_test_itens');
    configBox = await Hive.openBox('provider_integ_test_config');
    historicoBox = await Hive.openBox<PrecoHistorico>(
      'provider_integ_test_historico',
    );

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

  group('ListasProvider Integration Tests', () {
    test('Deve carregar listas ao iniciar', () async {
      await HiveService.salvarListaCompras(
        ListaCompras(id: 'lista-1', nome: 'Teste', dataCriacao: DateTime.now()),
      );

      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.listas.length, 1);
      expect(provider.listas.first.nome, 'Teste');
    });

    test('Deve retornar listas ativas', () async {
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

      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.listasAtivas.length, 1);
      expect(provider.listasAtivas.first.nome, 'Ativa');
    });

    test('Deve retornar listas finalizadas', () async {
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

      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      expect(provider.listasFinalizadas.length, 1);
      expect(provider.listasFinalizadas.first.nome, 'Finalizada');
    });

    test('Deve adicionar nova lista', () async {
      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final novaLista = ListaCompras(
        id: 'nova-lista',
        nome: 'Nova Lista',
        dataCriacao: DateTime.now(),
      );

      await provider.adicionarLista(novaLista);

      expect(provider.listas.any((l) => l.id == 'nova-lista'), isTrue);
    });

    test('Deve remover lista', () async {
      await HiveService.salvarListaCompras(
        ListaCompras(id: 'lista-1', nome: 'Teste', dataCriacao: DateTime.now()),
      );

      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.removerLista('lista-1');

      expect(provider.listas.any((l) => l.id == 'lista-1'), isFalse);
    });

    test('Deve adicionar item a uma lista', () async {
      final lista = ListaCompras(
        id: 'lista-1',
        nome: 'Teste',
        dataCriacao: DateTime.now(),
      );
      await HiveService.salvarListaCompras(lista);

      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final item = Item(
        id: 'item-1',
        nome: 'Arroz',
        quantidade: 2,
        dataCriacao: DateTime.now(),
      );
      await provider.adicionarItem(lista, item);

      final listaAtualizada = provider.getListaPorId('lista-1');
      expect(listaAtualizada?.itens.length, 1);
      expect(listaAtualizada?.itens.first.nome, 'Arroz');
    });

    test('Deve atualizar item em uma lista', () async {
      final lista = ListaCompras(
        id: 'lista-1',
        nome: 'Teste',
        dataCriacao: DateTime.now(),
      );
      lista.adicionarItem(
        Item(
          id: 'item-1',
          nome: 'Arroz',
          quantidade: 1,
          dataCriacao: DateTime.now(),
        ),
      );
      await HiveService.salvarListaCompras(lista);

      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final itemAtualizado = Item(
        id: 'item-1',
        nome: 'Arroz Integral',
        quantidade: 2,
        dataCriacao: DateTime.now(),
      );
      await provider.atualizarItem(lista, itemAtualizado);

      final listaAtualizada = provider.getListaPorId('lista-1');
      expect(listaAtualizada?.itens.first.nome, 'Arroz Integral');
    });

    test('Deve remover item de uma lista', () async {
      final lista = ListaCompras(
        id: 'lista-1',
        nome: 'Teste',
        dataCriacao: DateTime.now(),
      );
      lista.adicionarItem(
        Item(
          id: 'item-1',
          nome: 'Arroz',
          quantidade: 1,
          dataCriacao: DateTime.now(),
        ),
      );
      await HiveService.salvarListaCompras(lista);

      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final item = lista.itens.first;
      await provider.removerItem(lista, item);

      final listaAtualizada = provider.getListaPorId('lista-1');
      expect(listaAtualizada?.itens.length, 0);
    });

    test('Deve alternar status do item', () async {
      final lista = ListaCompras(
        id: 'lista-1',
        nome: 'Teste',
        dataCriacao: DateTime.now(),
      );
      lista.adicionarItem(
        Item(
          id: 'item-1',
          nome: 'Arroz',
          quantidade: 1,
          dataCriacao: DateTime.now(),
        ),
      );
      await HiveService.salvarListaCompras(lista);

      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final item = lista.itens.first;
      await provider.alternarStatusItem(lista, item);

      final listaAtualizada = provider.getListaPorId('lista-1');
      expect(listaAtualizada?.itens.first.comprado, isTrue);
    });

    test('Deve finalizar lista e salvar histórico de preços', () async {
      final lista = ListaCompras(
        id: 'lista-1',
        nome: 'Teste',
        dataCriacao: DateTime.now(),
      );
      lista.adicionarItem(
        Item(
          id: 'item-1',
          nome: 'Arroz',
          quantidade: 1,
          preco: 10.0,
          dataCriacao: DateTime.now(),
        ),
      );
      lista.itens.first.comprado = true;
      await HiveService.salvarListaCompras(lista);

      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.finalizarLista(lista);

      final listaAtualizada = provider.getListaPorId('lista-1');
      expect(listaAtualizada?.finalizada, isTrue);

      final historico = provider.obterHistorico('Arroz');
      expect(historico, isNotNull);
    });

    test('Deve obter lista por ID', () async {
      await HiveService.salvarListaCompras(
        ListaCompras(id: 'lista-1', nome: 'Teste', dataCriacao: DateTime.now()),
      );

      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final lista = provider.getListaPorId('lista-1');
      expect(lista, isNotNull);
      expect(lista?.nome, 'Teste');
    });

    test('Deve retornar null para ID inexistente', () async {
      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final lista = provider.getListaPorId('inexistente');
      expect(lista, isNull);
    });

    test('Deve importar listas substituindo existentes', () async {
      await HiveService.salvarListaCompras(
        ListaCompras(id: '1', nome: 'Original', dataCriacao: DateTime.now()),
      );

      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final novasListas = [
        ListaCompras(id: '2', nome: 'Nova 1', dataCriacao: DateTime.now()),
        ListaCompras(id: '3', nome: 'Nova 2', dataCriacao: DateTime.now()),
      ];

      await provider.importarListas(novasListas, substituir: true);

      expect(provider.listas.length, 2);
      expect(provider.listas.any((l) => l.nome == 'Nova 1'), isTrue);
    });

    test('Deve importar listas mesclando com existentes', () async {
      await HiveService.salvarListaCompras(
        ListaCompras(id: '1', nome: 'Original', dataCriacao: DateTime.now()),
      );

      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      final novasListas = [
        ListaCompras(id: '2', nome: 'Nova', dataCriacao: DateTime.now()),
      ];

      await provider.importarListas(novasListas, substituir: false);

      expect(provider.listas.length, 2);
    });

    test('Deve salvar último preço no histórico', () async {
      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.adicionarPrecoAoHistorico('Arroz', 10.50);

      final historico = provider.obterHistorico('Arroz');
      expect(historico, isNotNull);
      expect(historico?.ultimoPreco, 10.50);
    });

    test('Deve obter último preço do histórico', () async {
      final provider = ListasProvider();
      await Future.delayed(const Duration(milliseconds: 100));

      await provider.adicionarPrecoAoHistorico('Feijao', 8.00);
      await provider.adicionarPrecoAoHistorico('Feijao', 9.00);

      final preco = provider.obterUltimoPreco('Feijao');
      expect(preco, 9.00);
    });
  });
}
