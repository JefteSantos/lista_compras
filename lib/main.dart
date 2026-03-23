import 'package:flutter/material.dart';
import 'services/hive_service.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:lista_compras/models/listas_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/auth_service.dart';
import 'services/drive_backup_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  Intl.defaultLocale = 'pt_BR';
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ListasProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Tenta renovar sessão Google silenciosamente ao iniciar
    AuthService.signInSilently();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Dispara backup automático quando o app vai para background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final provider = Provider.of<ListasProvider>(
        navigatorKey.currentContext!,
        listen: false,
      );
      DriveBackupService.uploadBackupSilently(provider.listas);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Não Esquece!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          dividerColor: Colors.transparent,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('pt', 'BR')],
      home: const HomeScreen(),
    );
  }
}

/// Chave global do Navigator para acessar context no WidgetsBindingObserver.
final navigatorKey = GlobalKey<NavigatorState>();
