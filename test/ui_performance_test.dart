import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:lista_compras/hive_registrar.g.dart';
import 'package:lista_compras/l10n/generated/app_localizations.dart';
import 'package:lista_compras/models/item.dart';
import 'package:lista_compras/models/lista_compras.dart';
import 'package:lista_compras/models/listas_provider.dart';
import 'package:lista_compras/models/preco_historico.dart';
import 'package:lista_compras/screens/list_detail_screen.dart';
import 'package:lista_compras/screens/report_screen.dart';
import 'package:lista_compras/services/hive_service.dart';
import 'package:lista_compras/utils/app_utils.dart';
import 'package:provider/provider.dart';

class _CountingListasProvider extends ListasProvider {
  int listReads = 0;

  @override
  List<ListaCompras> get listas {
    listReads++;
    return super.listas;
  }

  void notifyStatusOnly() => notifyListeners();
}

Widget _app(ListasProvider provider, Widget screen) {
  return ChangeNotifierProvider<ListasProvider>.value(
    value: provider,
    child: MaterialApp(
      locale: const Locale('pt'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ),
  );
}

void main() {
  late Directory hiveDirectory;
  final createdAt = DateTime(2026, 1, 10);

  setUpAll(() {
    hiveDirectory = Directory.systemTemp.createTempSync('shopping-ui-test-');
    Hive.init(hiveDirectory.path);
    Hive.registerAdapters();
  });

  setUp(() async {
    await HiveService.init(
      listaBox: await Hive.openBox<ListaCompras>('listas_compras'),
      itemBox: await Hive.openBox<Item>('itens'),
      configBox: await Hive.openBox('configuracoes'),
      historicoBox: await Hive.openBox<PrecoHistorico>('historico_precos'),
    );
  });

  tearDown(() => Hive.deleteFromDisk());

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  testWidgets(
    'expanded report builds only visible item rows and can reach the last item',
    (tester) async {
      final lista = ListaCompras(
        id: 'large-list',
        nome: 'Compra grande',
        dataCriacao: createdAt,
        itens: List.generate(
          1000,
          (index) => Item(
            id: 'item-$index',
            nome: 'Produto $index',
            dataCriacao: createdAt,
            preco: 1,
          ),
        ),
      );
      await tester.runAsync(() => HiveService.salvarListaCompras(lista));
      final provider = _CountingListasProvider();
      addTearDown(provider.dispose);
      await tester.pumpWidget(_app(provider, const ReportScreen()));
      await tester.pumpAndSettle();
      final initialReads = provider.listReads;

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      expect(provider.listReads, initialReads);
      expect(find.text('Produto 0'), findsOneWidget);
      expect(find.text('Produto 999'), findsNothing);
      final renderedItems = find
          .byWidgetPredicate(
            (widget) =>
                widget is Text &&
                (widget.data?.startsWith('Produto ') ?? false),
          )
          .evaluate()
          .length;
      expect(renderedItems, greaterThan(0));

      await tester.scrollUntilVisible(
        find.text('Produto 999'),
        2000,
        maxScrolls: 30,
        scrollable: find.descendant(
          of: find.byType(ListView),
          matching: find.byType(Scrollable),
        ),
      );
      expect(find.text('Produto 999'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'report ignores status notifications and refreshes filters and totals after edits',
    (tester) async {
      final lista = ListaCompras(
        id: 'market',
        nome: 'Mercado',
        dataCriacao: createdAt,
        itens: [
          Item(id: 'rice', nome: 'Arroz', preco: 10, dataCriacao: createdAt),
        ],
      );
      final other = ListaCompras(
        id: 'pharmacy',
        nome: 'Farmácia',
        dataCriacao: createdAt.subtract(const Duration(days: 1)),
        itens: [
          Item(id: 'soap', nome: 'Sabonete', preco: 4, dataCriacao: createdAt),
        ],
      );
      await tester.runAsync(
        () => HiveService.salvarListasCompras([lista, other]),
      );
      final provider = _CountingListasProvider();
      addTearDown(provider.dispose);
      await tester.pumpWidget(_app(provider, const ReportScreen()));
      await tester.pumpAndSettle();

      String? grandTotal() => tester
          .widget<Text>(find.byKey(const ValueKey('report-grand-total')).first)
          .data;
      expect(grandTotal(), AppUtils.formatMoney(14));
      final initialReads = provider.listReads;
      provider.notifyStatusOnly();
      await tester.pumpAndSettle();
      expect(provider.listReads, initialReads);

      await tester.enterText(find.byType(TextField), 'ARROZ');
      await tester.pumpAndSettle();
      expect(find.text('Mercado'), findsOneWidget);
      expect(find.text('Farmácia'), findsNothing);
      expect(grandTotal(), AppUtils.formatMoney(10));

      final readsAfterSearch = provider.listReads;
      await tester.enterText(find.byType(TextField), 'arroz');
      await tester.pumpAndSettle();
      expect(provider.listReads, readsAfterSearch);

      await tester.runAsync(
        () => provider.atualizarItem(
          lista,
          lista.itens.single.copyWith(preco: 20),
        ),
      );
      await tester.pumpAndSettle();
      expect(grandTotal(), AppUtils.formatMoney(20));

      await tester.enterText(find.byType(TextField), 'sabonete');
      await tester.pumpAndSettle();
      expect(find.text('Farmácia'), findsOneWidget);
      expect(find.text('Mercado'), findsNothing);
      expect(grandTotal(), AppUtils.formatMoney(4));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a large category remains lazy in list details', (tester) async {
    final lista = ListaCompras(
      id: 'grouped-list',
      nome: 'Agrupada',
      dataCriacao: createdAt,
      itens: List.generate(
        1000,
        (index) => Item(
          id: 'item-$index',
          nome: 'Produto $index',
          categoria: 'Mercado',
          dataCriacao: createdAt,
        ),
      ),
    );
    await tester.runAsync(() async {
      await HiveService.salvarListaCompras(lista);
      await HiveService.salvarConfiguracao('agrupar_por_categoria', true);
    });
    final provider = ListasProvider();
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      _app(provider, ListDetailScreen(listaId: lista.id)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Produto 0'), findsOneWidget);
    expect(find.text('Produto 999'), findsNothing);
    expect(find.byType(Dismissible).evaluate().length, lessThan(30));
    expect(tester.takeException(), isNull);
  });
}
