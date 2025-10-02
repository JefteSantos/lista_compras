import 'package:flutter/material.dart';
import 'services/hive_service.dart';
import 'examples/hive_example.dart';
import 'package:provider/provider.dart';
import 'package:lista_compras/models/listas_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListasProvider()),
      ],
      child: MyApp(),
    ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lista de Compras',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HiveExample(),
    );
  }
}
