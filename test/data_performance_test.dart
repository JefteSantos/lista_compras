import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:lista_compras/hive_registrar.g.dart';
import 'package:lista_compras/models/item.dart';
import 'package:lista_compras/models/lista_compras.dart';
import 'package:lista_compras/models/listas_provider.dart';
import 'package:lista_compras/models/preco_historico.dart';
import 'package:lista_compras/services/hive_service.dart';
import 'package:lista_compras/utils/list_summary.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory databaseDirectory;
  late Box<ListaCompras> listaBox;
  late ListasProvider provider;

  setUpAll(() async {
    databaseDirectory = await Directory.systemTemp.createTemp('listas_data_');
    Hive.init(databaseDirectory.path);
    Hive.registerAdapters();
  });

  setUp(() async {
    // These tests exercise persistence without invoking mobile widget plugins.
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
    listaBox = await Hive.openBox<ListaCompras>('test_listas');
    final itemBox = await Hive.openBox<Item>('test_itens');
    final configBox = await Hive.openBox('test_configuracoes');
    final historicoBox = await Hive.openBox<PrecoHistorico>('test_historico');
    await HiveService.init(
      listaBox: listaBox,
      itemBox: itemBox,
      configBox: configBox,
      historicoBox: historicoBox,
    );
    provider = ListasProvider();
  });

  tearDown(() async {
    provider.dispose();
    await HiveService.limparTodosDados();
    await HiveService.fecharBoxes();
    debugDefaultTargetPlatformOverride = null;
  });

  tearDownAll(() async {
    await Hive.close();
    await databaseDirectory.delete(recursive: true);
  });

  test('summary preserves fractional quantities and unpriced items', () {
    final summary = ListSummary.fromItems([
      _item('rice', price: 8, quantity: 1.5, purchased: true),
      _item('milk', price: 5, quantity: 2),
      _item('bread', purchased: true),
    ]);

    expect(summary.itemCount, 3);
    expect(summary.purchasedCount, 2);
    expect(summary.total, 22);
    expect(summary.purchasedTotal, 12);
    expect(summary.pendingTotal, 10);
    final empty = ListSummary.fromItems([]);
    expect(empty.itemCount, 0);
    expect(empty.total, 0);
    expect(empty.pendingTotal, 0);
  });

  test(
    'changing one list refreshes its totals and keeps other summaries',
    () async {
      final first = _list('first', items: [_item('rice', price: 8)]);
      final second = _list('second', items: [_item('milk', price: 5)]);
      await provider.adicionarLista(first);
      await provider.adicionarLista(second);
      final firstSummary = provider.obterResumoLista(first);
      final secondSummary = provider.obterResumoLista(second);
      final revision = provider.dataRevision;

      expect(provider.obterResumoLista(first), same(firstSummary));
      await provider.adicionarItem(first, _item('bread', price: 3));

      final updated = provider.obterResumoLista(first);
      expect(updated.total, 11);
      expect(updated.itemCount, 2);
      expect(updated, isNot(same(firstSummary)));
      expect(provider.obterResumoLista(second), same(secondSummary));
      expect(provider.dataRevision, revision + 1);
      expect(HiveService.obterListaCompras(first.id)!.itens, hasLength(2));
    },
  );

  test(
    'item edits preserve list partitions and refresh purchased totals',
    () async {
      final list = _list('first', items: [_item('rice', price: 8)]);
      await provider.adicionarLista(list);
      final activeLists = provider.listasAtivas;
      final finishedLists = provider.listasFinalizadas;
      provider.obterResumoLista(list);

      await provider.alternarStatusItem(list, list.itens.first);

      expect(provider.listasAtivas, same(activeLists));
      expect(provider.listasFinalizadas, same(finishedLists));
      expect(provider.obterResumoLista(list).purchasedTotal, 8);
      expect(list.itens.first.dataCompra, isNotNull);

      await provider.alternarStatusItem(list, list.itens.first);

      expect(provider.obterResumoLista(list).purchasedTotal, 0);
      expect(list.itens.first.dataCompra, isNull);
    },
  );

  test(
    'totals refresh while an item save is still awaiting persistence',
    () async {
      final list = _list('first', items: [_item('rice', price: 8)]);
      await provider.adicionarLista(list);
      expect(provider.obterResumoLista(list).total, 8);

      final pendingSave = provider.atualizarItem(
        list,
        list.itens.first.copyWith(preco: 12),
      );
      expect(provider.obterResumoLista(list).total, 12);
      await pendingSave;

      list.itens.first.preco = 15;
      final pendingListSave = provider.atualizarLista(list);
      expect(provider.obterResumoLista(list).total, 15);
      await pendingListSave;
    },
  );

  test('finalizing and reopening refresh cached list partitions', () async {
    final list = _list(
      'first',
      items: [
        _item('rice', price: 8, purchased: true, category: 'food'),
        _item('rice-duplicate', name: ' RICE ', price: 8, purchased: true),
        _item('milk', price: 5),
      ],
    );
    await provider.adicionarLista(list);
    expect(provider.listasAtivas, [list]);
    expect(provider.listasFinalizadas, isEmpty);
    expect(provider.obterUltimaCategoria('rice'), 'food');

    await provider.finalizarLista(list);

    expect(provider.listasAtivas, isEmpty);
    expect(provider.listasFinalizadas, [list]);
    expect(provider.obterHistorico('rice')!.entradas, hasLength(1));
    expect(provider.obterHistorico('rice')!.ultimaData, list.dataFinalizacao);
    expect(provider.obterHistorico('milk'), isNull);
    expect(provider.obterUltimaCategoria('rice'), 'food');

    await provider.reabrirLista(list);

    expect(provider.listasAtivas, [list]);
    expect(provider.listasFinalizadas, isEmpty);
    expect(list.dataFinalizacao, isNull);
  });

  test(
    'category suggestions refresh after renaming, clearing and deleting',
    () async {
      final older = _list(
        'older',
        day: 1,
        items: [_item('old-rice', name: 'Rice', category: 'older-category')],
      );
      final newer = _list(
        'newer',
        day: 2,
        items: [_item('rice', name: ' Rice ', category: 'newer-category')],
      );
      await provider.adicionarLista(older);
      await provider.adicionarLista(newer);
      expect(provider.obterUltimaCategoria('RICE'), 'newer-category');

      await provider.atualizarItem(
        newer,
        newer.itens.first.copyWith(nome: 'Beans'),
      );

      expect(provider.obterUltimaCategoria('rice'), 'older-category');
      expect(provider.obterUltimaCategoria('beans'), 'newer-category');

      // Models are mutable: saving the same object must also invalidate the index.
      newer.itens.first.categoria = null;
      await provider.atualizarItem(newer, newer.itens.first);
      expect(provider.obterUltimaCategoria('beans'), isNull);

      await provider.removerItem(older, older.itens.first);
      expect(provider.obterUltimaCategoria('rice'), isNull);
    },
  );

  test(
    'replacing a list refreshes references, order and its summary',
    () async {
      final first = _list('first', day: 1, items: [_item('rice', price: 8)]);
      final second = _list('second', day: 2);
      await provider.adicionarLista(first);
      await provider.adicionarLista(second);
      provider.listasAtivas;
      provider.obterResumoLista(first);
      final replacement = first.copyWith(
        itens: [_item('rice', price: 12)],
        dataCriacao: DateTime(2026, 10, 3),
      );

      await provider.atualizarLista(replacement);

      expect(provider.listas.map((list) => list.id), ['first', 'second']);
      expect(provider.listasAtivas.first, same(replacement));
      expect(provider.getListaPorId('first'), same(replacement));
      expect(provider.obterResumoLista(replacement).total, 12);
      expect(provider.obterResumoLista(first).total, 8);
    },
  );

  test('each item mutation persists and notifies exactly once', () async {
    final list = _list('first');
    await provider.adicionarLista(list);
    var writes = 0;
    var notifications = 0;
    final subscription = listaBox.watch(key: list.id).listen((_) => writes++);
    provider.addListener(() => notifications++);

    await provider.adicionarItem(list, _item('rice', price: 8));
    await provider.atualizarItem(list, list.itens.first.copyWith(preco: 9));
    await provider.removerItem(list, list.itens.first);
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(writes, 3);
    expect(notifications, 3);
    expect(HiveService.obterListaCompras(list.id)!.itens, isEmpty);
  });

  test('missing items neither write nor change the data revision', () async {
    final list = _list('first');
    await provider.adicionarLista(list);
    final revision = provider.dataRevision;
    var writes = 0;
    final subscription = listaBox.watch().listen((_) => writes++);

    await provider.atualizarItem(list, _item('missing'));
    await provider.removerItem(list, _item('missing'));
    await Future<void>.delayed(Duration.zero);
    await subscription.cancel();

    expect(provider.dataRevision, revision);
    expect(writes, 0);
  });

  test('imports invalidate old summaries and retain merge semantics', () async {
    final original = _list('first', items: [_item('rice', price: 8)]);
    await provider.adicionarLista(original);
    provider.obterResumoLista(original);
    final replacement = _list('first', items: [_item('rice', price: 12)]);
    final added = _list('second', day: 2);

    await provider.importarListas([replacement, added]);

    expect(provider.listas, hasLength(2));
    expect(
      provider.obterResumoLista(provider.getListaPorId('first')!).total,
      8,
    );

    await provider.importarListas([replacement], substituir: true);

    expect(provider.listas, hasLength(1));
    expect(provider.getListaPorId('second'), isNull);
    expect(
      provider.obterResumoLista(provider.getListaPorId('first')!).total,
      12,
    );
  });

  test(
    'deleting a list retains other cached totals and removes its category',
    () async {
      final first = _list('first', items: [_item('rice', category: 'food')]);
      final second = _list('second', items: [_item('milk', price: 5)]);
      await provider.adicionarLista(first);
      await provider.adicionarLista(second);
      final summary = provider.obterResumoLista(second);
      expect(provider.obterUltimaCategoria('rice'), 'food');

      await provider.removerLista('first');

      expect(provider.getListaPorId('first'), isNull);
      expect(provider.obterUltimaCategoria('rice'), isNull);
      expect(provider.obterResumoLista(second), same(summary));
    },
  );

  test('summaries of unsaved lists do not reuse a stale mutable snapshot', () {
    final list = _list('unsaved', items: [_item('rice', price: 8)]);
    expect(provider.obterResumoLista(list).total, 8);
    list.itens.first.preco = 12;
    expect(provider.obterResumoLista(list).total, 12);
  });

  test(
    'persisted changes survive closing and reopening the database',
    () async {
      final list = _list('first', items: [_item('rice', price: 8)]);
      await provider.adicionarLista(list);
      await provider.alternarStatusItem(list, list.itens.first);
      await listaBox.flush();
      await listaBox.close();
      listaBox = await Hive.openBox<ListaCompras>('test_listas');
      await HiveService.init(
        listaBox: listaBox,
        itemBox: HiveService.itemBox,
        configBox: HiveService.configBox,
        historicoBox: HiveService.historicoPrecosBox,
      );
      await provider.carregarListas();

      final restored = provider.getListaPorId(list.id)!;
      expect(restored.itens.first.comprado, isTrue);
      expect(restored.itens.first.dataCompra, isNotNull);
      expect(provider.obterResumoLista(restored).purchasedTotal, 8);
    },
  );
}

ListaCompras _list(String id, {int day = 1, List<Item>? items}) => ListaCompras(
  id: id,
  nome: id,
  dataCriacao: DateTime(2026, 10, day),
  itens: items,
);

Item _item(
  String id, {
  String? name,
  double? price,
  double quantity = 1,
  bool purchased = false,
  String? category,
}) => Item(
  id: id,
  nome: name ?? id,
  preco: price,
  quantidade: quantity,
  comprado: purchased,
  categoria: category,
  dataCriacao: DateTime(2026, 10, 1),
);
