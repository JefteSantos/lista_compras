import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lista_compras/models/listas_provider.dart';
import 'package:lista_compras/models/lista_compras.dart';
import 'package:lista_compras/models/item.dart';
import 'package:lista_compras/screens/home_screen.dart';
import 'package:lista_compras/services/hive_service.dart';
import 'package:hive/hive.dart';
import 'dart:io';

void main() {
  setUpAll(() async {
    final tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ItemAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(ListaComprasAdapter());
  });

  setUp(() async {
    final lb = await Hive.openBox<ListaCompras>('listas_compras');
    final ib = await Hive.openBox<Item>('itens');
    final cb = await Hive.openBox('configuracoes');
    await HiveService.init(listaBox: lb, itemBox: ib, configBox: cb);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
  });

  group('HomeScreen Widget Tests', () {
    testWidgets('deve exibir título corretamente', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => ListasProvider(),
            child: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Minhas Listas'), findsOneWidget);
    });

    testWidgets('deve exibir tabs Ativas e Histórico', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => ListasProvider(),
            child: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ativas'), findsOneWidget);
      expect(find.text('Histórico'), findsOneWidget);
    });

    testWidgets('deve exibir FAB para adicionar lista', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => ListasProvider(),
            child: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('deve exibir botão de relatórios', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => ListasProvider(),
            child: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    });
  });
}
