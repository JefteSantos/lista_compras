import 'package:flutter_test/flutter_test.dart';
import 'package:lista_compras/models/lista_compras.dart';
import 'package:lista_compras/models/item.dart';

void main() {
  group('ListaCompras Model Tests', () {
    test('deve criar uma lista vazia corretamente', () {
      final lista = ListaCompras(
        id: '1',
        nome: 'Supermercado',
        dataCriacao: DateTime.now(),
      );

      expect(lista.id, '1');
      expect(lista.nome, 'Supermercado');
      expect(lista.itens, isEmpty);
      expect(lista.finalizada, false);
      expect(lista.totalItens, 0);
      expect(lista.precoTotal, 0.0);
    });

    test('deve adicionar item corretamente', () {
      final lista = ListaCompras(
        id: '1',
        nome: 'Supermercado',
        dataCriacao: DateTime.now(),
      );

      final item = Item(
        id: 'item1',
        nome: 'Arroz',
        quantidade: 2,
        preco: 10.0,
        dataCriacao: DateTime.now(),
      );

      lista.adicionarItem(item);

      expect(lista.itens.length, 1);
      expect(lista.totalItens, 1);
      expect(lista.precoTotal, 20.0);
    });

    test('deve calcular preço total corretamente', () {
      final lista = ListaCompras(
        id: '1',
        nome: 'Supermercado',
        dataCriacao: DateTime.now(),
      );

      lista.adicionarItem(
        Item(
          id: 'item1',
          nome: 'Arroz',
          quantidade: 2,
          preco: 10.0,
          dataCriacao: DateTime.now(),
        ),
      );

      lista.adicionarItem(
        Item(
          id: 'item2',
          nome: 'Feijão',
          quantidade: 1,
          preco: 8.0,
          dataCriacao: DateTime.now(),
        ),
      );

      expect(lista.precoTotal, 28.0);
    });

    test('deve calcular preço comprado corretamente', () {
      final lista = ListaCompras(
        id: '1',
        nome: 'Supermercado',
        dataCriacao: DateTime.now(),
      );

      final item1 = Item(
        id: 'item1',
        nome: 'Arroz',
        quantidade: 2,
        preco: 10.0,
        dataCriacao: DateTime.now(),
        comprado: true,
      );

      final item2 = Item(
        id: 'item2',
        nome: 'Feijão',
        quantidade: 1,
        preco: 8.0,
        dataCriacao: DateTime.now(),
        comprado: false,
      );

      lista.adicionarItem(item1);
      lista.adicionarItem(item2);

      expect(lista.precoComprado, 20.0);
      expect(lista.itensComprados, 1);
    });

    test('deve remover item corretamente', () {
      final lista = ListaCompras(
        id: '1',
        nome: 'Supermercado',
        dataCriacao: DateTime.now(),
      );

      final item = Item(
        id: 'item1',
        nome: 'Arroz',
        quantidade: 2,
        preco: 10.0,
        dataCriacao: DateTime.now(),
      );

      lista.adicionarItem(item);
      expect(lista.itens.length, 1);

      lista.removerItem(item);
      expect(lista.itens.length, 0);
    });

    test('deve atualizar item corretamente', () {
      final lista = ListaCompras(
        id: '1',
        nome: 'Supermercado',
        dataCriacao: DateTime.now(),
      );

      final item = Item(
        id: 'item1',
        nome: 'Arroz',
        quantidade: 2,
        preco: 10.0,
        dataCriacao: DateTime.now(),
      );

      lista.adicionarItem(item);

      final itemAtualizado = item.copyWith(nome: 'Arroz Integral', preco: 12.0);

      lista.atualizarItem(itemAtualizado);

      expect(lista.itens.first.nome, 'Arroz Integral');
      expect(lista.itens.first.preco, 12.0);
      expect(lista.precoTotal, 24.0);
    });

    test('deve finalizar lista corretamente', () {
      final lista = ListaCompras(
        id: '1',
        nome: 'Supermercado',
        dataCriacao: DateTime.now(),
      );

      expect(lista.finalizada, false);
      expect(lista.dataFinalizacao, isNull);

      lista.finalizarLista();

      expect(lista.finalizada, true);
      expect(lista.dataFinalizacao, isNotNull);
    });

    test('deve reabrir lista corretamente', () {
      final lista = ListaCompras(
        id: '1',
        nome: 'Supermercado',
        dataCriacao: DateTime.now(),
      );

      lista.finalizarLista();
      expect(lista.finalizada, true);

      lista.reabrirLista();

      expect(lista.finalizada, false);
      expect(lista.dataFinalizacao, isNull);
    });
  });

  group('Item Model Tests', () {
    test('deve criar item corretamente', () {
      final item = Item(
        id: 'item1',
        nome: 'Arroz',
        quantidade: 2,
        preco: 10.0,
        dataCriacao: DateTime.now(),
      );

      expect(item.id, 'item1');
      expect(item.nome, 'Arroz');
      expect(item.quantidade, 2);
      expect(item.preco, 10.0);
      expect(item.comprado, false);
      expect(item.precoTotal, 20.0);
    });

    test('deve calcular preço total corretamente', () {
      final item = Item(
        id: 'item1',
        nome: 'Arroz',
        quantidade: 3,
        preco: 15.0,
        dataCriacao: DateTime.now(),
      );

      expect(item.precoTotal, 45.0);
    });

    test('deve retornar 0 quando preço é nulo', () {
      final item = Item(
        id: 'item1',
        nome: 'Arroz',
        quantidade: 2,
        dataCriacao: DateTime.now(),
      );

      expect(item.precoTotal, 0.0);
    });

    test('deve copiar item com alterações', () {
      final item = Item(
        id: 'item1',
        nome: 'Arroz',
        quantidade: 2,
        preco: 10.0,
        dataCriacao: DateTime.now(),
      );

      final itemCopiado = item.copyWith(nome: 'Arroz Integral', quantidade: 3);

      expect(itemCopiado.id, item.id);
      expect(itemCopiado.nome, 'Arroz Integral');
      expect(itemCopiado.quantidade, 3);
      expect(itemCopiado.preco, 10.0);
    });

    test('deve marcar item como comprado', () {
      final item = Item(
        id: 'item1',
        nome: 'Arroz',
        quantidade: 2,
        preco: 10.0,
        dataCriacao: DateTime.now(),
      );

      expect(item.comprado, false);
      expect(item.dataCompra, isNull);

      final itemComprado = item.copyWith(
        comprado: true,
        dataCompra: DateTime.now(),
      );

      expect(itemComprado.comprado, true);
      expect(itemComprado.dataCompra, isNotNull);
    });
  });
}
