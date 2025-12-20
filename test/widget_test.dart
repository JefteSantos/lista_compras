import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lista_compras/models/listas_provider.dart';
import 'package:lista_compras/screens/home_screen.dart';

void main() {
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

      expect(find.text('Minhas Listas'), findsOneWidget);
    });

    testWidgets('deve exibir tabs Ativas e Histórico', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => ListasProvider(),
            child: const HomeScreen(),
          ),
        ),
      );

      expect(find.text('Ativas'), findsOneWidget);
      expect(find.text('Histórico'), findsOneWidget);
    });

    testWidgets('deve exibir FAB para adicionar lista', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => ListasProvider(),
            child: const HomeScreen(),
          ),
        ),
      );

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

      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
    });
  });
}
