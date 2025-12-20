import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lista_compras/main.dart' as app;
import 'package:lista_compras/services/hive_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    // Limpa o banco de dados Hive antes de cada teste para garantir isolamento e agilidade
    await HiveService.limparTodosDados();
  });

  group('App Integration Tests', () {
    testWidgets('deve criar uma nova lista', (WidgetTester tester) async {
      app.main();
      await tester.pump(const Duration(milliseconds: 400));

      final fab = find.byKey(const Key('fabNovaLista'));
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Nova Lista'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Lista de Teste');
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('CRIAR'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Lista de Teste'), findsOneWidget);
    });

    testWidgets('deve adicionar item à lista', (WidgetTester tester) async {
      app.main();
      await tester.pump(const Duration(milliseconds: 400));

      final fab = find.byKey(const Key('fabNovaLista'));
      await tester.tap(fab);
      await tester.pump(const Duration(milliseconds: 400));

      await tester.enterText(find.byType(TextField), 'Supermercado');
      await tester.tap(find.text('CRIAR'));
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Supermercado'));
      await tester.pump(const Duration(milliseconds: 400));

      final addItemFab = find.byKey(const Key('fabNovoItem'));
      await tester.tap(addItemFab);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Novo Item'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Arroz');
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('SALVAR'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Arroz'), findsOneWidget);
    });

    testWidgets('deve navegar para tela de relatórios', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pump(const Duration(milliseconds: 400));

      final reportButton = find.byIcon(Icons.bar_chart);
      expect(reportButton, findsOneWidget);

      await tester.tap(reportButton);
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Relatório de Compras'), findsOneWidget);
    });

    testWidgets('deve alternar entre tabs Ativas e Histórico', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Ativas'), findsOneWidget);
      expect(find.text('Histórico'), findsOneWidget);

      await tester.tap(find.text('Histórico'));
      await tester.pump(const Duration(milliseconds: 400));

      await tester.tap(find.text('Ativas'));
      await tester.pump(const Duration(milliseconds: 400));
    });
  });
}
